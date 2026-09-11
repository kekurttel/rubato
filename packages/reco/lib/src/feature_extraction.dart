import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/decay.dart';

/// Per-event weight inputs resolved by the caller (spec 10.2).
///
/// The extractor stays catalog-agnostic: the app layer looks the
/// event's track up once and hands its artist/genre ids in, so this
/// file never imports Drift or provider code.
final class EventFeatures {
  /// Creates event features.
  const EventFeatures({
    required this.event,
    this.artistIds = const <String>[],
    this.genreIds = const <String>[],
    this.likeState = 0,
  });

  /// Flushed listening observation.
  final PlayEvent event;

  /// Credited artist ids of the played track.
  final List<String> artistIds;

  /// Genre ids of the played track.
  final List<String> genreIds;

  /// Current like state (-1/0/1) of the played track.
  final int likeState;
}

/// Feature extraction + incremental rollups (spec 10.2, 10.10).
///
/// Weight per event:
/// `w = listenedMs * decay(age) * completionBoost * skipPenalty * like`
/// where `completionBoost = 1 + 0.5 * completionRatio`,
/// `skipPenalty = 0.15` for skips (×1.25 for radio skips per spec
/// 10.8, i.e. 0.1875 — radio skips are common, so each one counts a
/// touch more toward learning what to avoid), and `like` is 1.6 for
/// likes / 0.05 for dislikes. Stream plays (`stream`/`radio`/`search`
/// sources) weight exactly like local plays.
///
/// Noise (`listenedMs < 3000` and not a skip) is dropped before it
/// reaches any accumulator, mirroring the sink's flush rule.
abstract final class FeatureExtraction {
  /// Noise gate shared with the sink (spec section 9).
  static bool isNoise(PlayEvent event) =>
      !event.skipped && event.listenedMs < 3000;

  /// Completion boost: full listens reinforce more than glimpses.
  static double completionBoost(double completionRatio) =>
      1.0 + 0.5 * completionRatio.clamp(0, 1).toDouble();

  /// Skip penalty: 0.15 for skips, 1.0 otherwise.
  ///
  /// Radio skips multiply by 1.25 (spec 10.8).
  static double skipPenalty(PlayEvent event) {
    if (!event.skipped) {
      return 1;
    }
    if (event.source == PlaySource.radio) {
      return 0.15 * 1.25;
    }
    return 0.15;
  }

  /// Like multiplier: 1.6 liked, 0.05 disliked, 1.0 otherwise.
  static double likeMultiplier(int likeState) => switch (likeState) {
    1 => 1.6,
    -1 => 0.05,
    _ => 1.0,
  };

  /// Full event weight at [now] under [profile]'s half-life.
  static double eventWeight(
    EventFeatures features,
    DateTime now,
    PreferenceProfile profile,
  ) {
    final event = features.event;
    if (isNoise(event)) {
      return 0;
    }
    final age = RecoDecay.ageOf(event.startedAt, now);
    return event.listenedMs *
        RecoDecay.decay(age, profile.decayHalfLifeDays) *
        completionBoost(event.completionRatio) *
        skipPenalty(event) *
        likeMultiplier(features.likeState);
  }

  /// Folds one event into its stats row (incremental, spec 10.10).
  ///
  /// `previous` is the existing row or null for first observation.
  /// Quick restarts (same track within 30 s) bump [UserTrackStats]
  /// `replayCount` instead of looking like fresh discovery.
  static UserTrackStats updateStats(
    UserTrackStats? previous,
    EventFeatures features,
    DateTime now,
  ) {
    final event = features.event;
    final base =
        previous ?? UserTrackStats(trackId: event.trackId, updatedAt: now);
    final quickRestart =
        base.lastPlayedAt != null &&
        event.startedAt.difference(base.lastPlayedAt!).inSeconds.abs() <= 30;
    // Decayed score: fade the old aggregate across the gap, then add
    // this event's fresh (unaged) contribution.
    final gap = base.lastPlayedAt == null
        ? Duration.zero
        : RecoDecay.ageOf(base.lastPlayedAt!, now);
    final fadedScore = base.decayedScore * RecoDecay.decay(gap, 45);
    final freshWeight =
        event.listenedMs *
        completionBoost(event.completionRatio) *
        skipPenalty(event) *
        likeMultiplier(features.likeState);
    final lastPlayed = base.lastPlayedAt;
    final mergedLast =
        lastPlayed == null ||
            event.startedAt.isAfter(
              lastPlayed,
            )
        ? event.startedAt
        : lastPlayed;
    return base.copyWith(
      updatedAt: now,
      playCount: base.playCount + 1,
      skipCount: base.skipCount + (event.skipped ? 1 : 0),
      completeCount: base.completeCount + (event.isComplete ? 1 : 0),
      replayCount: base.replayCount + (quickRestart ? 1 : 0),
      totalListenMs: base.totalListenMs + event.listenedMs,
      lastPlayedAt: mergedLast,
      decayedScore: fadedScore + (isNoise(event) ? 0 : freshWeight),
    );
  }

  /// Folds a batch of events into [profile] (incremental path).
  ///
  /// Long-term maps accumulate decayed weights; `recentIntent`
  /// accumulates raw heard milliseconds for events inside the 7-day
  /// window only. Every map is renormalized so its max is 1.0.
  static PreferenceProfile updateProfile(
    PreferenceProfile profile,
    List<EventFeatures> features,
    DateTime now,
  ) {
    final artists = Map<String, double>.of(profile.artistWeights);
    final genres = Map<String, double>.of(profile.genreWeights);
    final timeContext = <String, Map<String, double>>{
      for (final entry in profile.timeContext.entries)
        entry.key: Map<String, double>.of(entry.value),
    };
    final recent = Map<String, double>.of(profile.recentIntent);

    for (final feature in features) {
      final event = feature.event;
      if (isNoise(event)) {
        continue;
      }
      final weight = eventWeight(feature, now, profile);
      for (final artist in feature.artistIds) {
        artists[artist] = (artists[artist] ?? 0) + weight;
        final bucket = event.timeOfDayBucket.name;
        final scoped = timeContext.putIfAbsent(
          bucket,
          Map<String, double>.new,
        );
        scoped[artist] = (scoped[artist] ?? 0) + weight;
      }
      for (final genre in feature.genreIds) {
        genres[genre] = (genres[genre] ?? 0) + weight;
      }
      if (RecoDecay.isRecent(event.startedAt, now)) {
        for (final key in [...feature.artistIds, ...feature.genreIds]) {
          recent[key] = (recent[key] ?? 0) + event.listenedMs.toDouble();
        }
      }
    }

    // Prune recent intent outside the window on write: callers pass
    // the current batch, but stale keys from older batches linger.
    // Full rebuilds (below) recompute it exactly; here we drop keys
    // that stopped accumulating only when they are exactly zero.
    recent.removeWhere((key, value) => value <= 0);

    return profile.copyWith(
      updatedAt: now,
      artistWeights: RecoDecay.normalizeMax(artists),
      genreWeights: RecoDecay.normalizeMax(genres),
      timeContext: RecoDecay.normalizeTimeContext(timeContext),
      recentIntent: RecoDecay.normalizeMax(recent),
    );
  }

  /// Recomputes [profile] from scratch over [features] (nightly path).
  ///
  /// Identical math to [updateProfile] but starts from empty maps, so
  /// drift from incremental rounding and stale `recentIntent` keys
  /// cannot accumulate. The app layer triggers this when the last
  /// full rebuild is older than 24 h or 200+ events arrived since.
  static PreferenceProfile rebuildProfile(
    PreferenceProfile profile,
    List<EventFeatures> features,
    DateTime now,
  ) => updateProfile(
    profile.copyWith(
      artistWeights: const <String, double>{},
      genreWeights: const <String, double>{},
      timeContext: const <String, Map<String, double>>{},
      recentIntent: const <String, double>{},
    ),
    features,
    now,
  );

  /// Maximum value of the recent-intent map (ranker normalization).
  static double maxRecentIntent(PreferenceProfile profile) {
    var max = 0.0;
    for (final value in profile.recentIntent.values) {
      if (value > max) {
        max = value;
      }
    }
    return max;
  }
}
