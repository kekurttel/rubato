import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/diversity.dart';
import 'package:aurora_reco/src/heuristic_ranker.dart';
import 'package:aurora_reco/src/ranker.dart';
import 'package:aurora_reco/src/score.dart';
import 'package:aurora_reco/src/vector.dart';

/// Infinite radio over a seed track (spec 10.8).
///
/// Seeds 25 tracks, then 15 more whenever fewer than 3 remain (the
/// playback controller's refill hook calls back into the app layer,
/// which delegates here — playback never imports reco). Radio blends
/// cosine similarity to the seed (60%) with the heuristic score
/// (40%) so stations stay on-theme without looping the same artist.
/// Skips written with `source = radio` already carry the heavier
/// skip penalty from feature extraction.
abstract final class RecoRadio {
  /// Seed queue length for a fresh station.
  static const int seedCount = 25;

  /// Refill size when fewer than [refillThreshold] remain.
  static const int refillCount = 15;

  /// Remaining-track threshold that triggers a refill.
  static const int refillThreshold = 3;

  /// Generates [count] station tracks for [seed].
  ///
  /// [recentIds] (already-queued or just-played ids) are excluded so
  /// refills never repeat the seed run. Dislikes are always excluded.
  static List<ScoredTrack> generate({
    required Track seed,
    required List<Track> candidates,
    required RankRequest request,
    Set<String> recentIds = const <String>{},
    int count = seedCount,
  }) {
    const ranker = HeuristicRanker();
    final topArtists = _topArtists(request.profile, 128);
    final seedVector = TrackVector.build(seed, topArtists);
    final scored = <ScoredTrack>[];
    for (final track in candidates) {
      if (track.id == seed.id || recentIds.contains(track.id)) {
        continue;
      }
      if (request.statsByTrackId[track.id]?.isDisliked ?? false) {
        continue;
      }
      final heuristic = ranker.scoreOne(request, track);
      final similarity = TrackVector.cosine(
        seedVector,
        TrackVector.build(track, topArtists),
      );
      final blended = 0.6 * similarity + 0.4 * heuristic.score;
      scored.add(
        ScoredTrack(
          trackId: track.id,
          score: blended.clamp(0, 1).toDouble(),
          reasons: [
            ScoreReason('similar', similarity),
            ScoreReason('radio', heuristic.score),
            ...heuristic.reasons.take(1),
          ],
        ),
      );
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    final byId = <String, Track>{
      for (final track in candidates) track.id: track,
    };
    return Diversity.mmr(
      ranked: scored,
      byId: byId,
      statsByTrackId: request.statsByTrackId,
      count: count,
      penalty: request.profile.consecutiveArtistPenalty,
    );
  }

  static List<String> _topArtists(PreferenceProfile profile, int count) {
    final entries = profile.artistWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final entry in entries.take(count)) entry.key];
  }
}
