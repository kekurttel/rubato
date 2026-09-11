import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_reco/src/diversity.dart';
import 'package:aurora_reco/src/mix.dart';
import 'package:aurora_reco/src/score.dart';
import 'package:aurora_reco/src/vector.dart';

/// Persisted reco surface snapshot (maps to `reco_snapshots.json`).
///
/// The app layer stores [toJson] through `RecoSnapshotDao.putSnapshot`
/// with [computedAt]/[ttlMs] as epoch milliseconds; the UI reads the
/// freshest snapshot per surface and never waits on recompute.
final class RecoSnapshot {
  /// Creates a snapshot.
  const RecoSnapshot({
    required this.surface,
    required this.entries,
    required this.computedAt,
    required this.ttlMs,
  });

  /// Deserializes a stored snapshot.
  factory RecoSnapshot.fromJson(Map<String, Object?> json) {
    final entries = json['entries'];
    return RecoSnapshot(
      surface: json['surface']! as String,
      entries: <ScoredTrack>[
        if (entries is List)
          for (final entry in entries)
            if (entry is Map<String, Object?>)
              ScoredTrack.fromJson(entry)
            else if (entry is Map)
              ScoredTrack.fromJson(
                entry.map(
                  (key, value) => MapEntry('$key', value),
                ),
              ),
      ],
      computedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['computedAt'] as num?)?.toInt() ?? 0,
        isUtc: true,
      ),
      ttlMs: Duration(
        milliseconds: (json['ttlMs'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  /// Surface id (see [RecoSurface]).
  final String surface;

  /// Ranked entries (ids + scores + Why-panel reasons).
  final List<ScoredTrack> entries;

  /// Computation time (UTC).
  final DateTime computedAt;

  /// Freshness window.
  final Duration ttlMs;

  /// Track ids in order (convenience for queue building).
  List<String> get trackIds => <String>[
    for (final entry in entries) entry.trackId,
  ];

  /// Whether [now] falls outside the freshness window.
  bool isStaleAt(DateTime now) => now.difference(computedAt) >= ttlMs;

  /// Serializes for the `reco_snapshots` table.
  Map<String, Object?> toJson() => <String, Object?>{
    'surface': surface,
    'computedAt': computedAt.millisecondsSinceEpoch,
    'ttlMs': ttlMs.inMilliseconds,
    'entries': [
      for (final entry in entries) entry.toJson(),
    ],
  };
}

/// Surface ids (YouTube-Music-like, all on-device, spec 10.8).
abstract final class RecoSurface {
  /// Last 20 distinct plays, chronological — not reco-ranked.
  static const String recentlyPlayed = 'recently_played';

  /// Albums/playlists with 0.15 < progress < 0.95.
  static const String continueListening = 'continue_listening';

  /// 20 mixed picks (Your Supermix equivalent).
  static const String madeForYou = 'made_for_you';

  /// Seeded by the top artist (My Mix 1).
  static const String dailyMix1 = 'daily_mix_1';

  /// Seeded by the top genre (My Mix 2).
  static const String dailyMix2 = 'daily_mix_2';

  /// Seeded by the current time bucket (My Mix 3).
  static const String dailyMix3 = 'daily_mix_3';

  /// Exploration slice, 20 (Discover Mix).
  static const String discover = 'discover';

  /// Recent adds matching top genres, 20 (New Release Mix).
  static const String newReleaseMix = 'new_release_mix';

  /// High replayCount + recency, 20 (Replay Mix).
  static const String replayMix = 'replay_mix';

  /// Adjacent picks beyond the home mix, 12.
  static const String basedOnListening = 'based_on_listening';

  /// Lazy cosine-similar list for the current player item, 12.
  static const String similarToCurrent = 'similar_to_current';

  /// Per-bucket mood mixes, 4 x 12 (see [moodSurfaceFor]).
  static const String moodPrefix = 'mood_mix_';

  /// Home snapshot freshness (spec 10.8).
  static const Duration homeTtl = Duration(minutes: 20);

  /// All home-tab surfaces covered by [homeTtl].
  static const List<String> homeSurfaces = <String>[
    madeForYou,
    dailyMix1,
    dailyMix2,
    dailyMix3,
    discover,
    newReleaseMix,
    replayMix,
    basedOnListening,
  ];

  /// Mood surface id for [bucket].
  static String moodSurfaceFor(TimeOfDayBucket bucket) =>
      '$moodPrefix${bucket.name}';

  /// Milliseconds from [now] until the next local midnight.
  ///
  /// Daily mixes rebuild once per local calendar day (spec 10.8);
  /// storing this as their TTL makes staleness checks trivial.
  static Duration msUntilLocalMidnight(DateTime now) {
    final local = now.toLocal();
    final midnight = DateTime(
      local.year,
      local.month,
      local.day,
    ).add(const Duration(days: 1));
    return midnight.difference(local);
  }

  /// Whether a daily snapshot computed at [computedAt] is stale at
  /// [now] (different local calendar day or version bump).
  static bool isDailyStale(
    DateTime computedAt,
    DateTime now, {
    int? profileVersion,
    int? snapshotProfileVersion,
  }) {
    if (profileVersion != null &&
        snapshotProfileVersion != null &&
        profileVersion != snapshotProfileVersion) {
      return true;
    }
    final a = computedAt.toLocal();
    final b = now.toLocal();
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }
}

/// Pure surface slicers over an already-ranked list (spec 10.8).
///
/// Inputs arrive as plain models so every method runs unchanged on
/// the UI isolate (tests) and the background isolate (production).
abstract final class Surfaces {
  /// Last [count] distinct tracks, newest-first (not reco-ranked).
  static List<ScoredTrack> recentlyPlayed(
    List<PlayEvent> eventsNewestFirst, {
    int count = 20,
  }) {
    final seen = <String>{};
    final picks = <ScoredTrack>[];
    for (final event in eventsNewestFirst) {
      if (picks.length >= count) {
        break;
      }
      if (seen.add(event.trackId)) {
        picks.add(
          ScoredTrack(
            trackId: event.trackId,
            score: 1,
            reasons: const [ScoreReason('recency', 0.10)],
          ),
        );
      }
    }
    return picks;
  }

  /// Next-up tracks of albums/playlists in the 0.15–0.95 band.
  ///
  /// Progress is distinct heard tracks over known total; collections
  /// with unknown totals use heard-over-heard-plus-one so partial
  /// listens still qualify. Returns at most [count] tracks ordered
  /// by recency of the collection's last play.
  static List<ScoredTrack> continueListening({
    required List<PlayEvent> eventsNewestFirst,
    required Map<String, Track> byId,
    Map<String, int> albumTrackCounts = const <String, int>{},
    Map<String, List<String>> playlistTracks = const <String, List<String>>{},
    int count = 20,
  }) {
    final heardByAlbum = <String, Set<String>>{};
    final lastTouchAlbum = <String, DateTime>{};
    for (final event in eventsNewestFirst.reversed) {
      final track = byId[event.trackId];
      final albumId = track?.albumId;
      if (albumId == null) {
        continue;
      }
      heardByAlbum.putIfAbsent(albumId, Set<String>.new).add(event.trackId);
      lastTouchAlbum[albumId] = event.startedAt;
    }
    final candidates = <({String id, double progress, DateTime touch})>[];
    for (final entry in heardByAlbum.entries) {
      final total = albumTrackCounts[entry.key] ?? 0;
      final progress = total > 0
          ? entry.value.length / total
          : entry.value.length / (entry.value.length + 1);
      if (progress > 0.15 && progress < 0.95) {
        // Continue with the most recent heard track of the album.
        String? resume;
        for (final event in eventsNewestFirst) {
          if (entry.value.contains(event.trackId)) {
            resume = event.trackId;
            break;
          }
        }
        if (resume != null) {
          candidates.add(
            (
              id: resume,
              progress: progress,
              touch:
                  lastTouchAlbum[entry.key] ??
                  DateTime.fromMillisecondsSinceEpoch(0),
            ),
          );
        }
      }
    }
    for (final entry in playlistTracks.entries) {
      if (entry.value.isEmpty) {
        continue;
      }
      final heard = entry.value.where(
        heardByAlbum.values.expand((s) => s).contains,
      );
      final progress = heard.length / entry.value.length;
      if (progress > 0.15 && progress < 0.95) {
        final resume = entry.value.firstWhere(
          (id) => !heard.contains(id),
          orElse: () => entry.value.first,
        );
        if (byId.containsKey(resume)) {
          candidates.add(
            (
              id: resume,
              progress: progress,
              touch: DateTime.fromMillisecondsSinceEpoch(0),
            ),
          );
        }
      }
    }
    candidates.sort((a, b) => b.touch.compareTo(a.touch));
    return <ScoredTrack>[
      for (final candidate in candidates.take(count))
        ScoredTrack(
          trackId: candidate.id,
          score: candidate.progress,
          reasons: const [ScoreReason('recency', 0.10)],
        ),
    ];
  }

  /// 20 mixed picks over [ranked] (delegates to [MixSlicer]).
  static List<ScoredTrack> madeForYou({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required Map<String, UserTrackStats> statsByTrackId,
    required PreferenceProfile profile,
    required List<Track> explorationPool,
    required int storedEventCount,
    int count = 20,
  }) => MixSlicer.slice(
    ranked: ranked,
    byId: byId,
    statsByTrackId: statsByTrackId,
    profile: profile,
    explorationPool: explorationPool,
    count: count,
    storedEventCount: storedEventCount,
  );

  /// Mix seeded by the top artist (takes up to [count] of their
  /// tracks in ranked order, then same-genre fill).
  static List<ScoredTrack> dailyMix1({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required PreferenceProfile profile,
    int count = 20,
  }) {
    final topArtist = _topKey(profile.artistWeights);
    if (topArtist == null) {
      return ranked.take(count).toList();
    }
    return _seededMix(
      ranked: ranked,
      byId: byId,
      count: count,
      matchesSeed: (track) => track.artistIds.contains(topArtist),
    );
  }

  /// Mix seeded by the top genre.
  static List<ScoredTrack> dailyMix2({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required PreferenceProfile profile,
    int count = 20,
  }) {
    final topGenre = _topKey(profile.genreWeights);
    if (topGenre == null) {
      return ranked.take(count).toList();
    }
    return _seededMix(
      ranked: ranked,
      byId: byId,
      count: count,
      matchesSeed: (track) => track.genreIds.contains(topGenre),
    );
  }

  /// Mix seeded by the current bucket's top artists.
  static List<ScoredTrack> dailyMix3({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required PreferenceProfile profile,
    required TimeOfDayBucket bucket,
    int count = 20,
  }) {
    final scoped = profile.timeContext[bucket.name] ?? const {};
    final seeds = _topKeys(scoped, 3).toSet();
    if (seeds.isEmpty) {
      return ranked.take(count).toList();
    }
    return _seededMix(
      ranked: ranked,
      byId: byId,
      count: count,
      matchesSeed: (track) => track.artistIds.any(seeds.contains),
    );
  }

  /// Exploration slice: top-ranked unplayed tracks ([count]).
  static List<ScoredTrack> discover({
    required List<ScoredTrack> ranked,
    required Map<String, UserTrackStats> statsByTrackId,
    int count = 20,
  }) {
    final picks = <ScoredTrack>[];
    for (final item in ranked) {
      if (picks.length >= count) {
        break;
      }
      if ((statsByTrackId[item.trackId]?.playCount ?? 0) == 0) {
        picks.add(item);
      }
    }
    return picks;
  }

  /// Recent adds (30 d) matching the top-3 genres, newest-first.
  static List<ScoredTrack> newReleaseMix({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required PreferenceProfile profile,
    required DateTime now,
    int count = 20,
  }) {
    final topGenres = _topKeys(profile.genreWeights, 3).toSet();
    final rankIndex = <String, int>{
      for (var i = 0; i < ranked.length; i++) ranked[i].trackId: i,
    };
    final fresh = <Track>[];
    for (final track in byId.values) {
      if (now.difference(track.createdAt) > const Duration(days: 30)) {
        continue;
      }
      if (topGenres.isEmpty || track.genreIds.any(topGenres.contains)) {
        fresh.add(track);
      }
    }
    fresh.sort((a, b) {
      final date = b.createdAt.compareTo(a.createdAt);
      if (date != 0) {
        return date;
      }
      return (rankIndex[a.id] ?? 1 << 30).compareTo(rankIndex[b.id] ?? 1 << 30);
    });
    return <ScoredTrack>[
      for (final track in fresh.take(count))
        ScoredTrack(
          trackId: track.id,
          score: 0.5,
          reasons: const [ScoreReason('cold', 0)],
        ),
    ];
  }

  /// High replayCount blended with recency ([count]).
  static List<ScoredTrack> replayMix({
    required Map<String, UserTrackStats> statsByTrackId,
    required DateTime now,
    int count = 20,
  }) {
    final rows =
        statsByTrackId.values
            .where((stats) => stats.replayCount > 0 || stats.playCount > 2)
            .toList()
          ..sort((a, b) {
            final replay = b.replayCount.compareTo(a.replayCount);
            if (replay != 0) {
              return replay;
            }
            final aLast = a.lastPlayedAt;
            final bLast = b.lastPlayedAt;
            if (aLast == null || bLast == null) {
              return 0;
            }
            return bLast.compareTo(aLast);
          });
    return <ScoredTrack>[
      for (final stats in rows.take(count))
        ScoredTrack(
          trackId: stats.trackId,
          score: (stats.replayCount / (stats.replayCount + 3))
              .clamp(0, 1)
              .toDouble(),
          reasons: const [ScoreReason('replay', 0.06)],
        ),
    ];
  }

  /// Picks beyond the home mix: exploitation ranks 20–32, capped 12.
  static List<ScoredTrack> basedOnListening(
    List<ScoredTrack> ranked, {
    int count = 12,
  }) {
    if (ranked.length <= 20) {
      return ranked.take(count).toList();
    }
    return ranked.skip(20).take(count).toList();
  }

  /// Cosine-similar tracks to [seed] ([count], spec 10.9).
  static List<ScoredTrack> similarToCurrent({
    required Track seed,
    required List<Track> candidates,
    required List<String> topArtists,
    int count = 12,
  }) => <ScoredTrack>[
    for (final hit in TrackVector.similarTo(
      seed: seed,
      candidates: candidates,
      topArtists: topArtists,
      count: count,
    ))
      ScoredTrack(
        trackId: hit.trackId,
        score: hit.similarity,
        reasons: [ScoreReason('similar', hit.similarity)],
      ),
  ];

  /// One 12-track mood mix per bucket from that bucket's artists.
  static Map<String, List<ScoredTrack>> moodMixes({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required PreferenceProfile profile,
    int count = 12,
  }) {
    final mixes = <String, List<ScoredTrack>>{};
    for (final bucket in TimeOfDayBucket.values) {
      final seeds = _topKeys(
        profile.timeContext[bucket.name] ?? const {},
        3,
      ).toSet();
      final picks = <ScoredTrack>[];
      if (seeds.isNotEmpty) {
        for (final item in ranked) {
          if (picks.length >= count) {
            break;
          }
          final track = byId[item.trackId];
          if (track != null && track.artistIds.any(seeds.contains)) {
            picks.add(item);
          }
        }
      }
      for (final item in ranked) {
        if (picks.length >= count) {
          break;
        }
        if (!picks.any((pick) => pick.trackId == item.trackId)) {
          picks.add(item);
        }
      }
      mixes[RecoSurface.moodSurfaceFor(bucket)] = Diversity.mmr(
        ranked: picks,
        byId: byId,
        statsByTrackId: const {},
        count: count,
      );
    }
    return mixes;
  }

  static List<ScoredTrack> _seededMix({
    required List<ScoredTrack> ranked,
    required Map<String, Track> byId,
    required bool Function(Track track) matchesSeed,
    required int count,
  }) {
    final seeded = <ScoredTrack>[];
    final rest = <ScoredTrack>[];
    for (final item in ranked) {
      final track = byId[item.trackId];
      if (track != null && matchesSeed(track)) {
        seeded.add(item);
      } else {
        rest.add(item);
      }
    }
    return [...seeded, ...rest].take(count).toList();
  }

  static String? _topKey(Map<String, double> weights) {
    String? best;
    var bestValue = double.negativeInfinity;
    for (final entry in weights.entries) {
      if (entry.value > bestValue) {
        bestValue = entry.value;
        best = entry.key;
      }
    }
    return best;
  }

  static List<String> _topKeys(Map<String, double> weights, int count) {
    final entries = weights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final entry in entries.take(count)) entry.key];
  }
}
