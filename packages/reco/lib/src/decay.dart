import 'dart:math' as math;

import 'package:aurora_core/aurora_core.dart';

/// Time-decay helpers (spec section 10.1).
///
/// Long-term weights fade with [PreferenceProfile.decayHalfLifeDays]
/// (default 45): `decay(ageDays) = pow(0.5, ageDays / halfLife)`.
/// The 7-day [PreferenceProfile.recentIntent] window is undecayed
/// (linear) so sudden taste shifts surface without erasing history.
abstract final class RecoDecay {
  /// Decay factor for an event aged [age] under [halfLifeDays].
  ///
  /// Returns 1.0 for fresh (or future-dated) events, decaying toward
  /// 0.0 for ancient ones. A 45-day-old event under the default
  /// half-life contributes exactly half its weight.
  static double decay(Duration age, double halfLifeDays) {
    final ageDays = age.inMilliseconds / Duration.millisecondsPerDay;
    if (ageDays <= 0) {
      return 1;
    }
    final halfLife = halfLifeDays > 0 ? halfLifeDays : 45.0;
    return math.pow(0.5, ageDays / halfLife).toDouble();
  }

  /// Age of [eventTime] relative to [now] (clamped at zero).
  static Duration ageOf(DateTime eventTime, DateTime now) {
    final age = now.difference(eventTime);
    return age.isNegative ? Duration.zero : age;
  }

  /// Whether [eventTime] falls inside the recent-intent window.
  static bool isRecent(
    DateTime eventTime,
    DateTime now, {
    Duration window = const Duration(days: 7),
  }) => now.difference(eventTime) <= window;

  /// Recency boost for a track last heard at [lastPlayedAt] (spec 10.3).
  ///
  /// `exp(-hoursSinceLastPlay / 72)`; 0.0 when never played.
  static double recency(DateTime? lastPlayedAt, DateTime now) {
    if (lastPlayedAt == null) {
      return 0;
    }
    final hours = now.difference(lastPlayedAt).inMilliseconds / 3600000.0;
    if (hours < 0) {
      return 1;
    }
    return math.exp(-hours / 72.0);
  }

  /// Replay affinity from a restart counter (spec 10.3).
  ///
  /// `tanh(replayCount / 3)`: saturates near 1.0 for habitual replays.
  static double replayAffinity(int replayCount) {
    if (replayCount <= 0) {
      return 0;
    }
    final x = replayCount / 3.0;
    final e = math.exp(2 * x);
    return (e - 1) / (e + 1);
  }

  /// Normalizes [weights] so the maximum value becomes 1.0 (spec 10.2).
  ///
  /// Returns a new map; empty input stays empty. A zero maximum maps
  /// every entry to 0.0 instead of dividing by zero.
  static Map<String, double> normalizeMax(Map<String, double> weights) {
    if (weights.isEmpty) {
      return <String, double>{};
    }
    var max = 0.0;
    for (final value in weights.values) {
      if (value > max) {
        max = value;
      }
    }
    if (max <= 0) {
      return <String, double>{
        for (final entry in weights.entries) entry.key: 0.0,
      };
    }
    return <String, double>{
      for (final entry in weights.entries) entry.key: entry.value / max,
    };
  }

  /// Normalizes each bucket map of [timeContext] independently.
  static Map<String, Map<String, double>> normalizeTimeContext(
    Map<String, Map<String, double>> timeContext,
  ) => <String, Map<String, double>>{
    for (final entry in timeContext.entries)
      entry.key: normalizeMax(entry.value),
  };
}
