import 'package:aurora_core/aurora_core.dart';

/// Playback source badge for the Now Playing header (spec 13.8).
enum SourceBadge {
  /// Verified on-disk file.
  local,

  /// Provider-authorized stream URL (no file written).
  stream,

  /// Persisted download.
  downloaded,
}

/// Display label for a [SourceBadge].
String sourceBadgeLabel(SourceBadge badge) => switch (badge) {
  SourceBadge.local => 'Local',
  SourceBadge.stream => 'Stream',
  SourceBadge.downloaded => 'Downloaded',
};

/// Repeat setting mirrored from the playback controller.
enum RepeatSetting {
  /// Stop at the end of the queue.
  off,

  /// Loop the current track.
  one,

  /// Loop the whole queue.
  all,
}

/// Immutable Now Playing frame (mini-player reads a subset of this).
final class NowPlayingInfo {
  /// Creates a frame.
  const NowPlayingInfo({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.shuffle,
    required this.repeat,
    required this.likeState,
    required this.badge,
    required this.useStream,
    required this.radioEnabled,
    this.track,
    this.qualityLabel,
    this.downloadState,
    this.downloadProgress = 0,
    this.queue = const <Track>[],
    this.currentIndex = 0,
    this.lyrics,
    this.volume = 1,
  });

  /// Empty frame (nothing loaded yet).
  const NowPlayingInfo.idle()
    : this(
        isPlaying: false,
        position: Duration.zero,
        duration: Duration.zero,
        shuffle: false,
        repeat: RepeatSetting.off,
        likeState: 0,
        badge: SourceBadge.local,
        useStream: false,
        radioEnabled: false,
        volume: 1,
      );

  /// Current track (null when idle).
  final Track? track;

  /// Whether audio is audible.
  final bool isPlaying;

  /// Current position.
  final Duration position;

  /// Current item length.
  final Duration duration;

  /// Shuffle enabled.
  final bool shuffle;

  /// Repeat behavior.
  final RepeatSetting repeat;

  /// Like state (-1/0/1).
  final int likeState;

  /// Source badge.
  final SourceBadge badge;

  /// Quality/bitrate label next to the badge.
  final String? qualityLabel;

  /// Whether the stream URL is active (vs the local file).
  final bool useStream;

  /// Download job state (null hides the button when not applicable).
  final DownloadState? downloadState;

  /// Download progress 0..1.
  final double downloadProgress;

  /// Upcoming queue (current first) for the queue sheet.
  final List<Track> queue;

  /// Index of the current item inside [queue].
  final int currentIndex;

  /// Infinite-radio refill enabled.
  final bool radioEnabled;

  /// Local LRC / embedded lyrics (null hides the lyrics area; web
  /// lyrics are never fetched per spec 13.8).
  final String? lyrics;

  /// Output volume 0..1 (drives the desktop player-bar slider).
  final double volume;

  /// 0..1 playback progress for sliders and the mini-player bar.
  double get progress {
    if (duration.inMilliseconds <= 0) {
      return 0;
    }
    return (position.inMilliseconds / duration.inMilliseconds)
        .clamp(0, 1)
        .toDouble();
  }

  /// Remaining time label source.
  Duration get remaining => duration - position;
}

/// Now Playing boundary behind the player surfaces (spec 13.8/13.9).
///
/// The app lane implements this over the playback controller,
/// download queue, and lyrics sidecars. Widgets stay declarative.
abstract class NowPlayingService {
  /// Live player frames.
  Stream<NowPlayingInfo> watch();

  /// Toggles play/pause.
  Future<void> toggle();

  /// User-initiated skip (writes a skip event).
  Future<void> next();

  /// Restarts when position > 3s, else steps back.
  Future<void> previous();

  /// Seeks (streams use range requests).
  Future<void> seek(Duration position);

  /// Sets the output volume 0..1 (desktop player bar).
  Future<void> setVolume(double volume);

  /// Enables/disables shuffle.
  Future<void> setShuffle({required bool enabled});

  /// Cycles repeat off → one → all.
  Future<void> cycleRepeat();

  /// Writes the like state for the current track.
  Future<void> setLike(int likeState);

  /// Switches between stream URL and local file when both exist.
  Future<void> setUseStream({required bool useStream});

  /// Enqueues a persistent download at [quality].
  Future<void> download(Quality quality);

  /// Moves a queue entry (queue-sheet reorder).
  Future<void> reorderQueue(int from, int to);

  /// Toggles infinite-radio refill.
  Future<void> setRadioEnabled({required bool enabled});

  /// Display artist line for [track].
  String artistLine(Track track);
}
