import 'dart:async';
import 'dart:developer' as developer;

import 'package:audio_service/audio_service.dart';
import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_playback/src/audio_engine.dart';
import 'package:aurora_playback/src/audio_handler.dart';
import 'package:aurora_playback/src/listening_event_sink.dart';
import 'package:aurora_playback/src/playback_state.dart';
import 'package:aurora_playback/src/playback_store.dart';
import 'package:aurora_playback/src/queue_controller.dart';
import 'package:meta/meta.dart';

/// Appends radio tracks when the queue runs low (Phase 4 use-case).
///
/// Called with the seed track; must never block (the controller guards
/// concurrency and failures). Null disables radio refill.
typedef RadioRefill = Future<List<Track>> Function(Track seed);

/// Rehydrates tracks for a persisted queue (app reads the database).
typedef TrackResolver =
    Future<Map<String, Track>> Function(
      List<String> trackIds,
    );

/// Resolves full notification metadata for [track] (artist/album/artwork).
///
/// Wired by the app layer (display names + cached art lookups); when null
/// the controller falls back to [trackToMediaItem] plus provider artwork
/// (local file URI else online thumbnail URL else null). Never throws:
/// failures degrade to the basic item.
typedef MediaItemResolver = Future<MediaItem> Function(Track track);

/// Fetches a bot-gated [MediaHandleKind.authorizedStream] to a temp file
/// and returns its path, so the engine can play it as a local file.
///
/// Device-proven need: googlevideo URLs that resolve fine return HTTP 403
/// inside ExoPlayer on some networks while a plain Dart HTTP GET of the
/// same URL can still succeed. The app layer owns the temp dir + HTTP
/// fetch; the controller only loads the returned file (same status flow
/// as any local file). Null disables the fallback. Never throws: null
/// (or a throw, treated as null) means "use the normal re-resolve path".
typedef StreamFallback =
    Future<String?> Function(Track track, MediaHandle handle);

/// Browser-like headers attached to provider-authorized stream URLs.
///
/// `googlevideo` rejects requests without a browser `User-Agent` on some
/// networks, and `just_audio` builds `AudioSource.uri` without headers
/// unless they are passed to [AudioEngine.setSourceUri]. Sent for
/// [MediaHandleKind.authorizedStream] when the handle carries no headers
/// of its own; local files and `content://`/`file://` URIs stay
/// header-free (see `_streamHeaders`).
const Map<String, String> defaultStreamHeaders = <String, String>{
  'User-Agent':
      'Mozilla/5.0 (Linux; Android 14; Pixel 8 Build/AP2A.240905.003) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/126.0.0.0 Mobile Safari/537.36',
  'Accept': '*/*',
};

/// Allowed status transitions (spec section 8 state machine).
///
/// Rebuffering (`playing/ready/paused → buffering`) and pause-during-load
/// are legal: streams rebuffer on seeks, and users can pause mid-resolve.
const Map<PlaybackStatus, Set<PlaybackStatus>> _allowedTransitions =
    <PlaybackStatus, Set<PlaybackStatus>>{
      PlaybackStatus.idle: {PlaybackStatus.loading},
      PlaybackStatus.loading: {
        PlaybackStatus.buffering,
        PlaybackStatus.ready,
        PlaybackStatus.playing,
        PlaybackStatus.paused,
        PlaybackStatus.error,
        PlaybackStatus.idle,
      },
      PlaybackStatus.buffering: {
        PlaybackStatus.ready,
        PlaybackStatus.playing,
        PlaybackStatus.paused,
        PlaybackStatus.error,
        PlaybackStatus.idle,
      },
      PlaybackStatus.ready: {
        PlaybackStatus.playing,
        PlaybackStatus.paused,
        PlaybackStatus.buffering,
        PlaybackStatus.loading,
        PlaybackStatus.error,
        PlaybackStatus.idle,
      },
      PlaybackStatus.playing: {
        PlaybackStatus.paused,
        PlaybackStatus.buffering,
        PlaybackStatus.completed,
        PlaybackStatus.loading,
        PlaybackStatus.error,
        PlaybackStatus.idle,
      },
      PlaybackStatus.paused: {
        PlaybackStatus.playing,
        PlaybackStatus.buffering,
        PlaybackStatus.loading,
        PlaybackStatus.completed,
        PlaybackStatus.error,
        PlaybackStatus.idle,
      },
      PlaybackStatus.completed: {
        PlaybackStatus.loading,
        PlaybackStatus.playing,
        PlaybackStatus.idle,
      },
      PlaybackStatus.error: {
        PlaybackStatus.loading,
        PlaybackStatus.idle,
      },
    };

/// Player orchestration: queue, providers, engine, events (spec §8).
///
/// Tapping a track shows the mini-player immediately (`loading`), then
/// transitions through buffering to playing. Errors never clear the
/// queue: the item fails, the UI snacks (see [errors]), and playback
/// auto-skips after [missingSkipDelay]. Reco stays decoupled — radio
/// refill arrives via [radioRefill] (app layer), never a reco import.
final class PlaybackController {
  /// Creates the controller and subscribes to the engine.
  ///
  /// The controller takes engine ownership (see [dispose]). The audio
  /// handler stays reachable via [handler] for `AudioService.init`.
  PlaybackController({
    required this.providers,
    required this.engine,
    required this.handler,
    required this.queue,
    required this.events,
    required this.store,
    required this.clock,
    this.likeWriter,
    this.likeStateReader,
    this.trackResolver,
    this.mediaItemResolver,
    this.streamFallback,
    this.radioRefill,
    this.radioEnabled = false,
    this.defaultQuality = Quality.high,
    this.missingSkipDelay = const Duration(milliseconds: 800),
    this.persistInterval = const Duration(seconds: 5),
  }) : _info = PlaybackInfo.initial(events.sessionId) {
    handler.attachTransport(
      onPlay: resume,
      onPause: pause,
      onSeek: seek,
      onNext: next,
      onPrevious: previous,
      onStop: stop,
    );
    handler.onLikeRequest = () async {
      final track = _info.track;
      if (track == null) {
        return;
      }
      final current = likeStateReader?.call(track.id) ?? 0;
      await _writeLike(current == 1 ? 0 : 1);
    };
    _engineSubs
      ..add(
        engine.state.listen(
          _onEngineState,
          onError: (Object error, StackTrace stack) {
            developer.log(
              'engine state stream error=${_short(error)}',
              name: 'AURORA_DIAG',
              stackTrace: stack,
            );
          },
        ),
      )
      ..add(
        engine.position.listen(
          _onPosition,
          onError: (Object error, StackTrace stack) {
            developer.log(
              'engine position stream error=${_short(error)}',
              name: 'AURORA_DIAG',
              stackTrace: stack,
            );
          },
        ),
      )
      ..add(engine.becomingNoisy.listen((_) => pause()));
  }

  /// Provider registry (resolves playables per track).
  final ProviderRegistry providers;

  /// Audio output (the app injects the just_audio engine).
  final AudioEngine engine;

  /// Notification / lock-screen bridge.
  final AuroraAudioHandler handler;

  /// Playback queue (reorder + shuffle state for the queue sheet).
  final QueueController queue;

  /// Listening-event accumulator (writes play_events, never reco).
  final ListeningEventSink events;

  /// Queue + resume persistence (app implements it over DAOs).
  final PlaybackStore store;

  /// Injectable clock (timestamps, session rotation, TTL math).
  final Clock clock;

  /// Like persistence (app wires `StatsDao.setLikeState`; null = no-op).
  final LikeWriter? likeWriter;

  /// Reads the current like state for the media-notification toggle.
  final int Function(String trackId)? likeStateReader;

  /// Track rehydration for process-death restore (null = ids only).
  final TrackResolver? trackResolver;

  /// Notification metadata for the current item (null = provider-art
  /// fallback). Never blocks loads: enrichment publishes async and stale
  /// resolutions (skipped meanwhile) are dropped.
  final MediaItemResolver? mediaItemResolver;

  /// Temp-file fallback for gated stream URLs (null = re-resolve only).
  final StreamFallback? streamFallback;

  /// Radio refill hook (null disables; never blocks playback).
  RadioRefill? radioRefill;

  /// Queue-sheet radio toggle.
  bool radioEnabled;

  /// Quality for non-local tracks (local files always original).
  final Quality defaultQuality;

  /// Missing-file auto-skip delay (spec: 800ms).
  final Duration missingSkipDelay;

  /// Queue/position persist cadence while playing.
  final Duration persistInterval;

  final List<StreamSubscription<dynamic>> _engineSubs =
      <StreamSubscription<dynamic>>[];
  final StreamController<PlaybackInfo> _stream =
      StreamController<PlaybackInfo>.broadcast();
  final StreamController<PlaybackError> _errors =
      StreamController<PlaybackError>.broadcast();

  PlaybackInfo _info;
  bool _wantsPlaying = false;
  bool _refilling = false;
  int _lastHandlerPositionSec = -1;
  Timer? _persistTimer;
  Timer? _skipTimer;
  DateTime _lastActive = DateTime.fromMillisecondsSinceEpoch(0);
  int _resolveAttempts = 0;

  /// Current state frame.
  PlaybackInfo get info => _info;

  /// State frames (mini-player + notification listen here).
  Stream<PlaybackInfo> get stream => _stream.stream;

  /// Item failures (the UI shows a snackbar per event).
  Stream<PlaybackError> get errors => _errors.stream;

  /// Plays [track], replacing the queue (mini-player shows instantly).
  ///
  /// Explicit user intent: escapes a terminal [PlaybackStatus.error] via
  /// `error → loading` before the fresh load starts.
  Future<void> playTrack(Track track, {QueueContext? context}) async {
    final ctx = context ?? const QueueContext(origin: PlaySource.library);
    queue.setQueue(
      <Track>[track, ...ctx.upcoming],
      startIndex: 0,
      origin: ctx.origin,
      now: clock.nowUtc(),
    );
    _resetErrorForUserIntent();
    await _loadCurrent(autoplay: true);
  }

  /// Plays [tracks] from [startIndex].
  ///
  /// Explicit user intent: escapes a terminal [PlaybackStatus.error] via
  /// `error → loading` before the fresh load starts.
  Future<void> playQueue(
    List<Track> tracks, {
    int startIndex = 0,
    PlaySource origin = PlaySource.queue,
  }) async {
    if (tracks.isEmpty) {
      return;
    }
    queue.setQueue(
      tracks,
      startIndex: startIndex,
      origin: origin,
      now: clock.nowUtc(),
    );
    _resetErrorForUserIntent();
    await _loadCurrent(autoplay: true);
  }

  /// Suspends playback (persists queue + position).
  Future<void> pause() async {
    _wantsPlaying = false;
    _stopPersistTimer();
    try {
      await engine.pause();
    } on Exception {
      // Engine already idle; state mapping below still applies.
    }
    events.onPaused();
    _setStatus(PlaybackStatus.paused);
    _touch();
    await _persistAll();
  }

  /// Resumes playback (rotates the session after 30 min idle).
  ///
  /// Explicit user intent: from [PlaybackStatus.error] the dead source is
  /// discarded and the current item is reloaded from scratch (fresh
  /// resolve + headers) instead of resuming it. Without this, `resume`
  /// from error attempted the illegal `error → playing` transition and
  /// playback stayed bricked until restart.
  Future<void> resume() async {
    final track = _info.track;
    if (track == null) {
      return;
    }
    if (_info.status == PlaybackStatus.error) {
      await _loadCurrent(autoplay: true);
      return;
    }
    _rotateSessionIfIdle();
    _wantsPlaying = true;
    if (!events.hasOpen) {
      // Restored items never opened an observation; start one now.
      events.onStarted(
        track,
        queue.current?.origin ?? PlaySource.queue,
      );
    }
    events.onResumed();
    try {
      await engine.play();
    } on Object catch (e) {
      _itemError(_info.track!, 'Resume failed: ${_short(e)}');
      return;
    }
    _setStatus(PlaybackStatus.playing);
    _touch();
    _startPersistTimer();
  }

  /// Toggles play/pause (completed restarts the item).
  Future<void> toggle() async {
    if (_info.isPlaying) {
      await pause();
    } else if (_info.status == PlaybackStatus.completed) {
      await seek(Duration.zero);
      await resume();
    } else {
      await resume();
    }
  }

  /// Seeks within the current item (streams use range requests).
  Future<void> seek(Duration position) async {
    if (_info.track == null) {
      return;
    }
    final from = engine.positionNow;
    try {
      await engine.seek(position);
    } on Exception {
      return;
    }
    events.onSeek(from, position);
    _emit(_info.copyWith(position: position));
  }

  /// Advances (user skips count as skips; auto-advance does not).
  ///
  /// Explicit user intent always escapes [PlaybackStatus.error]: both
  /// load paths below reset `error → loading` first. The queue-exhausted
  /// path keeps the terminal state (there is nothing to load).
  Future<void> next({bool userInitiated = true}) async {
    final current = queue.current;
    if (current == null) {
      return;
    }
    if (userInitiated) {
      events.onSkipped(atMs: engine.positionNow.inMilliseconds);
    }
    final stepped = queue.step(1);
    if (stepped == null) {
      if (_info.repeatMode == RepeatMode.all && queue.length > 1) {
        queue.jumpTo(0);
        _resetErrorForUserIntent();
        await _loadCurrent(autoplay: _wantsPlaying || !userInitiated);
      } else {
        events.onCompleted();
        _wantsPlaying = false;
        _setStatus(PlaybackStatus.completed);
        await _persistAll();
      }
      return;
    }
    _resetErrorForUserIntent();
    await _loadCurrent(autoplay: _wantsPlaying || !userInitiated);
  }

  /// Restarts when position > 3s, else steps back (spec section 8).
  ///
  /// Explicit user intent escapes [PlaybackStatus.error] on the path
  /// that actually reloads (seek-only paths never touch the machine).
  Future<void> previous() async {
    if (queue.current == null) {
      return;
    }
    if (engine.positionNow > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    events.onSkipped(atMs: engine.positionNow.inMilliseconds);
    if (queue.step(-1) == null) {
      await seek(Duration.zero);
      return;
    }
    _resetErrorForUserIntent();
    await _loadCurrent(autoplay: _wantsPlaying);
  }

  /// Enables/disables shuffle (Fisher-Yates, order kept for unshuffle).
  Future<void> setShuffle({required bool enabled}) async {
    queue.setShuffle(enabled: enabled);
    _emit(_info.copyWith(shuffle: enabled));
    _publishHandlerState();
    await _persistAll();
  }

  /// Sets the repeat behavior.
  Future<void> setRepeat(RepeatMode mode) async {
    _emit(_info.copyWith(repeatMode: mode));
    _publishHandlerState();
    await _persistAll();
  }

  /// Sets volume 0..1.
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0, 1).toDouble();
    try {
      await engine.setVolume(clamped);
    } on Exception {
      return;
    }
    _emit(_info.copyWith(volume: clamped));
  }

  /// Sets playback speed. Phase 1 stub: stays 1.0 (TODO phase-5).
  Future<void> setSpeed(double speed) async {}

  /// Inserts [track] directly after the playhead.
  void addNext(Track track, {PlaySource origin = PlaySource.queue}) {
    queue.addNext(track, origin: origin, now: clock.nowUtc());
    unawaited(_persistAll());
  }

  /// Appends [track] at the end of the queue.
  void addLast(Track track, {PlaySource origin = PlaySource.queue}) {
    queue.addLast(track, origin: origin, now: clock.nowUtc());
    unawaited(_persistAll());
  }

  /// Removes the play-order entry at [index].
  void removeAt(int index) {
    queue.removeAt(index);
    unawaited(_persistAll());
  }

  /// Moves a play-order entry (queue-sheet reorder).
  void move(int from, int to) {
    queue.move(from, to);
    unawaited(_persistAll());
  }

  /// Likes the current track (persists via the app-wired writer).
  Future<void> likeCurrent() => _writeLike(1);

  /// Dislikes the current track (excluded from Home mixes downstream).
  Future<void> dislikeCurrent() => _writeLike(-1);

  /// Clears the like state of the current track.
  Future<void> clearLikeCurrent() => _writeLike(0);

  /// Stops playback and unloads (idle path).
  Future<void> stop() async {
    _skipTimer?.cancel();
    _stopPersistTimer();
    _wantsPlaying = false;
    events.onStopped();
    try {
      await engine.stop();
    } on Exception {
      // Already idle; continue to the idle state below.
    }
    _setStatus(PlaybackStatus.idle);
    _emit(_info.copyWith(clearTrack: true, position: Duration.zero));
    // Dismissed/stopped: clear the notification content + expanded queue
    // per audio_service norms (the service itself stops best-effort via
    // androidStopForegroundOnPause defaults).
    handler
      ..setCurrentItem(null)
      ..setQueueItems(const <MediaItem>[]);
    _publishHandlerState();
    await _persistAll();
  }

  /// Restores queue + position after process death (±1s, starts paused).
  Future<void> restore() async {
    final stored = await store.loadQueue();
    if (stored.items.isEmpty) {
      return;
    }
    var tracks = <String, Track>{};
    final resolver = trackResolver;
    if (resolver != null) {
      try {
        tracks = await resolver(
          <String>[for (final i in stored.items) i.trackId],
        );
      } on Exception {
        tracks = <String, Track>{};
      }
    }
    queue.restore(
      items: stored.items.length > 200
          ? stored.items.sublist(0, 200)
          : stored.items,
      index: stored.index,
      tracks: tracks,
    );
    final state = await store.loadState();
    final restoreItem = queue.current;
    if (restoreItem == null) {
      return;
    }
    final track = queue.trackById(restoreItem.trackId);
    if (track == null) {
      return;
    }
    _emit(
      _info.copyWith(
        shuffle: state?.shuffle ?? false,
        repeatMode: _repeatFrom(state?.repeatMode),
        sessionId: AuroraIds.newSessionId(),
      ),
    );
    events.sessionId = _info.sessionId;
    await _prepareLoaded(
      track,
      autoplay: false,
      startAt: Duration(milliseconds: state?.positionMs ?? 0),
    );
  }

  /// Releases timers and subscriptions (takes engine ownership).
  Future<void> dispose() async {
    _skipTimer?.cancel();
    _stopPersistTimer();
    for (final sub in _engineSubs) {
      await sub.cancel();
    }
    await _stream.close();
    await _errors.close();
    await engine.dispose();
  }

  Future<void> _writeLike(int likeState) async {
    final track = _info.track;
    final writer = likeWriter;
    if (track == null || writer == null) {
      return;
    }
    await writer(trackId: track.id, likeState: likeState);
  }

  Future<void> _loadCurrent({required bool autoplay}) async {
    _skipTimer?.cancel();
    try {
      // Cut previous audio immediately; the mini-player is already live.
      await engine.pause();
    } on Exception {
      // Engine already idle; continue loading below.
    }
    final item = queue.current;
    if (item == null) {
      return;
    }
    final track = queue.trackById(item.trackId);
    if (track == null) {
      return;
    }
    _wantsPlaying = autoplay;
    _resolveAttempts = 0;
    _lastHandlerPositionSec = -1;
    _setStatus(PlaybackStatus.loading);
    _emit(
      _info.copyWith(
        track: track,
        position: Duration.zero,
        duration: track.duration,
        clearError: true,
      ),
    );
    // Instant basic item (title now), enriched async (artist/album/art).
    handler.setCurrentItem(trackToMediaItem(track));
    _publishQueue();
    unawaited(_enrichMediaItem(track));
    events.onStarted(track, item.origin);
    await _resolveAndPlay(track, autoplay: autoplay);
    await _persistAll();
    _maybeRefillRadio(track);
  }

  Future<void> _resolveAndPlay(Track track, {required bool autoplay}) async {
    final provider = _providerFor(track);
    if (provider == null) {
      events.onStopped();
      _itemError(track, 'Unknown provider ${track.providerId}');
      return;
    }
    final quality = track.providerId == 'local'
        ? Quality.original
        : defaultQuality;
    // Every attempt resolves fresh: `resolvePlayable` re-resolves expired
    // stream URLs (the provider-internal `resolveFresh` equivalent), so a
    // retry never replays the failed handle. The resolve itself is
    // `Object`-guarded: a throwing provider (Error, not just Exception)
    // must surface as an item error, never escape `playTrack` as a crash.
    late final Result<MediaHandle, AppError> resolved;
    try {
      resolved = await provider.resolvePlayable(track, quality);
    } on Object catch (e) {
      developer.log(
        'resolve throw provider=${track.providerId} err=${_short(e)}',
        name: 'AURORA_DIAG',
      );
      events.onStopped();
      _itemError(track, 'Resolve failed (${track.providerId}): ${_short(e)}');
      return;
    }
    final handle = resolved.valueOrNull;
    if (handle == null) {
      events.onStopped();
      _itemError(track, resolved.errorOrNull?.message ?? 'Resolve failed');
      return;
    }
    _setStatus(
      handle.isLocalFile ? PlaybackStatus.loading : PlaybackStatus.buffering,
    );
    final diagHost = handle.isLocalFile
        ? 'file'
        : (Uri.tryParse(handle.uri)?.host ?? '?');
    developer.log(
      'engine load kind=${handle.kind.name} host=$diagHost '
      'len=${handle.uri.length}',
      name: 'AURORA_DIAG',
    );
    try {
      await _loadHandle(handle);
      developer.log(
        'engine setSource ok kind=${handle.kind.name} host=$diagHost',
        name: 'AURORA_DIAG',
      );
      if (autoplay) {
        await engine.play();
        developer.log('engine play called host=$diagHost', name: 'AURORA_DIAG');
      } else {
        _setStatus(PlaybackStatus.ready);
      }
    } on Object catch (e) {
      final msg = e.toString();
      final shown = msg.length > 200 ? msg.substring(0, 200) : msg;
      developer.log(
        'engine setSource fail host=$diagHost err=$shown',
        name: 'AURORA_DIAG',
      );
      // Source error (403/404/timeout): fetch to a temp file ONCE, then
      // re-resolve ONCE, then surface.
      if (!handle.isLocalFile && _resolveAttempts < 1) {
        _resolveAttempts++;
        final fallback = streamFallback;
        if (fallback != null) {
          developer.log(
            'stream fallback start vid=${track.sourceTrackId} host=$diagHost',
            name: 'AURORA_DIAG',
          );
          final path = await _tryStreamFallback(track, handle, fallback);
          if (path != null) {
            developer.log(
              'stream fallback file vid=${track.sourceTrackId} '
              'len=${path.length}',
              name: 'AURORA_DIAG',
            );
            try {
              await engine.setSourceFile(path);
              developer.log(
                'stream fallback play vid=${track.sourceTrackId}',
                name: 'AURORA_DIAG',
              );
              if (autoplay) {
                await engine.play();
              } else {
                _setStatus(PlaybackStatus.ready);
              }
              return;
            } on Object catch (fe) {
              final fmsg = fe.toString();
              final fshown =
                  fmsg.length > 120 ? fmsg.substring(0, 120) : fmsg;
              developer.log(
                'stream fallback load fail err=$fshown',
                name: 'AURORA_DIAG',
              );
            }
          } else {
            developer.log(
              'stream fallback null vid=${track.sourceTrackId}',
              name: 'AURORA_DIAG',
            );
          }
        }
        await _resolveAndPlay(track, autoplay: autoplay);
        return;
      }
      events.onStopped();
      // Local vs stream failures surface distinctly so the phone error
      // names the failing lane (the local message was previously generic).
      final prefix = handle.isLocalFile
          ? 'Local playback failed'
          : 'Playback failed';
      _itemError(track, '$prefix: ${_short(e)}');
    }
  }

  /// Upgrades the notification item without blocking the load.
  ///
  /// The basic item is already published by the caller; this resolves the
  /// full metadata (artist/album/artUri) and re-publishes. Stale results
  /// (the user skipped meanwhile) are dropped. Never throws.
  Future<void> _enrichMediaItem(Track track) async {
    late final MediaItem item;
    try {
      final resolver = mediaItemResolver;
      item = resolver != null
          ? await resolver(track)
          : await _defaultMediaItem(track);
    } on Object {
      return;
    }
    if (queue.current?.trackId != track.id || _info.track?.id != track.id) {
      return;
    }
    handler.setCurrentItem(item);
  }

  /// Default item metadata from provider artwork (no app wiring needed).
  ///
  /// `artUri` is the local artwork file URI when the provider holds cached
  /// art on disk, else the online thumbnail URL, else null. Artist/album
  /// stay null here (`Track` carries ids only); the app resolver fills
  /// display names. Never throws.
  Future<MediaItem> _defaultMediaItem(Track track) async {
    Uri? artUri;
    try {
      final provider = _providerFor(track);
      final art = await provider?.artwork(track);
      final resolved = art?.valueOrNull;
      final path = resolved?.localPath;
      final url = resolved?.url;
      if (path != null && path.isNotEmpty) {
        artUri = Uri.file(path);
      } else if (url != null && url.isNotEmpty) {
        artUri = Uri.tryParse(url);
      } else {
        final fallback = trackFallbackThumbnailUrl(track);
        if (fallback != null) {
          artUri = Uri.tryParse(fallback);
        }
      }
    } on Object {
      final fallback = trackFallbackThumbnailUrl(track);
      artUri = fallback != null ? Uri.tryParse(fallback) : null;
    }
    return trackToMediaItem(track, artUri: artUri);
  }

  /// Publishes play-order items for the expanded notification / auto.
  ///
  /// Basic items (id/title); the current item's full metadata lands via
  /// [_enrichMediaItem]. Never throws.
  void _publishQueue() {
    try {
      final out = <MediaItem>[];
      for (final entry in queue.items) {
        final track = queue.trackById(entry.trackId);
        if (track != null) {
          out.add(trackToMediaItem(track));
        }
      }
      handler.setQueueItems(out);
    } on Object {
      // Notification extras never interrupt playback.
    }
  }

  /// Runs [fallback] without ever throwing (null = re-resolve instead).
  Future<String?> _tryStreamFallback(
    Track track,
    MediaHandle handle,
    StreamFallback fallback,
  ) async {
    try {
      return await fallback(track, handle);
    } on Object {
      // Matches the typedef contract ("a throw, treated as null"):
      // Errors (e.g. ArgumentError from a malformed handle URI) must
      // degrade to the re-resolve path, never crash the load.
      return null;
    }
  }

  /// Loads [handle] onto the engine without headers where forbidden.
  ///
  /// `content://`/`file://` local handles go via `setSourceUri` parsed
  /// (header-free): `setSourceFile` would `Uri.file(...)` them and mangle
  /// the scheme. Raw paths keep the `setSourceFile` lane (which itself is
  /// content-aware as defense-in-depth). Streams keep their headers.
  Future<void> _loadHandle(MediaHandle handle) {
    if (handle.isLocalFile && isContentOrFileUri(handle.uri)) {
      return engine.setSourceUri(Uri.parse(handle.uri));
    }
    if (handle.isLocalFile) {
      return engine.setSourceFile(handle.uri);
    }
    return engine.setSourceUri(
      Uri.parse(handle.uri),
      headers: _streamHeaders(handle),
    );
  }

  /// Headers for [AudioEngine.setSourceUri], or null for header-free loads.
  ///
  /// Local files never take headers; neither do `content://`/`file://`
  /// URIs. Provider-authorized streams send the handle's own headers
  /// when non-empty, else [defaultStreamHeaders] (googlevideo 403s
  /// headerless requests on some networks).
  Map<String, String>? _streamHeaders(MediaHandle handle) {
    if (handle.isLocalFile) {
      return null;
    }
    final scheme = Uri.tryParse(handle.uri)?.scheme.toLowerCase();
    if (scheme == 'file' || scheme == 'content') {
      return null;
    }
    return handle.headers.isEmpty ? defaultStreamHeaders : handle.headers;
  }

  /// Resets a terminal error for explicit user intent (`error → loading`).
  ///
  /// Only user-initiated entry points call this (`playTrack`,
  /// `playQueue`, `next`, `previous`, and `resume` via `_loadCurrent`).
  /// Automatic transitions (engine noise while in error/idle) keep going
  /// through [_setStatus] and stay rejected by the guard there.
  void _resetErrorForUserIntent() {
    if (_info.status == PlaybackStatus.error) {
      _setStatus(PlaybackStatus.loading);
    }
  }

  /// Prepares a restored item paused at [startAt] (no event observed).
  Future<void> _prepareLoaded(
    Track track, {
    required bool autoplay,
    required Duration startAt,
  }) async {
    final provider = _providerFor(track);
    if (provider == null) {
      return;
    }
    _setStatus(PlaybackStatus.loading);
    late final Result<MediaHandle, AppError> resolved;
    try {
      resolved = await provider.resolvePlayable(
        track,
        track.providerId == 'local' ? Quality.original : defaultQuality,
      );
    } on Object {
      _setStatus(PlaybackStatus.idle);
      return;
    }
    final handle = resolved.valueOrNull;
    if (handle == null) {
      _setStatus(PlaybackStatus.idle);
      return;
    }
    try {
      await _loadHandle(handle);
      if (startAt > Duration.zero) {
        await engine.seek(startAt);
      }
      _setStatus(autoplay ? PlaybackStatus.playing : PlaybackStatus.paused);
      _emit(
        _info.copyWith(
          track: track,
          position: startAt,
          duration: track.duration,
        ),
      );
      handler.setCurrentItem(trackToMediaItem(track));
      _publishQueue();
      unawaited(_enrichMediaItem(track));
    } on Object {
      // Unplayable restores stay idle; the queue itself survived.
      _setStatus(PlaybackStatus.idle);
    }
  }

  MusicProvider? _providerFor(Track track) {
    try {
      return providers.byId(track.providerId);
    } on Object {
      return null;
    }
  }

  void _itemError(Track track, String message) {
    _wantsPlaying = false;
    _setStatus(PlaybackStatus.error);
    _emit(_info.copyWith(errorMessage: message));
    _publishHandlerState();
    if (!_errors.isClosed) {
      _errors.add(PlaybackError(trackId: track.id, message: message));
    }
    // The queue survives; auto-skip without marking a user skip.
    _skipTimer?.cancel();
    _skipTimer = Timer(missingSkipDelay, () {
      if (queue.step(1) != null) {
        unawaited(_loadCurrent(autoplay: true));
      }
    });
  }

  void _onEngineState(EngineState state) {
    if (state.processing == EngineProcessing.completed) {
      unawaited(_onItemCompleted());
      return;
    }
    if (_info.status == PlaybackStatus.error ||
        _info.status == PlaybackStatus.idle) {
      // Error/idle ignore engine noise until a new load starts.
      _publishHandlerState();
      return;
    }
    if (_info.status == PlaybackStatus.loading ||
        _info.status == PlaybackStatus.buffering) {
      if (state.processing == EngineProcessing.buffering) {
        _setStatus(PlaybackStatus.buffering);
      } else if (state.processing == EngineProcessing.ready) {
        _setStatus(
          state.playing ? PlaybackStatus.playing : PlaybackStatus.ready,
        );
      }
      _publishHandlerState();
      return;
    }
    if (state.playing && _info.status != PlaybackStatus.playing) {
      _setStatus(PlaybackStatus.playing);
      _startPersistTimer();
    } else if (!state.playing &&
        _info.status == PlaybackStatus.playing &&
        state.processing == EngineProcessing.ready) {
      _setStatus(PlaybackStatus.paused);
    }
    _publishHandlerState();
  }

  Future<void> _onItemCompleted() async {
    final track = _info.track;
    final origin = queue.current?.origin ?? PlaySource.queue;
    events.onCompleted();
    if (_info.repeatMode == RepeatMode.one && track != null) {
      // Replay opens a fresh observation (the complete above is kept).
      events.onStarted(track, origin);
      try {
        await engine.seek(Duration.zero);
        await engine.play();
      } on Object catch (e) {
        _itemError(track, 'Replay failed: ${_short(e)}');
        return;
      }
      _wantsPlaying = true;
      _setStatus(PlaybackStatus.playing);
      _touch();
      _startPersistTimer();
      return;
    }
    await next(userInitiated: false);
  }

  void _onPosition(Duration position) {
    if (_info.track == null) {
      return;
    }
    _emit(_info.copyWith(position: position));
    // Notification progress stays live without spamming the platform
    // channel: republish transport state on whole-second ticks only
    // (transitions republish immediately via _setStatus either way).
    if (position.inSeconds != _lastHandlerPositionSec) {
      _lastHandlerPositionSec = position.inSeconds;
      _publishHandlerState();
    }
  }

  void _maybeRefillRadio(Track seed) {
    if (!radioEnabled || radioRefill == null || _refilling) {
      return;
    }
    if (queue.remaining >= 3) {
      return;
    }
    _refilling = true;
    final refill = radioRefill;
    if (refill == null) {
      _refilling = false;
      return;
    }
    unawaited(
      refill(seed)
          .then((tracks) {
            for (final track in tracks.take(15)) {
              queue.addLast(
                track,
                origin: PlaySource.radio,
                now: clock.nowUtc(),
              );
            }
            return _persistAll();
          })
          .catchError((Object _) {})
          .whenComplete(() => _refilling = false),
    );
  }

  void _rotateSessionIfIdle() {
    if (clock.nowUtc().difference(_lastActive) > const Duration(minutes: 30)) {
      final sessionId = AuroraIds.newSessionId();
      events.sessionId = sessionId;
      _emit(_info.copyWith(sessionId: sessionId));
    }
  }

  void _touch() {
    _lastActive = clock.nowUtc();
  }

  void _startPersistTimer() {
    _stopPersistTimer();
    _persistTimer = Timer.periodic(persistInterval, (_) {
      unawaited(_persistAll());
    });
  }

  void _stopPersistTimer() {
    _persistTimer?.cancel();
    _persistTimer = null;
  }

  Future<void> _persistAll() async {
    try {
      final snapshot = queue.snapshot();
      final items = snapshot.items.length > 200
          ? snapshot.items.sublist(0, 200)
          : snapshot.items;
      await store.saveQueue(StoredQueue(items: items, index: snapshot.index));
      await store.saveState(
        StoredPlayback(
          trackId: _info.track?.id,
          positionMs: engine.positionNow.inMilliseconds,
          isPlaying: _info.isPlaying,
          shuffle: _info.shuffle,
          repeatMode: _info.repeatMode.name,
          sessionId: _info.sessionId,
          updatedAt: clock.nowUtc(),
        ),
      );
    } on Exception {
      // Persistence never interrupts playback.
    }
  }

  void _setStatus(PlaybackStatus next) {
    final allowed = _allowedTransitions[_info.status];
    assert(
      allowed == null || allowed.contains(next) || next == _info.status,
      'Illegal playback transition ${_info.status} → $next',
    );
    if (allowed != null && !allowed.contains(next) && next != _info.status) {
      auroraLogger.warning(
        'Illegal playback transition ${_info.status} → $next ignored',
      );
      return;
    }
    _emit(
      _info.copyWith(
        status: next,
        clearError: next != PlaybackStatus.error,
      ),
    );
    _publishHandlerState();
  }

  void _emit(PlaybackInfo info) {
    _info = info;
    if (!_stream.isClosed) {
      _stream.add(info);
    }
  }

  void _publishHandlerState() {
    final processing = switch (_info.status) {
      PlaybackStatus.idle => AudioProcessingState.idle,
      PlaybackStatus.loading => AudioProcessingState.loading,
      PlaybackStatus.buffering => AudioProcessingState.buffering,
      PlaybackStatus.ready => AudioProcessingState.ready,
      PlaybackStatus.playing => AudioProcessingState.ready,
      PlaybackStatus.paused => AudioProcessingState.ready,
      PlaybackStatus.completed => AudioProcessingState.completed,
      PlaybackStatus.error => AudioProcessingState.error,
    };
    handler.publishState(
      processing: processing,
      playing: _info.isPlaying,
      position: engine.positionNow,
      speed: _info.speed,
      queueIndex: queue.currentIndex < 0 ? null : queue.currentIndex,
    );
  }

  RepeatMode _repeatFrom(String? raw) {
    for (final mode in RepeatMode.values) {
      if (mode.name == raw) {
        return mode;
      }
    }
    return RepeatMode.off;
  }

  String _short(Object e) {
    final text = e.toString();
    return text.length > 120 ? '${text.substring(0, 120)}…' : text;
  }
}

/// Visible for testing: allowed status transitions.
@visibleForTesting
Map<PlaybackStatus, Set<PlaybackStatus>> get allowedTransitions =>
    _allowedTransitions;
