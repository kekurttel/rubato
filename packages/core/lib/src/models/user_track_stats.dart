import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_track_stats.freezed.dart';
part 'user_track_stats.g.dart';

/// Incremental per-track listening rollup (spec section 5).
///
/// Maintained by the event sink; read by the heuristic ranker. A missing
/// row means "never observed" and ranks as zeros.
@freezed
abstract class UserTrackStats with _$UserTrackStats {
  /// Creates a stats row.
  const factory UserTrackStats({
    /// Observed track id.
    required String trackId,

    /// Last update time (UTC).
    required DateTime updatedAt,

    /// Started plays (noise-filtered, see section 9).
    @Default(0) int playCount,

    /// Skipped plays.
    @Default(0) int skipCount,

    /// Plays with `completionRatio` >= 0.85.
    @Default(0) int completeCount,

    /// Restarts within 10s of a complete (or replays within 30s).
    @Default(0) int replayCount,

    /// Total heard milliseconds across all plays.
    @Default(0) int totalListenMs,

    /// Last play time (UTC), null when never played.
    DateTime? lastPlayedAt,

    /// -1 dislike, 0 none, 1 like.
    @Default(0) int likeState,

    /// Time-decayed aggregate score.
    @Default(0) double decayedScore,
  }) = _UserTrackStats;

  const UserTrackStats._();

  /// Deserializes stats from JSON.
  factory UserTrackStats.fromJson(Map<String, dynamic> json) =>
      _$UserTrackStatsFromJson(json);

  /// `skipCount / max(playCount, 1)`.
  double get skipRate => skipCount / (playCount < 1 ? 1 : playCount);

  /// `completeCount / max(playCount, 1)`, clamped 0..1.
  double get completionAffinity {
    final ratio = completeCount / (playCount < 1 ? 1 : playCount);
    return ratio.clamp(0, 1).toDouble();
  }

  /// Whether the user disliked this track (excluded from Home mixes).
  bool get isDisliked => likeState == -1;

  /// Whether the user liked this track.
  bool get isLiked => likeState == 1;
}
