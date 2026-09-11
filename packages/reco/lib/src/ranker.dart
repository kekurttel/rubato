import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/score.dart';

/// Bulk ranking input assembled by the app layer (spec 10.7).
///
/// The caller pages events/stats from Drift and hands plain models in;
/// the ranker never touches the database or the network, so it stays
/// safe to run on a background isolate.
final class RankRequest {
  /// Creates a rank request.
  RankRequest({
    required this.tracks,
    required this.profile,
    required this.now,
    this.statsByTrackId = const <String, UserTrackStats>{},
    this.tracksById,
    this.recentPlayCount7d = const <String, int>{},
    TimeOfDayBucket? bucket,
  }) : bucket = bucket ?? now.timeOfDayBucket;

  /// Candidate tracks to score.
  final List<Track> tracks;

  /// Current taste profile.
  final PreferenceProfile profile;

  /// Scoring instant (UTC; tests freeze this).
  final DateTime now;

  /// Observed per-track stats; missing entries rank as zeros.
  final Map<String, UserTrackStats> statsByTrackId;

  /// Track lookup for artist/genre resolution (defaults to [tracks]).
  final Map<String, Track>? tracksById;

  /// Plays per track inside the last 7 days (overplay penalty input).
  final Map<String, int> recentPlayCount7d;

  /// Local-time bucket for the time-context term.
  final TimeOfDayBucket bucket;
}

/// Ranker interface (spec 10.7; `HeuristicRanker` is the only impl).
///
/// Kept so a future on-device model can slot in without touching
/// surfaces, radio, or the snapshot format.
abstract class Ranker {
  /// Scores and sorts [request] best-first (dislikes kept for callers).
  Future<List<ScoredTrack>> rank(RankRequest request);

  /// Scores one track (used by radio refill and similar-tracks).
  ScoredTrack scoreOne(RankRequest request, Track track);
}
