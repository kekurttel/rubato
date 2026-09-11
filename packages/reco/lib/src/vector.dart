import 'dart:math' as math;

import 'package:aurora_core/aurora_core.dart';

/// Handcrafted 32-d track vector, no neural net (spec 10.9).
///
/// Layout: dims 0–15 hashed artist bag (top 128 profile artists),
/// 16–23 genre one-hot over 8 known genres + other, 24–25 year
/// bucket, 26 duration bucket, 27 explicit flag, 28–31 reserved 0.
/// Cosine similarity powers "similar tracks" and radio seeding.
abstract final class TrackVector {
  /// Vector dimensionality (spec-fixed).
  static const int dimensions = 32;

  /// Genre slots for dims 16–23 (index 8 is "other").
  static const List<String> genreSlots = <String>[
    'metal',
    'ambient',
    'electronic',
    'jazz',
    'hiphop',
    'folk',
    'indie',
    'classical',
  ];

  /// Builds the 32-d vector for [track].
  ///
  /// [topArtists] is the profile's top-128 artist list (defines the
  /// artist hash space); unknown artists still hash deterministically
  /// into dims 0–15 so cold tracks compare sanely.
  static List<double> build(Track track, List<String> topArtists) {
    final vector = List<double>.filled(dimensions, 0);
    final rank = <String, int>{
      for (var i = 0; i < topArtists.length; i++) topArtists[i]: i,
    };
    for (final artist in track.artistIds) {
      final slot = (rank[artist] ?? artist.hashCode).abs() % 16;
      vector[slot] += 1;
    }
    var other = 0.0;
    for (final genre in track.genreIds) {
      final slot = genreSlots.indexOf(genre.toLowerCase());
      if (slot < 0) {
        other = 1;
      } else {
        vector[16 + slot] = 1;
      }
    }
    if (track.genreIds.isEmpty) {
      other = 1;
    }
    vector[24] = _yearDim(track.year);
    vector[25] = 1 - vector[24];
    vector[26] = _durationDim(track.durationMs);
    vector[27] = track.explicit ? 1 : 0;
    if (other > 0 && !_hasGenreBit(vector)) {
      vector[23] = 1;
    }
    return vector;
  }

  /// Cosine similarity in 0..1 (0 when either vector is all zeros).
  static double cosine(List<double> a, List<double> b) {
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < dimensions; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA <= 0 || normB <= 0) {
      return 0;
    }
    return (dot / (math.sqrt(normA) * math.sqrt(normB))).clamp(0, 1).toDouble();
  }

  /// Ranks [candidates] by cosine similarity to [seed] (excludes seed).
  static List<SimilarTrack> similarTo({
    required Track seed,
    required List<Track> candidates,
    required List<String> topArtists,
    int count = 12,
  }) {
    final seedVector = build(seed, topArtists);
    final scored = <SimilarTrack>[];
    for (final track in candidates) {
      if (track.id == seed.id) {
        continue;
      }
      scored.add(
        SimilarTrack(
          trackId: track.id,
          similarity: cosine(seedVector, build(track, topArtists)),
        ),
      );
    }
    scored.sort((a, b) => b.similarity.compareTo(a.similarity));
    return scored.length > count ? scored.sublist(0, count) : scored;
  }

  static bool _hasGenreBit(List<double> vector) {
    for (var i = 16; i < 24; i++) {
      if (vector[i] != 0) {
        return true;
      }
    }
    return false;
  }

  // Year bucket packed into dim 24 (dim 25 is its complement so
  // same-era tracks share two dims, different eras share none).
  static double _yearDim(int? year) {
    if (year == null) {
      return 0.5;
    }
    if (year < 1990) {
      return 0;
    }
    if (year < 2000) {
      return 0.25;
    }
    if (year < 2010) {
      return 0.5;
    }
    if (year < 2020) {
      return 0.75;
    }
    return 1;
  }

  // Duration bucket: short (<2m) 0, standard 0.5, long (>6m) 1.
  static double _durationDim(int durationMs) {
    if (durationMs < 120000) {
      return 0;
    }
    if (durationMs > 360000) {
      return 1;
    }
    return 0.5;
  }
}

/// A track id with its cosine similarity to a seed track.
final class SimilarTrack {
  /// Creates a similar-track hit.
  const SimilarTrack({required this.trackId, required this.similarity});

  /// Similar track id.
  final String trackId;

  /// Cosine similarity in 0..1.
  final double similarity;
}
