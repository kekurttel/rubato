import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/score.dart';

/// Diversity: greedy MMR plus hard adjacency constraints (spec 10.5).
///
/// `similarity(i, j) = 0.6` same primary artist + `0.3` same album +
/// `0.2` genre Jaccard, clamped 0..1. Greedy MMR picks
/// `argmax λ·score − (1−λ)·maxSimilarityToSelected` with λ = 0.70.
///
/// Hard constraints (enforced while picking, deferred candidates get
/// a second pass so output length is preserved whenever feasible):
/// max 2 consecutive same artist, max 3 same-album tracks per
/// rolling window of 20, and dislikes excluded (unless
/// `includeDisliked` for the artist-page path).
abstract final class Diversity {
  /// MMR trade-off between relevance and novelty (spec 10.5).
  static const double lambda = 0.70;

  /// Same-primary-artist similarity component.
  static const double sameArtist = 0.6;

  /// Same-album similarity component.
  static const double sameAlbum = 0.3;

  /// Genre-Jaccard similarity component.
  static const double genreJaccardWeight = 0.2;

  /// Max consecutive tracks sharing a primary artist.
  static const int maxConsecutiveArtist = 2;

  /// Max tracks from one album inside any rolling window of 20.
  static const int maxSameAlbumPerWindow = 3;

  /// Rolling window length for the album constraint.
  static const int albumWindow = 20;

  /// Pairwise similarity in 0..1 (spec 10.5).
  static double similarity(Track a, Track b) {
    var value = 0.0;
    if (a.artistIds.isNotEmpty &&
        b.artistIds.isNotEmpty &&
        a.artistIds.first == b.artistIds.first) {
      value += sameArtist;
    }
    if (a.albumId != null && a.albumId == b.albumId) {
      value += sameAlbum;
    }
    value += genreJaccardWeight * _jaccard(a.genreIds, b.genreIds);
    return value.clamp(0, 1).toDouble();
  }

  /// Greedy MMR ordering of [ranked] (best-first input) to [count].
  ///
  /// [byId] resolves ids for similarity; unknown ids fall back to
  /// score order. Dislikes are dropped unless [includeDisliked].
  static List<ScoredTrack> mmr({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required Map<String, UserTrackStats> statsByTrackId,
    int? count,
    bool includeDisliked = false,
    double penalty = 0,
  }) {
    final pool = <ScoredTrack>[
      for (final item in ranked)
        if (includeDisliked ||
            !(statsByTrackId[item.trackId]?.isDisliked ?? false))
          item,
    ];
    final target = count == null || count > pool.length ? pool.length : count;
    final selected = <ScoredTrack>[];
    final remaining = [...pool];

    while (selected.length < target && remaining.isNotEmpty) {
      // MMR value of every remainder against the current selection.
      final values = <double>[
        for (final candidate in remaining)
          _mmrValue(candidate, selected, byId, penalty),
      ];
      // Best-valued first; take the first that keeps the hard
      // constraints. Only a degenerate catalog (nothing fits) bends
      // a constraint, so T9-style guarantees hold whenever the
      // catalog allows them.
      final order = <int>[
        for (var i = 0; i < remaining.length; i++) i,
      ]..sort((a, b) => values[b].compareTo(values[a]));
      var placed = false;
      for (final index in order) {
        if (!_violates(remaining[index], selected, byId)) {
          selected.add(remaining.removeAt(index));
          placed = true;
          break;
        }
      }
      if (!placed) {
        selected.add(remaining.removeAt(order.first));
      }
    }
    return selected;
  }

  static double _mmrValue(
    ScoredTrack candidate,
    List<ScoredTrack> selected,
    Map<String, Track> byId,
    double penalty,
  ) {
    var maxSim = 0.0;
    final track = byId[candidate.trackId];
    if (track != null) {
      for (final picked in selected) {
        final other = byId[picked.trackId];
        if (other == null) {
          continue;
        }
        final sim = similarity(track, other);
        if (sim > maxSim) {
          maxSim = sim;
        }
      }
    }
    // Consecutive-artist penalty (profile-tunable, spec 10.2).
    var consecutive = 0.0;
    if (penalty > 0 && track != null && selected.isNotEmpty) {
      final last = byId[selected.last.trackId];
      if (last != null &&
          last.artistIds.isNotEmpty &&
          track.artistIds.isNotEmpty &&
          last.artistIds.first == track.artistIds.first) {
        consecutive = penalty;
      }
    }
    return lambda * candidate.score - (1 - lambda) * maxSim - consecutive;
  }

  static bool _violates(
    ScoredTrack candidate,
    List<ScoredTrack> selected,
    Map<String, Track> byId,
  ) {
    final track = byId[candidate.trackId];
    if (track == null) {
      return false;
    }
    if (track.artistIds.isNotEmpty && selected.length >= 2) {
      final primary = track.artistIds.first;
      var run = 0;
      for (var i = selected.length - 1; i >= 0; i--) {
        final prev = byId[selected[i].trackId];
        if (prev == null ||
            prev.artistIds.isEmpty ||
            prev.artistIds.first != primary) {
          break;
        }
        run++;
      }
      if (run >= maxConsecutiveArtist) {
        return true;
      }
    }
    if (track.albumId != null) {
      final window = selected.length >= albumWindow
          ? selected.sublist(selected.length - albumWindow)
          : selected;
      var sameAlbumCount = 0;
      for (final picked in window) {
        if (byId[picked.trackId]?.albumId == track.albumId) {
          sameAlbumCount++;
        }
      }
      if (sameAlbumCount >= maxSameAlbumPerWindow) {
        return true;
      }
    }
    return false;
  }

  static double _jaccard(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) {
      return 0;
    }
    final setA = a.toSet();
    final setB = b.toSet();
    final intersection = setA.intersection(setB).length;
    if (intersection == 0) {
      return 0;
    }
    return intersection / setA.union(setB).length;
  }
}
