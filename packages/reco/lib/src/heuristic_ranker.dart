import 'dart:math' as math;

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/decay.dart';
import 'package:aurora_reco/src/feature_extraction.dart';
import 'package:aurora_reco/src/ranker.dart';
import 'package:aurora_reco/src/score.dart';

/// Heuristic ranker: exact spec section 10.3 formula (the only impl).
///
/// ```text
/// raw = 0.28*artistAff + 0.16*genreAff + 0.14*completionAff
///     + 0.10*recency + 0.10*like + 0.08*timeAff + 0.06*replay
///     + 0.05*searchIntent - 0.18*skipRate - 0.08*overplayPenalty
/// score = clamp(raw, 0, 1)
/// ```
///
/// Every returned [ScoredTrack] carries at least one [ScoreReason]
/// (zero-signal tracks get a `no_signal` reason) so the Why-panel
/// never renders empty (spec T10).
final class HeuristicRanker implements Ranker {
  /// Creates the ranker (stateless; weights are spec-fixed).
  const HeuristicRanker();

  @override
  Future<List<ScoredTrack>> rank(RankRequest request) async =>
      rankSync(request);

  /// Synchronous bulk rank (the isolate entry calls this).
  List<ScoredTrack> rankSync(RankRequest request) {
    final catalog =
        request.tracksById ??
        <String, Track>{for (final track in request.tracks) track.id: track};
    final maxIntent = _maxIntent(request.profile);
    final scored = <ScoredTrack>[
      for (final track in request.tracks)
        scoreTrack(
          track: track,
          profile: request.profile,
          stats: request.statsByTrackId[track.id],
          now: request.now,
          bucket: request.bucket,
          maxRecentIntent: maxIntent,
          recentPlayCount7d: request.recentPlayCount7d[track.id] ?? 0,
          catalog: catalog,
        ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  @override
  ScoredTrack scoreOne(RankRequest request, Track track) => scoreTrack(
    track: track,
    profile: request.profile,
    stats: request.statsByTrackId[track.id],
    now: request.now,
    bucket: request.bucket,
    maxRecentIntent: _maxIntent(request.profile),
    recentPlayCount7d: request.recentPlayCount7d[track.id] ?? 0,
    catalog: request.tracksById,
  );

  /// Scores one track with explicit inputs (tests use this directly).
  ScoredTrack scoreTrack({
    required Track track,
    required PreferenceProfile profile,
    required DateTime now,
    required TimeOfDayBucket bucket,
    required double maxRecentIntent,
    UserTrackStats? stats,
    int recentPlayCount7d = 0,
    Map<String, Track>? catalog,
  }) {
    final artistAff = _meanWeight(profile.artistWeights, track.artistIds);
    final genreAff = _meanWeight(profile.genreWeights, track.genreIds);
    final playCount = stats?.playCount ?? 0;
    final skipRate = (stats?.skipCount ?? 0) / math.max(playCount, 1);
    final completionAff = stats?.completionAffinity ?? 0;
    final recency = RecoDecay.recency(stats?.lastPlayedAt, now);
    final like = switch (stats?.likeState ?? 0) {
      1 => 1.0,
      -1 => -1.0,
      _ => 0.0,
    };
    final timeAff = _meanWeight(
      profile.timeContext[bucket.name] ?? const <String, double>{},
      track.artistIds,
    );
    final replay = RecoDecay.replayAffinity(stats?.replayCount ?? 0);
    final searchIntent = _searchIntent(
      profile.recentIntent,
      maxRecentIntent,
      track,
    );
    final overplay = recentPlayCount7d >= 8
        ? math.min(1, (recentPlayCount7d - 7) / 8).toDouble()
        : 0.0;

    final raw =
        0.28 * artistAff +
        0.16 * genreAff +
        0.14 * completionAff +
        0.10 * recency +
        0.10 * like +
        0.08 * timeAff +
        0.06 * replay +
        0.05 * searchIntent -
        0.18 * skipRate -
        0.08 * overplay;
    final score = raw.clamp(0, 1).toDouble();

    final reasons = <ScoreReason>[];
    void add(String key, double weight, double value) {
      final contribution = weight * value;
      if (contribution.abs() > 1e-9) {
        reasons.add(ScoreReason(key, contribution));
      }
    }

    add('artist', 0.28, artistAff);
    add('genre', 0.16, genreAff);
    add('completion', 0.14, completionAff);
    add('recency', 0.10, recency);
    if (like != 0) {
      reasons.add(
        ScoreReason(like > 0 ? 'like' : 'like_negative', 0.10 * like),
      );
    }
    add('time', 0.08, timeAff);
    add('replay', 0.06, replay);
    add('intent', 0.05, searchIntent);
    if (skipRate > 0) {
      reasons.add(ScoreReason('skip', -0.18 * skipRate));
    }
    if (overplay > 0) {
      reasons.add(ScoreReason('overplay', -0.08 * overplay));
    }
    if (reasons.isEmpty) {
      reasons.add(const ScoreReason('no_signal', 0));
    }
    // Highest-impact reason first for the Why-panel.
    reasons.sort(
      (a, b) => b.contribution.abs().compareTo(a.contribution.abs()),
    );
    return ScoredTrack(
      trackId: track.id,
      score: score,
      reasons: reasons,
    );
  }

  double _maxIntent(PreferenceProfile profile) =>
      FeatureExtraction.maxRecentIntent(profile);

  double _meanWeight(Map<String, double> weights, List<String> ids) {
    if (ids.isEmpty) {
      return 0;
    }
    var sum = 0.0;
    for (final id in ids) {
      sum += weights[id] ?? 0;
    }
    return sum / ids.length;
  }

  double _searchIntent(
    Map<String, double> recentIntent,
    double maxIntent,
    Track track,
  ) {
    if (recentIntent.isEmpty || maxIntent <= 0) {
      return 0;
    }
    final keys = <String>[...track.artistIds, ...track.genreIds];
    if (keys.isEmpty) {
      return 0;
    }
    var sum = 0.0;
    for (final key in keys) {
      sum += (recentIntent[key] ?? 0) / maxIntent;
    }
    return (sum / keys.length).clamp(0, 1).toDouble();
  }
}
