import 'package:meta/meta.dart';

/// One human-readable "Why this track" contribution (spec 10.7).
///
/// [key] is a stable machine key (`artist`, `genre`, `completion`,
/// `recency`, `like`, `time`, `replay`, `intent`, `skip`, `overplay`,
/// `slice`, `similar`, `radio`, `cold`, `no_signal`); [contribution]
/// is the signed score delta in raw-score units.
@immutable
final class ScoreReason {
  /// Creates a reason.
  const ScoreReason(this.key, this.contribution);

  /// Stable machine key for the contributing factor.
  final String key;

  /// Signed contribution to the raw score (negative for penalties).
  final double contribution;

  /// Short display label for the Why-panel sheet.
  String get label => switch (key) {
    'artist' => 'Matches your top artists',
    'genre' => 'Matches your top genres',
    'completion' => 'You usually finish it',
    'recency' => 'Recently played',
    'like' => 'You liked this',
    'like_negative' => 'You disliked similar',
    'time' => 'Fits this time of day',
    'replay' => 'You replay this a lot',
    'intent' => 'Matches your recent mood',
    'skip' => 'Often skipped',
    'overplay' => 'Played a lot lately',
    'slice' => 'Discovery pick',
    'similar' => 'Similar to your seed',
    'radio' => 'Radio pick',
    'cold' => 'New to you',
    'no_signal' => 'Fresh recommendation',
    _ => key,
  };

  @override
  bool operator ==(Object other) =>
      other is ScoreReason &&
      other.key == key &&
      other.contribution == contribution;

  @override
  int get hashCode => Object.hash(key, contribution);

  @override
  String toString() => 'ScoreReason($key, $contribution)';
}

/// Which mix slice a track was drawn from (spec 10.6).
enum MixSlice {
  /// Top-scored exploitation candidates (default 70%).
  exploitation,

  /// Familiar-but-fresh adjacent candidates (default 20%).
  adjacent,

  /// Unplayed exploration candidates (default 10%).
  exploration,
}

/// A track with its heuristic score and Why-panel reasons.
@immutable
final class ScoredTrack {
  /// Creates a scored track.
  const ScoredTrack({
    required this.trackId,
    required this.score,
    required this.reasons,
    this.slice = MixSlice.exploitation,
  });

  /// Deserializes a snapshot entry.
  factory ScoredTrack.fromJson(Map<String, Object?> json) {
    final reasons = json['reasons'];
    return ScoredTrack(
      trackId: json['trackId']! as String,
      score: (json['score']! as num).toDouble(),
      slice: _sliceFrom(json['slice'] as String?),
      reasons: <ScoreReason>[
        if (reasons is List)
          for (final entry in reasons)
            if (entry is Map)
              ScoreReason(
                '${entry['key'] ?? 'no_signal'}',
                ((entry['contribution'] as num?) ?? 0).toDouble(),
              ),
      ],
    );
  }

  /// Scored track id.
  final String trackId;

  /// Clamped 0..1 heuristic score (spec 10.3).
  final double score;

  /// Per-factor contributions; never empty (spec T10).
  final List<ScoreReason> reasons;

  /// Which mix slice produced this pick.
  final MixSlice slice;

  /// Serializes for `reco_snapshots.json` (ids + scores + reasons).
  Map<String, Object?> toJson() => <String, Object?>{
    'trackId': trackId,
    'score': score,
    'slice': slice.name,
    'reasons': <Map<String, Object?>>[
      for (final reason in reasons)
        <String, Object?>{
          'key': reason.key,
          'contribution': reason.contribution,
        },
    ],
  };

  static MixSlice _sliceFrom(String? raw) {
    for (final slice in MixSlice.values) {
      if (slice.name == raw) {
        return slice;
      }
    }
    return MixSlice.exploitation;
  }

  @override
  String toString() =>
      'ScoredTrack($trackId, ${score.toStringAsFixed(3)}, $slice)';
}
