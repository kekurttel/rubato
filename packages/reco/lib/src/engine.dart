import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/candidates.dart';
import 'package:aurora_reco/src/feature_extraction.dart';
import 'package:aurora_reco/src/heuristic_ranker.dart';
import 'package:aurora_reco/src/ranker.dart';
import 'package:aurora_reco/src/score.dart';
import 'package:aurora_reco/src/surfaces.dart';

/// Result of folding flushed events into profile + stats.
final class ProfileUpdate {
  /// Creates an update result.
  const ProfileUpdate({required this.profile, required this.stats});

  /// Updated taste profile (maps max-normalized).
  final PreferenceProfile profile;

  /// Updated per-track rows by track id.
  final Map<String, UserTrackStats> stats;
}

/// Orchestrator: profile updates + home snapshot builds (spec 10).
///
/// All methods are pure functions of plain models. The app layer
/// (`UpdateProfileFromEvents`, `ComputeHomeSnapshots` use cases)
/// pages Drift rows, maps them with `DbMappers`, calls into here
/// (on a background isolate for snapshots), and writes results back
/// through `StatsDao` / `ProfileDao` / `RecoSnapshotDao`.
abstract final class RecoEngine {
  /// Folds [events] into [profile] and [stats] (incremental path).
  ///
  /// [tracksById] resolves artist/genre credits; [likeStates] carries
  /// current like states (defaults to 0). Stream/radio/search events
  /// weight exactly like local plays (spec 10.8).
  static ProfileUpdate updateProfileFromEvents({
    required PreferenceProfile profile,
    required List<PlayEvent> events,
    required Map<String, Track> tracksById,
    required Map<String, UserTrackStats> stats,
    required DateTime now,
    Map<String, int> likeStates = const <String, int>{},
  }) {
    final features = <EventFeatures>[
      for (final event in events)
        EventFeatures(
          event: event,
          artistIds: tracksById[event.trackId]?.artistIds ?? const <String>[],
          genreIds: tracksById[event.trackId]?.genreIds ?? const <String>[],
          likeState:
              likeStates[event.trackId] ??
              (stats[event.trackId]?.likeState ?? 0),
        ),
    ];
    final nextProfile = FeatureExtraction.updateProfile(profile, features, now);
    final nextStats = Map<String, UserTrackStats>.of(stats);
    for (final feature in features) {
      final event = feature.event;
      if (FeatureExtraction.isNoise(event)) {
        continue;
      }
      nextStats[event.trackId] = FeatureExtraction.updateStats(
        nextStats[event.trackId],
        feature,
        now,
      );
    }
    return ProfileUpdate(profile: nextProfile, stats: nextStats);
  }

  /// Full profile rebuild over [events] (nightly / >200-event path).
  static ProfileUpdate rebuildProfileFromEvents({
    required PreferenceProfile profile,
    required List<PlayEvent> events,
    required Map<String, Track> tracksById,
    required DateTime now,
    Map<String, int> likeStates = const <String, int>{},
  }) {
    final features = <EventFeatures>[
      for (final event in events)
        EventFeatures(
          event: event,
          artistIds: tracksById[event.trackId]?.artistIds ?? const <String>[],
          genreIds: tracksById[event.trackId]?.genreIds ?? const <String>[],
          likeState: likeStates[event.trackId] ?? 0,
        ),
    ];
    final nextProfile = FeatureExtraction.rebuildProfile(
      profile,
      features,
      now,
    );
    final nextStats = <String, UserTrackStats>{};
    for (final feature in features) {
      final event = feature.event;
      if (FeatureExtraction.isNoise(event)) {
        continue;
      }
      nextStats[event.trackId] = FeatureExtraction.updateStats(
        nextStats[event.trackId],
        feature,
        now,
      );
    }
    return ProfileUpdate(profile: nextProfile, stats: nextStats);
  }

  /// Builds every home snapshot (candidates → rank → mix → slice).
  static Map<String, RecoSnapshot> buildHomeSnapshots({
    required List<Track> tracks,
    required List<PlayEvent> events,
    required List<UserTrackStats> stats,
    required PreferenceProfile profile,
    required DateTime now,
    required int storedEventCount,
    List<String> similarIds = const <String>[],
    Map<String, int> albumTrackCounts = const <String, int>{},
  }) {
    final byId = <String, Track>{
      for (final track in tracks) track.id: track,
    };
    final statsById = <String, UserTrackStats>{
      for (final row in stats) row.trackId: row,
    };
    final newestFirst = [...events]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final candidates = CandidateGeneration.generate(
      CandidateInput(
        allTracks: tracks,
        profile: profile,
        statsByTrackId: statsById,
        recentTrackIds: {
          for (final event in events)
            if (now.difference(event.startedAt) <= const Duration(days: 90))
              event.trackId,
        },
        similarIds: similarIds,
        likedArtistIds: {
          for (final track in tracks)
            if (statsById[track.id]?.isLiked ?? false) ...track.artistIds,
        },
        completedAlbumIds: _completedAlbums(tracks, statsById),
        now: now,
      ),
    );

    const ranker = HeuristicRanker();
    final request = RankRequest(
      tracks: candidates.candidates,
      profile: profile,
      now: now,
      statsByTrackId: statsById,
      recentPlayCount7d: _playCounts7d(newestFirst, now),
    );
    final ranked = ranker.rankSync(request);
    // Home never serves dislikes (spec 10.5 hard constraint); the
    // artist-page path re-ranks with `includeDisliked` instead.
    final rankedHome = <ScoredTrack>[
      for (final item in ranked)
        if (!(statsById[item.trackId]?.isDisliked ?? false)) item,
    ];
    final bucket = now.timeOfDayBucket;

    final snapshots = <String, RecoSnapshot>{
      RecoSurface.recentlyPlayed: RecoSnapshot(
        surface: RecoSurface.recentlyPlayed,
        entries: Surfaces.recentlyPlayed(newestFirst),
        computedAt: now,
        ttlMs: RecoSurface.homeTtl,
      ),
      RecoSurface.continueListening: RecoSnapshot(
        surface: RecoSurface.continueListening,
        entries: Surfaces.continueListening(
          eventsNewestFirst: newestFirst,
          byId: byId,
          albumTrackCounts: albumTrackCounts,
        ),
        computedAt: now,
        ttlMs: RecoSurface.homeTtl,
      ),
      RecoSurface.madeForYou: RecoSnapshot(
        surface: RecoSurface.madeForYou,
        entries: Surfaces.madeForYou(
          ranked: rankedHome,
          byId: byId,
          statsByTrackId: statsById,
          profile: profile,
          explorationPool: candidates.explorationPool,
          storedEventCount: storedEventCount,
        ),
        computedAt: now,
        ttlMs: RecoSurface.homeTtl,
      ),
      RecoSurface.dailyMix1: RecoSnapshot(
        surface: RecoSurface.dailyMix1,
        entries: Surfaces.dailyMix1(
          ranked: rankedHome,
          byId: byId,
          profile: profile,
        ),
        computedAt: now,
        ttlMs: RecoSurface.msUntilLocalMidnight(now),
      ),
      RecoSurface.dailyMix2: RecoSnapshot(
        surface: RecoSurface.dailyMix2,
        entries: Surfaces.dailyMix2(
          ranked: rankedHome,
          byId: byId,
          profile: profile,
        ),
        computedAt: now,
        ttlMs: RecoSurface.msUntilLocalMidnight(now),
      ),
      RecoSurface.dailyMix3: RecoSnapshot(
        surface: RecoSurface.dailyMix3,
        entries: Surfaces.dailyMix3(
          ranked: rankedHome,
          byId: byId,
          profile: profile,
          bucket: bucket,
        ),
        computedAt: now,
        ttlMs: RecoSurface.msUntilLocalMidnight(now),
      ),
      RecoSurface.discover: RecoSnapshot(
        surface: RecoSurface.discover,
        entries: Surfaces.discover(
          ranked: rankedHome,
          statsByTrackId: statsById,
        ),
        computedAt: now,
        ttlMs: RecoSurface.homeTtl,
      ),
      RecoSurface.newReleaseMix: RecoSnapshot(
        surface: RecoSurface.newReleaseMix,
        entries: Surfaces.newReleaseMix(
          ranked: rankedHome,
          byId: byId,
          profile: profile,
          now: now,
        ),
        computedAt: now,
        ttlMs: RecoSurface.homeTtl,
      ),
      RecoSurface.replayMix: RecoSnapshot(
        surface: RecoSurface.replayMix,
        entries: Surfaces.replayMix(
          statsByTrackId: statsById,
          now: now,
        ),
        computedAt: now,
        ttlMs: RecoSurface.homeTtl,
      ),
      RecoSurface.basedOnListening: RecoSnapshot(
        surface: RecoSurface.basedOnListening,
        entries: Surfaces.basedOnListening(rankedHome),
        computedAt: now,
        ttlMs: RecoSurface.homeTtl,
      ),
    };
    for (final entry in Surfaces.moodMixes(
      ranked: rankedHome,
      byId: byId,
      profile: profile,
    ).entries) {
      snapshots[entry.key] = RecoSnapshot(
        surface: entry.key,
        entries: entry.value,
        computedAt: now,
        ttlMs: RecoSurface.msUntilLocalMidnight(now),
      );
    }
    return snapshots;
  }

  static Map<String, int> _playCounts7d(
    List<PlayEvent> newestFirst,
    DateTime now,
  ) {
    final counts = <String, int>{};
    for (final event in newestFirst) {
      if (now.difference(event.startedAt) > const Duration(days: 7)) {
        continue;
      }
      counts[event.trackId] = (counts[event.trackId] ?? 0) + 1;
    }
    return counts;
  }

  static Set<String> _completedAlbums(
    List<Track> tracks,
    Map<String, UserTrackStats> statsById,
  ) {
    final byAlbum = <String, List<Track>>{};
    for (final track in tracks) {
      final albumId = track.albumId;
      if (albumId != null) {
        byAlbum.putIfAbsent(albumId, () => <Track>[]).add(track);
      }
    }
    final completed = <String>{};
    for (final entry in byAlbum.entries) {
      if (entry.value.isEmpty) {
        continue;
      }
      var done = 0;
      for (final track in entry.value) {
        if ((statsById[track.id]?.completionAffinity ?? 0) >= 0.5) {
          done++;
        }
      }
      if (done / entry.value.length >= 0.5) {
        completed.add(entry.key);
      }
    }
    return completed;
  }
}
