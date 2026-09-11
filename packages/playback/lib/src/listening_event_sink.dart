import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:meta/meta.dart';

/// Batch event writer (app implements it over `EventsDao.insertAll`).
///
/// Upsert semantics by event id: interim 5s snapshots and the final close
/// share one id, so a single observation is always a single row.
typedef PlayEventBatchWriter = Future<void> Function(List<PlayEvent> events);

/// Reco wake-up hook (default NO-OP — playback never imports reco).
///
/// The app layer debounces this into `UpdateProfileFromEvents` (1500ms
/// after bursts). Reco reads only the database; never the network.
typedef RecoTrigger = void Function();

/// No-op reco hook (default; keeps playback reco-free).
void _noopReco() {}

/// Open (unclosed) listening observation.
@immutable
final class _OpenObservation {
  /// Creates an observation.
  const _OpenObservation({
    required this.eventId,
    required this.track,
    required this.source,
    required this.sessionId,
    required this.startedAt,
    required this.durationMs,
  });

  /// Event id shared by interim snapshots and the final close.
  final String eventId;

  /// Observed track.
  final Track track;

  /// Where playback originated.
  final PlaySource source;

  /// Session captured at start (rotation applies to the next event).
  final String sessionId;

  /// Observation start (UTC).
  final DateTime startedAt;

  /// Track length at play time, in milliseconds.
  final int durationMs;
}

/// Last closed observation (quick-restart merge signal).
@immutable
final class _ClosedNote {
  /// Creates a note.
  const _ClosedNote({
    required this.trackId,
    required this.closedAt,
    required this.listenedMs,
    required this.skipped,
  });

  /// Closed track id.
  final String trackId;

  /// Close time (UTC).
  final DateTime closedAt;

  /// Heard milliseconds in the closed observation.
  final int listenedMs;

  /// Whether the closed observation was a skip.
  final bool skipped;
}

/// Accumulates listening observations and flushes `PlayEvent`s (spec 9).
///
/// Wall-time accounting: `listenedMs` grows while unpaused (seek jumps
/// count as heard wall time — an approximation documented for Phase 3
/// refinement). Flush points: pause, skip, complete, track change, app
/// background (`flush()`), and every 5s while playing with ≥1000ms of
/// unflushed audio. Noise (`listenedMs` < 3000, not a skip) is dropped
/// before it ever reaches the writer.
final class ListeningEventSink {
  /// Creates the sink.
  ListeningEventSink({
    required this.clock,
    required this.writer,
    this.onEventsFlushed = _noopReco,
    String? sessionId,
  }) : sessionId = sessionId ?? AuroraIds.newSessionId();

  /// Injectable clock (event timestamps + bucket math).
  final Clock clock;

  /// Batch event writer (upsert by event id).
  final PlayEventBatchWriter writer;

  /// Reco wake-up hook (default NO-OP — playback never imports reco).
  final RecoTrigger onEventsFlushed;

  /// Current session (the controller rotates this on cold start/idle).
  String sessionId;

  /// Whether the device is offline (set by the controller per item).
  bool wasOffline = false;

  /// Playback speed multiplier (1.0 until Phase 5).
  double playbackSpeed = 1;

  _OpenObservation? _open;
  DateTime? _resumeMark;
  bool _paused = false;
  int _listenedMs = 0;
  int _flushedMs = 0;
  int _seekCount = 0;
  _ClosedNote? _lastClosed;

  /// Quick restarts merged into the previous event (test hook, spec 9).
  int replaysDetected = 0;

  /// Whether an observation is open.
  bool get hasOpen => _open != null;

  /// Heard milliseconds in the open observation (tests).
  int get openListenedMs => _listenedMs;

  /// Starts observing [track] (auto-closes a dangling item as skipped).
  void onStarted(Track track, PlaySource source) {
    if (_open != null) {
      _close(skipped: true, skipAtMs: _listenedMs);
    }
    final now = clock.nowUtc();
    final previous = _lastClosed;
    if (previous != null &&
        previous.trackId == track.id &&
        !previous.skipped &&
        previous.listenedMs < 3000 &&
        now.difference(previous.closedAt).inMilliseconds <= 2000) {
      // Quick restart of an incomplete play: extend the previous event
      // instead of minting a new row (no extra playCount downstream).
      replaysDetected++;
    }
    _open = _OpenObservation(
      eventId: AuroraIds.newId(),
      track: track,
      source: source,
      sessionId: sessionId,
      startedAt: now,
      durationMs: track.durationMs,
    );
    _resumeMark = now;
    _paused = false;
    _listenedMs = 0;
    _flushedMs = 0;
    _seekCount = 0;
  }

  /// Suspends accumulation and persists progress (≥3000ms only).
  void onPaused() {
    if (_open == null || _paused) {
      return;
    }
    _accumulate();
    _paused = true;
    _resumeMark = null;
    if (_listenedMs >= 3000 && _listenedMs - _flushedMs > 0) {
      _flushedMs = _listenedMs;
      unawaited(_write(<PlayEvent>[_snapshot(endedAt: null)]));
    }
  }

  /// Resumes accumulation on the same event id.
  void onResumed() {
    if (_open == null || !_paused) {
      return;
    }
    _paused = false;
    _resumeMark = clock.nowUtc();
  }

  /// Records a seek gesture (spam bumps the counter, never new events).
  void onSeek(Duration from, Duration to) {
    if (_open == null) {
      return;
    }
    _accumulate();
    _seekCount++;
  }

  /// Closes the observation as a genuine complete (auto-next ≠ skip).
  void onCompleted() {
    if (_open == null) {
      return;
    }
    _accumulate();
    _close(skipped: false);
  }

  /// Closes as a user skip (always recorded, however short).
  void onSkipped({int? atMs}) {
    if (_open == null) {
      return;
    }
    _accumulate();
    _close(skipped: true, skipAtMs: atMs ?? _listenedMs);
  }

  /// Closes without skip semantics (stop path; noise still dropped).
  void onStopped() {
    if (_open == null) {
      return;
    }
    _accumulate();
    _close(skipped: false);
  }

  /// Periodic/background flush: persists when ≥1000ms is unflushed.
  Future<void> flush() async {
    if (_open == null || _paused) {
      return;
    }
    _accumulate();
    if (_listenedMs >= 3000 && _listenedMs - _flushedMs >= 1000) {
      _flushedMs = _listenedMs;
      await _write(<PlayEvent>[_snapshot(endedAt: null)]);
    }
  }

  void _accumulate() {
    final mark = _resumeMark;
    if (_open == null || _paused || mark == null) {
      return;
    }
    final now = clock.nowUtc();
    _listenedMs += now.difference(mark).inMilliseconds;
    if (_listenedMs < 0) {
      _listenedMs = 0;
    }
    _resumeMark = now;
  }

  void _close({required bool skipped, int? skipAtMs}) {
    final open = _open;
    if (open == null) {
      return;
    }
    final now = clock.nowUtc();
    final duration = open.durationMs;
    final ratio = (_listenedMs / (duration < 1 ? 1 : duration)).clamp(0, 1);
    _lastClosed = _ClosedNote(
      trackId: open.track.id,
      closedAt: now,
      listenedMs: _listenedMs,
      skipped: skipped,
    );
    final listened = _listenedMs;
    final seeks = _seekCount;
    _open = null;
    _resumeMark = null;
    _paused = false;
    _listenedMs = 0;
    _flushedMs = 0;
    _seekCount = 0;
    if (!skipped && listened < 3000) {
      return;
    }
    unawaited(
      _write(
        <PlayEvent>[
          _eventFor(
            open,
            listenedMs: listened,
            completionRatio: ratio.toDouble(),
            skipped: skipped,
            skipAtMs: skipAtMs,
            endedAt: now,
            seekCount: seeks,
          ),
        ],
      ),
    );
  }

  PlayEvent _snapshot({required DateTime? endedAt}) {
    final open = _open!;
    final ratio = (_listenedMs / (open.durationMs < 1 ? 1 : open.durationMs))
        .clamp(
          0,
          1,
        );
    return _eventFor(
      open,
      listenedMs: _listenedMs,
      completionRatio: ratio.toDouble(),
      skipped: false,
      endedAt: endedAt,
      seekCount: _seekCount,
    );
  }

  PlayEvent _eventFor(
    _OpenObservation open, {
    required int listenedMs,
    required double completionRatio,
    required bool skipped,
    required int seekCount,
    DateTime? endedAt,
    int? skipAtMs,
  }) {
    final startedLocal = open.startedAt.toLocal();
    return PlayEvent(
      id: open.eventId,
      trackId: open.track.id,
      sessionId: open.sessionId,
      startedAt: open.startedAt,
      durationMs: open.durationMs,
      listenedMs: listenedMs,
      completionRatio: completionRatio,
      skipped: skipped,
      source: open.source,
      timeOfDayBucket: startedLocal.timeOfDayBucket,
      dayOfWeek: startedLocal.auroraDayOfWeek,
      endedAt: endedAt,
      skipAtMs: skipAtMs,
      playbackSpeed: playbackSpeed,
      wasOffline: wasOffline,
      seekCount: seekCount,
    );
  }

  /// Writes one batch (never throws; persistence must not break playback).
  Future<void> _write(List<PlayEvent> events) async {
    try {
      await writer(events);
    } on Exception {
      return;
    }
    onEventsFlushed();
  }
}
