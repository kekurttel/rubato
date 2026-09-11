import 'package:aurora_core/aurora_core.dart';
import 'package:meta/meta.dart';

/// Player lifecycle (spec section 8).
///
/// Legal flow: `idle → loading → buffering → ready → playing ⇄ paused`,
/// `playing → completed`, any non-idle `→ error` (stream 403/404/timeout,
/// missing file, codec) or `→ idle` on stop. `playing` without a loaded
/// media handle is illegal and asserted in debug builds.
enum PlaybackStatus {
  /// Nothing loaded.
  idle,

  /// Resolving via the provider (`resolvePlayable`) or opening a file.
  loading,

  /// Streaming bytes (`just_audio` buffering) — the Stream-mode state.
  buffering,

  /// Media ready, not yet playing.
  ready,

  /// Audible.
  playing,

  /// Suspended by the user, focus loss, or headset disconnect.
  paused,

  /// Natural end of the current item (auto-advance unless repeat-one).
  completed,

  /// Terminal failure for the current item (queue survives; UI snacks).
  ///
  /// Escape rule: explicit user intent (`playTrack`, `playQueue`, `next`,
  /// `previous`, `resume`) always resets `error → loading` for a fresh
  /// resolve; automatic transitions out of error (engine noise such as a
  /// late `playing` frame) stay rejected by the controller guard, so a
  /// failed item can never silently resume itself.
  error,
}

/// Repeat behavior (`playback_state.repeat_mode` stores the name).
enum RepeatMode {
  /// Stop at the end of the queue.
  off,

  /// Loop the current track.
  one,

  /// Loop the whole queue.
  all,
}

/// Origin + surroundings for `playTrack` (spec section 8).
@immutable
final class QueueContext {
  /// Creates a queue context.
  const QueueContext({required this.origin, this.upcoming = const <Track>[]});

  /// Where playback originated (recorded on items + events).
  final PlaySource origin;

  /// Tracks enqueued after the seed (radio appends more later).
  final List<Track> upcoming;
}

/// Immutable frame of player state (mini-player + notification read this).
@immutable
final class PlaybackInfo {
  /// Creates a state frame.
  const PlaybackInfo({
    required this.status,
    required this.position,
    required this.duration,
    required this.shuffle,
    required this.repeatMode,
    required this.volume,
    required this.speed,
    required this.sessionId,
    this.track,
    this.errorMessage,
  });

  /// Empty initial frame (status idle, session minted by the controller).
  factory PlaybackInfo.initial(String sessionId) => PlaybackInfo(
    status: PlaybackStatus.idle,
    position: Duration.zero,
    duration: Duration.zero,
    shuffle: false,
    repeatMode: RepeatMode.off,
    volume: 1,
    speed: 1,
    sessionId: sessionId,
  );

  /// Lifecycle state.
  final PlaybackStatus status;

  /// Current position.
  final Duration position;

  /// Current item length (zero when unknown).
  final Duration duration;

  /// Shuffle enabled.
  final bool shuffle;

  /// Repeat behavior.
  final RepeatMode repeatMode;

  /// Volume 0..1.
  final double volume;

  /// Speed multiplier (1.0 until Phase 5).
  final double speed;

  /// Playback session id (uuid, rotated on cold start / 30 min idle).
  final String sessionId;

  /// Current track, if any is loaded.
  final Track? track;

  /// Last error message, when [status] is [PlaybackStatus.error].
  final String? errorMessage;

  /// Whether audio is audible.
  bool get isPlaying => status == PlaybackStatus.playing;

  /// Copies with selective overrides.
  PlaybackInfo copyWith({
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    bool? shuffle,
    RepeatMode? repeatMode,
    double? volume,
    double? speed,
    String? sessionId,
    Track? track,
    String? errorMessage,
    bool clearTrack = false,
    bool clearError = false,
  }) => PlaybackInfo(
    status: status ?? this.status,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    shuffle: shuffle ?? this.shuffle,
    repeatMode: repeatMode ?? this.repeatMode,
    volume: volume ?? this.volume,
    speed: speed ?? this.speed,
    sessionId: sessionId ?? this.sessionId,
    track: clearTrack ? null : (track ?? this.track),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

/// Error surfaced to the UI (snackbar) when an item fails.
@immutable
final class PlaybackError {
  /// Creates an error frame.
  const PlaybackError({required this.trackId, required this.message});

  /// Failing track id.
  final String trackId;

  /// Log-safe message (no raw paths).
  final String message;
}
