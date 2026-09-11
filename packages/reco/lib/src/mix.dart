import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/diversity.dart';
import 'package:aurora_reco/src/score.dart';

/// Mix slicer: exploitation / adjacent / exploration (spec 10.6).
///
/// Rates come from the profile so Settings can expose "more
/// discovery" later, and must always sum to 1.0 ([PreferenceProfile]
/// `ratesValid`). Cold start (fewer than 15 stored events) widens to
/// 40/30/30 so thin histories still surface variety.
///
/// Slice semantics:
/// - exploitation: top MMR-ranked tracks.
/// - adjacent: score in [p40, p75], sharing a genre with a top
///   profile genre or an artist with an exploitation pick, low
///   play counts (familiar but fresh).
/// - exploration: unplayed pool-G tracks, excluding skipRate > 0.5.
///
/// The concatenated slices run through [Diversity.mmr] once more so
/// the final order keeps MMR spacing and the hard constraints hold
/// (spec T9) while slice counts stay exact (spec T8).
abstract final class MixSlicer {
  /// Stored-event count below which cold-start rates apply.
  static const int coldStartEvents = 15;

  /// Cold-start exploitation share.
  static const double coldExploitation = 0.40;

  /// Cold-start adjacent share.
  static const double coldAdjacent = 0.30;

  /// Cold-start exploration share.
  static const double coldExploration = 0.30;

  /// Splits [ranked] (best-first) into an N-track mixed queue.
  static List<ScoredTrack> slice({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required Map<String, UserTrackStats> statsByTrackId,
    required PreferenceProfile profile,
    required List<Track> explorationPool,
    required int count,
    required int storedEventCount,
  }) {
    if (ranked.isEmpty || count <= 0) {
      return const [];
    }
    final cold = storedEventCount < coldStartEvents;
    final exploitRate = cold ? coldExploitation : profile.exploitationRate;
    final adjacentRate = cold ? coldAdjacent : profile.adjacentRate;
    final exploitCount = (count * exploitRate).round();
    var adjacentCount = (count * adjacentRate).round();
    var exploreCount = count - exploitCount - adjacentCount;
    if (exploreCount < 0) {
      exploreCount = 0;
      adjacentCount = count - exploitCount;
    }

    final diversified = Diversity.mmr(
      ranked: ranked,
      byId: byId,
      statsByTrackId: statsByTrackId,
      penalty: profile.consecutiveArtistPenalty,
    );
    final exploitPicks = diversified.length > exploitCount
        ? diversified.sublist(0, exploitCount)
        : [...diversified];

    final adjacent = _adjacentSlice(
      ranked: ranked,
      byId: byId,
      statsByTrackId: statsByTrackId,
      profile: profile,
      exploitPicks: exploitPicks,
      exclude: {for (final pick in exploitPicks) pick.trackId},
      count: adjacentCount,
    );

    final explore = _explorationSlice(
      ranked: ranked,
      byId: byId,
      statsByTrackId: statsByTrackId,
      pool: explorationPool,
      exclude: {
        for (final pick in exploitPicks) pick.trackId,
        for (final pick in adjacent) pick.trackId,
      },
      count: exploreCount,
    );

    // Top-up from the ranked tail when a slice runs short so output
    // length stays exact on thin catalogs.
    final used = <String>{
      for (final pick in exploitPicks) pick.trackId,
      for (final pick in adjacent) pick.trackId,
      for (final pick in explore) pick.trackId,
    };
    final topUp = <ScoredTrack>[];
    if (used.length < count) {
      for (final item in diversified) {
        if (used.length >= count) {
          break;
        }
        if (used.add(item.trackId)) {
          topUp.add(item);
        }
      }
    }

    final combined = <ScoredTrack>[
      for (final pick in exploitPicks) _asSlice(pick, MixSlice.exploitation),
      for (final pick in adjacent) _asSlice(pick, MixSlice.adjacent),
      for (final pick in explore) _asSlice(pick, MixSlice.exploration),
      ...topUp,
    ].take(count).toList();

    // Final diversity pass preserves slice counts (it only reorders).
    final reordered = Diversity.mmr(
      ranked: combined,
      byId: byId,
      statsByTrackId: statsByTrackId,
      penalty: profile.consecutiveArtistPenalty,
    );
    return reordered.length > count ? reordered.sublist(0, count) : reordered;
  }

  static List<ScoredTrack> _adjacentSlice({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required Map<String, UserTrackStats> statsByTrackId,
    required PreferenceProfile profile,
    required List<ScoredTrack> exploitPicks,
    required Set<String> exclude,
    required int count,
  }) {
    if (count <= 0 || ranked.isEmpty) {
      return const [];
    }
    final scores = <double>[for (final item in ranked) item.score]..sort();
    final p40 = _percentile(scores, 0.40);
    final p75 = _percentile(scores, 0.75);
    final topGenres = _topKeys(profile.genreWeights, 3).toSet();
    final exploitArtists = <String>{
      for (final pick in exploitPicks)
        ...(byId[pick.trackId]?.artistIds ?? const <String>[]),
    };
    final picks = <ScoredTrack>[];
    for (final item in ranked) {
      if (picks.length >= count) {
        break;
      }
      if (exclude.contains(item.trackId)) {
        continue;
      }
      if (item.score < p40 || item.score > p75) {
        continue;
      }
      final track = byId[item.trackId];
      if (track == null) {
        continue;
      }
      final stats = statsByTrackId[item.trackId];
      if ((stats?.playCount ?? 0) > 2) {
        continue;
      }
      final sharesGenre = track.genreIds.any(topGenres.contains);
      final sharesArtist = track.artistIds.any(exploitArtists.contains);
      if (!sharesGenre && !sharesArtist) {
        continue;
      }
      picks.add(item);
    }
    // Fallback: relax the band before giving up the slice.
    if (picks.length < count) {
      for (final item in ranked) {
        if (picks.length >= count) {
          break;
        }
        if (exclude.contains(item.trackId) ||
            picks.any((pick) => pick.trackId == item.trackId)) {
          continue;
        }
        final track = byId[item.trackId];
        if (track == null) {
          continue;
        }
        if ((statsByTrackId[item.trackId]?.playCount ?? 0) > 2) {
          continue;
        }
        picks.add(item);
      }
    }
    return picks;
  }

  static List<ScoredTrack> _explorationSlice({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required Map<String, UserTrackStats> statsByTrackId,
    required List<Track> pool,
    required Set<String> exclude,
    required int count,
  }) {
    if (count <= 0) {
      return const [];
    }
    final rankById = <String, ScoredTrack>{
      for (final item in ranked) item.trackId: item,
    };
    final picks = <ScoredTrack>[];
    for (final track in pool) {
      if (picks.length >= count) {
        break;
      }
      if (exclude.contains(track.id)) {
        continue;
      }
      final stats = statsByTrackId[track.id];
      if (stats != null && stats.skipRate > 0.5) {
        continue;
      }
      final scored = rankById[track.id];
      if (scored != null) {
        picks.add(scored);
      } else {
        picks.add(
          ScoredTrack(
            trackId: track.id,
            score: 0,
            reasons: const [ScoreReason('cold', 0)],
          ),
        );
      }
    }
    return picks;
  }

  static ScoredTrack _asSlice(ScoredTrack item, MixSlice slice) {
    if (item.slice == slice) {
      return item;
    }
    return ScoredTrack(
      trackId: item.trackId,
      score: item.score,
      reasons: [
        ...item.reasons,
        const ScoreReason('slice', 0),
      ],
      slice: slice,
    );
  }

  static double _percentile(List<double> sorted, double fraction) {
    if (sorted.isEmpty) {
      return 0;
    }
    final index = ((sorted.length - 1) * fraction).round().clamp(
      0,
      sorted.length - 1,
    );
    return sorted[index];
  }

  static List<String> _topKeys(Map<String, double> weights, int count) {
    final entries = weights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final entry in entries.take(count)) entry.key];
  }
}
