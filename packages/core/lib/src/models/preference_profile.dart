import 'package:freezed_annotation/freezed_annotation.dart';

part 'preference_profile.freezed.dart';
part 'preference_profile.g.dart';

/// Single-row, versioned taste profile (spec section 5).
///
/// Long-term maps decay with a 45-day half-life; [recentIntent] covers
/// the last 7 days with linear (undecayed) weighting so a sudden genre
/// shift ("suddenly jazz") surfaces without erasing history. Each map is
/// normalized so its max value is 1.0 after an update.
@freezed
abstract class PreferenceProfile with _$PreferenceProfile {
  /// Creates a preference profile.
  const factory PreferenceProfile({
    /// Last update time (UTC).
    required DateTime updatedAt,

    /// Schema version (starts at 1).
    @Default(1) int version,

    /// Decayed artist affinity (artist id -> weight).
    @Default(<String, double>{}) Map<String, double> artistWeights,

    /// Decayed genre affinity (genre id -> weight).
    @Default(<String, double>{}) Map<String, double> genreWeights,

    /// Decayed per-time-bucket artist affinity
    /// (bucket name -> artist id -> weight).
    @Default(<String, Map<String, double>>{})
    Map<String, Map<String, double>> timeContext,

    /// Short-window (7d) genre/artist intent (key -> heard ms).
    @Default(<String, double>{}) Map<String, double> recentIntent,

    /// Exploration share of mixes (default 0.10).
    @Default(0.10) double explorationRate,

    /// Adjacent share of mixes (default 0.20).
    @Default(0.20) double adjacentRate,

    /// Exploitation share of mixes (default 0.70).
    @Default(0.70) double exploitationRate,

    /// Half-life in days for long-term decay (default 45).
    @Default(45) double decayHalfLifeDays,

    /// MMR penalty for consecutive same-artist picks (default 0.05).
    @Default(0.05) double consecutiveArtistPenalty,
  }) = _PreferenceProfile;

  const PreferenceProfile._();

  /// Deserializes a profile from JSON.
  factory PreferenceProfile.fromJson(Map<String, dynamic> json) =>
      _$PreferenceProfileFromJson(json);

  /// Sum of the three mix rates; must stay 1.0 (spec 10.6, 13.6).
  double get ratesSum => explorationRate + adjacentRate + exploitationRate;

  /// Whether the mix rates are valid (sum to 1.0 within epsilon).
  bool get ratesValid => (ratesSum - 1.0).abs() < 1e-9;
}
