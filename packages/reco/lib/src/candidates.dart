import 'dart:math' as math;

import 'package:aurora_core/aurora_core.dart';

/// Candidate generation input assembled by the app layer (spec 10.4).
final class CandidateInput {
  /// Creates candidate input.
  const CandidateInput({
    required this.allTracks,
    required this.profile,
    this.statsByTrackId = const <String, UserTrackStats>{},
    this.recentTrackIds = const <String>{},
    this.similarIds = const <String>[],
    this.likedArtistIds = const <String>{},
    this.completedAlbumIds = const <String>{},
    this.now,
  });

  /// Full on-device catalog (library + downloads + cached adds).
  final List<Track> allTracks;

  /// Current taste profile (cheap pre-score reads its artist map).
  final PreferenceProfile profile;

  /// Observed stats; missing entries count as unplayed.
  final Map<String, UserTrackStats> statsByTrackId;

  /// Distinct track ids heard in the last 90 days (source C).
  final Set<String> recentTrackIds;

  /// Similar ids already in `metadata_cache` (source F, offline-safe).
  final List<String> similarIds;

  /// Artists with a liked track (source D).
  final Set<String> likedArtistIds;

  /// Albums the user completed >= 50% (source E).
  final Set<String> completedAlbumIds;

  /// Scoring instant (reserved for future recency pre-scoring).
  final DateTime? now;
}

/// Candidate generation: union of sources A–G, capped at 800 (10.4).
///
/// Cheap pre-score is `artistAff + like bonus`, deliberately weaker
/// than the full ranker — it only trims the union down to a size the
/// isolate can score well under budget. Source G (exploration) is
/// also returned separately so the mix slicer can draw from it.
abstract final class CandidateGeneration {
  /// Hard cap on ranked candidates (spec 10.4).
  static const int maxCandidates = 800;

  /// Exploration pool size drawn from unplayed tracks (source G).
  static const int explorationPoolSize = 80;

  /// Builds the capped candidate list plus the exploration pool.
  static CandidateSet generate(CandidateInput input) {
    final byId = <String, Track>{
      for (final track in input.allTracks) track.id: track,
    };
    final union = <String>{};

    void addIfPresent(String id) {
      if (byId.containsKey(id)) {
        union.add(id);
      }
    }

    for (final track in input.allTracks) {
      final stats = input.statsByTrackId[track.id];
      // A. all downloaded tracks.
      if (track.isDownloaded) {
        union.add(track.id);
      }
      // B. all library/local tracks.
      if (track.hasLocalFile || track.providerId == 'local') {
        union.add(track.id);
      }
      // G. unplayed tracks are eligible for the exploration pool;
      // membership in the union is decided below by genre band.
      if ((stats?.playCount ?? 0) == 0) {
        union.add(track.id);
      }
      // D. tracks of liked artists already in the DB.
      if (track.artistIds.any(input.likedArtistIds.contains)) {
        union.add(track.id);
      }
      // E. other tracks on completed albums.
      if (track.albumId != null &&
          input.completedAlbumIds.contains(track.albumId)) {
        union.add(track.id);
      }
    }
    // C. last-90-days distinct tracks.
    input.recentTrackIds.forEach(addIfPresent);
    // F. cached similar ids (never fetched here — offline-safe).
    input.similarIds.forEach(addIfPresent);

    // Exploration pool first (deterministic order): unplayed tracks
    // whose best genre sits in the bottom-or-mid profile band, so
    // exploration actually explores instead of re-serving favorites.
    final exploration = _explorationPool(
      input.allTracks,
      input.statsByTrackId,
      input.profile,
    );

    // Cheap pre-score: mean artist affinity + like bonus.
    final scored = <String>[...union]
      ..sort((a, b) {
        final scoreB = _cheapScore(b, byId, input);
        final scoreA = _cheapScore(a, byId, input);
        return scoreB.compareTo(scoreA);
      });
    final capped = scored.length > maxCandidates
        ? scored.sublist(0, maxCandidates)
        : scored;
    return CandidateSet(
      candidates: [for (final id in capped) byId[id]!],
      explorationPool: exploration,
    );
  }

  static double _cheapScore(
    String id,
    Map<String, Track> byId,
    CandidateInput input,
  ) {
    final track = byId[id]!;
    var sum = 0.0;
    for (final artist in track.artistIds) {
      sum += input.profile.artistWeights[artist] ?? 0;
    }
    final artistAff = track.artistIds.isEmpty
        ? 0.0
        : sum / track.artistIds.length;
    final like = (input.statsByTrackId[id]?.likeState ?? 0) == 1 ? 1.0 : 0.0;
    return artistAff + like;
  }

  static List<Track> _explorationPool(
    List<Track> allTracks,
    Map<String, UserTrackStats> stats,
    PreferenceProfile profile,
  ) {
    final unplayed = <Track>[
      for (final track in allTracks)
        if ((stats[track.id]?.playCount ?? 0) == 0) track,
    ];
    if (unplayed.isEmpty) {
      return const [];
    }
    // Bottom-or-mid band: best genre weight below 0.75 of the max.
    // Profile maps are max-normalized, so 0.75 splits head from rest.
    final eligible = <Track>[
      for (final track in unplayed)
        if (_bestGenreWeight(track, profile) < 0.75) track,
    ];
    final pool = eligible.isEmpty ? unplayed : eligible;
    // Deterministic shuffle so snapshots are reproducible in tests.
    final random = math.Random(42);
    final shuffled = [...pool]..shuffle(random);
    return shuffled.length > explorationPoolSize
        ? shuffled.sublist(0, explorationPoolSize)
        : shuffled;
  }

  static double _bestGenreWeight(Track track, PreferenceProfile profile) {
    var best = 0.0;
    for (final genre in track.genreIds) {
      final weight = profile.genreWeights[genre] ?? 0;
      if (weight > best) {
        best = weight;
      }
    }
    return best;
  }
}

/// Capped candidates plus the reserved exploration pool.
final class CandidateSet {
  /// Creates a candidate set.
  const CandidateSet({
    required this.candidates,
    required this.explorationPool,
  });

  /// Ranker input (union of A–G, at most 800).
  final List<Track> candidates;

  /// Source-G pool reserved for the exploration slice.
  final List<Track> explorationPool;
}
