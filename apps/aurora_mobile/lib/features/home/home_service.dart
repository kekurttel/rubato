import 'dart:convert';
import 'dart:math';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_database/aurora_database.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:drift/drift.dart' show Value, Variable;

/// Home-tab surface ids (mirror `RecoSurface` in `packages/reco`).
///
/// Duplicated as strings so the UI needs no reco import — the app
/// lane bridges snapshot rows into [HomeRecoEntry] lists.
abstract final class HomeSurfaces {
  /// Last 20 distinct plays, chronological.
  static const String recentlyPlayed = 'recently_played';

  /// Albums/playlists with 0.15 < progress < 0.95.
  static const String continueListening = 'continue_listening';

  /// 20 mixed picks (Your Supermix equivalent).
  static const String madeForYou = 'made_for_you';

  /// Seeded by the top artist.
  static const String dailyMix1 = 'daily_mix_1';

  /// Seeded by the top genre.
  static const String dailyMix2 = 'daily_mix_2';

  /// Seeded by the current time bucket.
  static const String dailyMix3 = 'daily_mix_3';

  /// Exploration slice, 20.
  static const String discover = 'discover';

  /// Recent adds matching top genres, 20.
  static const String newReleaseMix = 'new_release_mix';

  /// High replayCount + recency, 20.
  static const String replayMix = 'replay_mix';

  /// Adjacent picks beyond the home mix, 12.
  static const String basedOnListening = 'based_on_listening';

  /// YouTube Music Top-charts rail (curated online search, 10).
  static const String ytmTop = 'ytm_top_charts';

  /// YouTube Music trending-now rail (curated online search, 10).
  static const String ytmTrending = 'ytm_trending_now';

  /// YouTube Music new-releases rail (curated online search, 10).
  static const String ytmNew = 'ytm_new_releases';

  /// Per-bucket mood mixes (`mood_mix_<bucket>`, 4 x 12 when the engine
  /// has written them; mirrors `RecoSurface.moodPrefix` in
  /// `packages/reco` without importing it).
  static const String moodPrefix = 'mood_mix_';
}

/// One Why-panel reason behind a home row or card.
final class HomeWhyReason {
  /// Creates a reason.
  const HomeWhyReason({required this.key, required this.contribution});

  /// Stable machine key (`artist`, `genre`, `skip`, ...).
  final String key;

  /// Signed score contribution in raw-score units.
  final double contribution;

  /// Short display label for the Why sheet.
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
}

/// One ranked home row: the track plus its Why-panel reasons.
final class HomeRecoEntry {
  /// Creates an entry.
  const HomeRecoEntry({
    required this.track,
    required this.score,
    this.reasons = const <HomeWhyReason>[],
  });

  /// Ranked track (resolved by the app lane from the snapshot).
  final Track track;

  /// Clamped 0..1 heuristic score.
  final double score;

  /// Why-panel contributions (never empty on real snapshots).
  final List<HomeWhyReason> reasons;
}

/// Continue-listening card: a resumable album or playlist.
final class ContinueItem {
  /// Creates a continue item.
  const ContinueItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.trackIds = const <String>[],
  });

  /// Album or playlist id (routes to `/album/:id`, `/playlist/:id`).
  final String id;

  /// Display title.
  final String title;

  /// Artist line or track-count hint.
  final String subtitle;

  /// 0..1 progress (always strictly inside 0.15–0.95 per spec).
  final double progress;

  /// Whether this card points at a playlist (else an album).
  bool get isPlaylist => id.startsWith('playlist:');

  /// Track ids for one-tap resume playback.
  final List<String> trackIds;
}

/// Day-part greeting derived from the injected [Clock] (spec 13.2).
String homeGreeting(Clock clock) {
  final hour = clock.now().hour;
  if (hour < 6) {
    return 'Good night';
  }
  if (hour < 12) {
    return 'Good morning';
  }
  if (hour < 18) {
    return 'Good afternoon';
  }
  return 'Good evening';
}

/// Snapshot + recompute boundary behind the Home tab.
///
/// The app lane implements this over `RecoSnapshotDao` (reads) and
/// the reco engine (recompute on a background isolate). Widgets never
/// touch Drift tables or reco internals directly.
abstract class HomeRecoService {
  /// Resolved entries for [surface] (empty when no snapshot exists).
  Future<List<HomeRecoEntry>> entriesFor(String surface);

  /// Resumable albums/playlists (empty hides the section).
  Future<List<ContinueItem>> continueListening();

  /// Forces a background recompute (pull-to-refresh).
  Future<void> recompute();

  /// Online reachability for the Library-mode banner.
  Stream<ProviderHealth> onlineHealth();
}

/// Playback + like actions behind home rows and cards.
abstract class HomeActions {
  /// Display artist line for [track] (ids resolved to names).
  String artistLine(Track track);

  /// Plays [tracks] from [startIndex] with [origin].
  Future<void> playTracks(
    List<Track> tracks, {
    int startIndex = 0,
    PlaySource origin = PlaySource.reco,
  });

  /// Current like state (-1/0/1) for [trackId].
  int likeStateFor(String trackId);

  /// Writes the like state for [trackId].
  Future<void> setLike(String trackId, int likeState);
}

/// Cold-start event gate (spec 10.6): fewer stored play events means
/// the profile has no signal yet and Home must fall back to library
/// data + recent searches instead of reco-ranked mixes.
///
/// Retained as the documented spec boundary; the writer below no longer
/// early-returns on it (mix shelves are healed from library data
/// whenever no fresh engine snapshot exists — see [computeColdStartHome]).
const int coldStartMaxEvents = 15;

/// Home snapshot freshness for cold-start rows (spec 10.8: 20 min TTL).
const Duration coldStartSnapshotTtl = Duration(minutes: 20);

/// Track ids per cold-start surface slice (spec 10.8 counts).
const int coldStartMixCount = 20;

/// Adjacent-pick count for the cold `based_on_listening` slice.
const int coldStartAdjacentCount = 12;

/// Upper bound on the id pool feeding the seeded shuffles.
///
/// A single covering index scan of ids only; fetching the whole table
/// is wasteful on very large libraries, so the pool caps here (still
/// effectively the full library for typical on-device collections).
const int coldStartShufflePoolCap = 5000;

/// Computes cold-start Home snapshots from local data (spec 10.6 cold
/// path + 10.8 surfaces) and persists them into `reco_snapshots`.
///
/// Fresh installs have no snapshots and (almost) no play events, so
/// Home would render empty even with a full local library. This fills
/// the rows Home already reads, in the exact bare-list JSON format the
/// app lane parses (`[{"trackId": ..., "score": ...}]`, reasons render
/// as `cold`):
/// - `recently_played`: distinct last 20 event tracks, passthrough
///   whenever play events exist (warm or cold).
/// - `made_for_you`: recent-search matches pinned first, then an
///   interleave of recently added + seeded-shuffle discover picks.
/// - `daily_mix_1`: newest tracks of the top artist by library track
///   count, filled with discover picks.
/// - `daily_mix_2` / `daily_mix_3`: seeded-shuffle slices (no genre or
///   time-context signal exists before first profile build; the mix-3
///   seed folds in the current day-part bucket so it varies by time).
/// - `discover`: seeded-shuffle slice of 20.
/// - `new_release_mix`: recently added tracks (`created_at` desc).
/// - `based_on_listening`: a second seeded-shuffle window of 12.
///
/// Mix surfaces are (re)written from library data whenever the surface
/// holds no fresh snapshot — regardless of the play-event count. The
/// previous `eventCount >= coldStartMaxEvents` early-return assumed the
/// engine/stats path would take over the shelves, but neither the
/// snapshot engine nor the profile→stats pipeline is wired yet, so warm
/// libraries rendered only Recently played. A fresh non-cold row (the
/// engine owns `id`s outside the `cold:` prefix) is never clobbered;
/// with [force] false, fresh cold rows (inside [coldStartSnapshotTtl])
/// are left alone; pass [force] true after library mutations (scan) or
/// on explicit refresh.
///
/// Cost: a handful of `LIMIT`-bounded indexed reads plus one
/// id-only scan and an in-memory shuffle — sub-millisecond to a few
/// milliseconds on device, so this runs inline on the caller like
/// every other DAO read instead of a background isolate. Never throws:
/// an empty library (or any failure) simply writes nothing and Home
/// keeps its empty-hidden sections.
Future<void> computeColdStartHome({
  required AuroraDatabase db,
  required Clock clock,
  bool force = false,
}) async {
  try {
    await _computeColdStartHome(db: db, clock: clock, force: force);
  } on Exception {
    // Home stays on its stats fallback / hidden sections.
  }
}

Future<void> _computeColdStartHome({
  required AuroraDatabase db,
  required Clock clock,
  required bool force,
}) async {
  final nowMs = clock.nowEpochMs();
  final trackCount = await _coldTrackCount(db);
  if (trackCount == 0) {
    return;
  }
  final eventCount = await db.eventsDao.countAll();

  if (eventCount > 0) {
    await _writeColdSurface(
      db,
      surface: HomeSurfaces.recentlyPlayed,
      ids: await _recentEventTrackIds(db),
      nowMs: nowMs,
      force: force,
    );
  }

  final recentAdds = await _recentTrackIds(db, coldStartMixCount);
  final pool = await _coldTrackIdPool(db);
  if (pool.isEmpty) {
    return;
  }
  const seedBase = 0xC01D;
  final discover = _seededShuffle(pool, seedBase).take(coldStartMixCount);
  final discoverB = _seededShuffle(pool, seedBase + 1).take(coldStartMixCount);
  final adjacent = _seededShuffle(pool, seedBase + 2).skip(coldStartMixCount);
  final bucketSeed = seedBase + 3 + _dayPartIndex(clock.now().hour);
  final timeSlice = _seededShuffle(pool, bucketSeed).take(coldStartMixCount);

  final topArtistTracks = await _topArtistTrackIds(db, coldStartMixCount);
  final searchPins = await _searchPinIds(db);

  final madeForYou = _dedupe([
    ...searchPins,
    ..._interleave(recentAdds, discover),
  ]).take(coldStartMixCount).toList();
  final dailyMix1 = _dedupe([
    ...topArtistTracks,
    ...discover,
  ]).take(coldStartMixCount).toList();

  await _writeColdSurface(
    db,
    surface: HomeSurfaces.madeForYou,
    ids: madeForYou,
    nowMs: nowMs,
    force: force,
  );
  await _writeColdSurface(
    db,
    surface: HomeSurfaces.dailyMix1,
    ids: dailyMix1,
    nowMs: nowMs,
    force: force,
  );
  await _writeColdSurface(
    db,
    surface: HomeSurfaces.dailyMix2,
    ids: discoverB.toList(),
    nowMs: nowMs,
    force: force,
  );
  await _writeColdSurface(
    db,
    surface: HomeSurfaces.dailyMix3,
    ids: timeSlice.toList(),
    nowMs: nowMs,
    force: force,
  );
  await _writeColdSurface(
    db,
    surface: HomeSurfaces.discover,
    ids: discover.toList(),
    nowMs: nowMs,
    force: force,
  );
  await _writeColdSurface(
    db,
    surface: HomeSurfaces.newReleaseMix,
    ids: recentAdds,
    nowMs: nowMs,
    force: force,
  );
  await _writeColdSurface(
    db,
    surface: HomeSurfaces.basedOnListening,
    ids: adjacent.take(coldStartAdjacentCount).toList(),
    nowMs: nowMs,
    force: force,
  );
}

/// Home snapshot freshness for online recommendations (4 hours).
const Duration onlineRecommendationsTtl = Duration(hours: 4);

/// Discovers online recommendations based on user taste (or trending hits)
/// and writes them to Home recommendation surfaces.
///
/// Fails gracefully on network or provider error, leaving existing
/// home surfaces intact.
Future<void> enrichHomeWithOnlineRecommendations(
  AuroraWiring wiring, {
  bool force = false,
}) async {
  try {
    await _enrichHomeWithOnlineRecommendations(wiring, force: force);
  } on Object {
    // Fail gracefully: network issues never break local Home recommendations.
  }
}

Future<void> _enrichHomeWithOnlineRecommendations(
  AuroraWiring wiring, {
  required bool force,
}) async {
  final nowMs = wiring.clock.nowEpochMs();
  if (!force) {
    final existing = await wiring.db.recoSnapshotsDao.bySurface(
      HomeSurfaces.discover,
    );
    if (existing != null && existing.id.startsWith('online:')) {
      final computedAt = existing.computedAt ?? 0;
      if (nowMs - computedAt < onlineRecommendationsTtl.inMilliseconds) {
        try {
          final decoded = jsonDecode(existing.json);
          if (decoded is List && decoded.isNotEmpty) {
            return;
          }
        } on FormatException {
          // Stale/corrupt json falls through to recompute.
        }
      }
    }
  }

  final seeds = <String>[];
  var isArtistSeed = false;

  final statsRows = await wiring.db.customSelect(
    'SELECT a.name AS name, '
    'SUM(CASE WHEN uts.like_state = 1 THEN 10 ELSE 0 END + '
    'COALESCE(uts.play_count, 0)) AS score '
    'FROM artists a '
    'JOIN track_artists ta ON ta.artist_id = a.id '
    'JOIN user_track_stats uts ON uts.track_id = ta.track_id '
    'WHERE (uts.like_state = 1 OR uts.play_count > 0) '
    "  AND TRIM(a.name) != '' AND LOWER(a.name) != 'unknown artist' "
    'GROUP BY a.name '
    'ORDER BY score DESC '
    'LIMIT 2',
    readsFrom: {
      wiring.db.artists,
      wiring.db.trackArtists,
      wiring.db.userTrackStats,
    },
  ).get();

  for (final row in statsRows) {
    final name = row.read<String>('name').trim();
    if (name.isNotEmpty && !seeds.contains(name)) {
      seeds.add(name);
    }
  }

  if (seeds.length < 2) {
    final libRows = await wiring.db.customSelect(
      'SELECT a.name AS name, COUNT(*) AS c '
      'FROM artists a '
      'JOIN track_artists ta ON ta.artist_id = a.id '
      "WHERE TRIM(a.name) != '' AND LOWER(a.name) != 'unknown artist' "
      'GROUP BY a.name '
      'ORDER BY c DESC '
      'LIMIT 2',
      readsFrom: {wiring.db.artists, wiring.db.trackArtists},
    ).get();

    for (final row in libRows) {
      if (seeds.length >= 2) {
        break;
      }
      final name = row.read<String>('name').trim();
      if (name.isNotEmpty && !seeds.contains(name)) {
        seeds.add(name);
      }
    }
  }

  if (seeds.isNotEmpty) {
    isArtistSeed = true;
  } else {
    seeds.addAll(const ['Top Hits', 'Popüler Müzik']);
    isArtistSeed = false;
  }

  final seedResults = <List<Track>>[];
  for (final seed in seeds.take(2)) {
    final queryText = isArtistSeed ? '$seed popular' : seed;
    try {
      final result = await wiring.ytdlp.search(
        SearchQuery(
          text: queryText,
          limit: 8,
          types: const [SearchType.track, SearchType.artist],
        ),
      );
      final tracks = <Track>[];
      result.fold(
        (page) {
          for (final artist in page.artists) {
            wiring.artistNames[artist.id] = artist.name;
          }
          tracks.addAll(page.tracks);
        },
        (error) {},
      );
      for (final track in tracks) {
        if (isArtistSeed && track.artistIds.isNotEmpty) {
          for (final artistId in track.artistIds) {
            wiring.artistNames.putIfAbsent(artistId, () => seed);
          }
        }
        await wiring.ensureTrackStored(track);
      }
      seedResults.add(tracks);
    } on Object {
      // Individual seed network error does not prevent trying other seeds.
    }
  }

  final allOnlineTracks = <Track>[
    for (final list in seedResults) ...list,
  ];
  if (allOnlineTracks.isEmpty) {
    return;
  }

  // 1. Discover rail: online discovered music
  final discoverIds = _dedupe(
    allOnlineTracks.map((t) => t.id).toList(),
  ).take(coldStartMixCount).toList();
  await _writeOnlineSurface(
    wiring.db,
    surface: HomeSurfaces.discover,
    ids: discoverIds,
    nowMs: nowMs,
  );

  // 2. Based on your listening: online tracks from the top artist
  final topArtistTracks =
      (seedResults.isNotEmpty && seedResults.first.isNotEmpty)
          ? seedResults.first
          : allOnlineTracks;
  final basedOnListeningIds = _dedupe(
    topArtistTracks.map((t) => t.id).toList(),
  ).take(coldStartAdjacentCount).toList();
  await _writeOnlineSurface(
    wiring.db,
    surface: HomeSurfaces.basedOnListening,
    ids: basedOnListeningIds,
    nowMs: nowMs,
  );

  // 3. Made for you: interleave online tracks into existing Made For You
  final existingSnapshot = await wiring.db.recoSnapshotsDao.bySurface(
    HomeSurfaces.madeForYou,
  );
  var baseIds = <String>[];
  if (existingSnapshot?.json != null) {
    try {
      final decoded = jsonDecode(existingSnapshot!.json);
      if (decoded is List) {
        baseIds = [
          for (final item in decoded)
            if (item is Map && item['trackId'] is String)
              item['trackId'] as String,
        ];
      }
    } on FormatException {
      // Fall through to recent tracks.
    }
  }
  if (baseIds.isEmpty) {
    baseIds = await _recentTrackIds(wiring.db, coldStartMixCount);
  }
  final onlineIdSet = allOnlineTracks.map((t) => t.id).toSet();
  final nonOnlineBaseIds =
      baseIds.where((id) => !onlineIdSet.contains(id)).toList();
  final onlineIds = allOnlineTracks.map((t) => t.id).toList();

  final interleavedMadeForYou = _dedupe(
    nonOnlineBaseIds.isNotEmpty
        ? _interleave(nonOnlineBaseIds, onlineIds)
        : onlineIds,
  ).take(coldStartMixCount).toList();

  await _writeOnlineSurface(
    wiring.db,
    surface: HomeSurfaces.madeForYou,
    ids: interleavedMadeForYou,
    nowMs: nowMs,
  );
}

/// Curated YouTube Music chart queries backing the YTM rails.
///
/// The catalog is the YouTube catalog (same engine as search), so these
/// rails stream exactly what YouTube Music serves for the charts — no
/// extra provider or dependency needed.
const Map<String, String> ytmChartQueries = <String, String>{
  HomeSurfaces.ytmTop: 'Top 100 global hits',
  HomeSurfaces.ytmTrending: 'Trending music worldwide',
  HomeSurfaces.ytmNew: 'New music releases',
};

/// Number of tracks kept per YouTube Music chart rail.
const int ytmChartRailCount = 10;

/// Fetches the YouTube Music chart rails and persists them as Home
/// snapshot surfaces ([HomeSurfaces.ytmTop], [HomeSurfaces.ytmTrending],
/// [HomeSurfaces.ytmNew]).
///
/// Each chart runs one curated online search and stores the discovered
/// tracks (with artist names) so rails resolve offline afterwards.
///
/// When the YouTube account is connected, the three rails come from
/// the account's own YouTube Music home feed instead of the generic
/// charts — recommendations match the user's taste. Fails gracefully:
/// an empty/failed fetch leaves the previous rows intact, and offline
/// devices keep the last charts. Never throws.
Future<void> enrichYtMusicCharts(
  AuroraWiring wiring, {
  bool force = false,
}) async {
  try {
    await _enrichYtMusicCharts(wiring, force: force);
  } on Object {
    // Chart fetch never breaks Home.
  }
}

/// Stores one account-feed item as a streamable catalog track.
Future<String?> _storeShelfTrack(
  AuroraWiring wiring,
  YtMusicTrack item,
  DateTime now,
) async {
  try {
    final videoId = item.videoId.trim();
    if (videoId.isEmpty) {
      return null;
    }
    final trackId = AuroraIds.trackId('ytdlp', videoId);
    final uploader = item.artist.trim();
    final artistId = uploader.isEmpty
        ? null
        : AuroraIds.trackId('ytdlp', 'channel-${_slug(uploader)}');
    if (artistId != null) {
      wiring.artistNames[artistId] = uploader;
    }
    await wiring.ensureTrackStored(
      Track(
        id: trackId,
        providerId: 'ytdlp',
        sourceTrackId: videoId,
        title: item.title.trim().isEmpty ? 'Untitled' : item.title.trim(),
        createdAt: now,
        updatedAt: now,
        artistIds: artistId != null ? <String>[artistId] : const <String>[],
      ),
    );
    return trackId;
  } on Object {
    return null;
  }
}

String _slug(String raw) => raw
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

Future<void> _enrichYtMusicCharts(
  AuroraWiring wiring, {
  required bool force,
}) async {
  final nowMs = wiring.clock.nowEpochMs();
  if (!force) {
    final existing = await wiring.db.recoSnapshotsDao.bySurface(
      HomeSurfaces.ytmTop,
    );
    if (existing != null && existing.id.startsWith('online:')) {
      final computedAt = existing.computedAt ?? 0;
      if (nowMs - computedAt < onlineRecommendationsTtl.inMilliseconds) {
        try {
          final decoded = jsonDecode(existing.json);
          if (decoded is List && decoded.isNotEmpty) {
            return;
          }
        } on FormatException {
          // Stale/corrupt json falls through to recompute.
        }
      }
    }
  }
  // Signed in: each surface prefers the account's own home-feed
  // shelf and falls back to its generic chart query, so a thin feed
  // never duplicates one shelf across all three rails.
  final List<YtMusicShelf> accountShelves;
  if (!wiring.ytdlp.account.isSignedIn) {
    accountShelves = const <YtMusicShelf>[];
  } else {
    var fetched = const <YtMusicShelf>[];
    try {
      fetched = await wiring.ytdlp.account.homeShelves();
    } on Object {
      fetched = const <YtMusicShelf>[];
    }
    accountShelves = fetched;
  }
  final now = wiring.clock.nowUtc();
  final surfaces = <String>[
    HomeSurfaces.ytmTop,
    HomeSurfaces.ytmTrending,
    HomeSurfaces.ytmNew,
  ];
  for (var i = 0; i < surfaces.length; i++) {
    if (i < accountShelves.length &&
        accountShelves[i].tracks.isNotEmpty) {
      final ids = <String>[];
      for (final item
          in accountShelves[i].tracks.take(ytmChartRailCount)) {
        final id = await _storeShelfTrack(wiring, item, now);
        if (id != null) {
          ids.add(id);
        }
      }
      await _writeOnlineSurface(
        wiring.db,
        surface: surfaces[i],
        ids: _dedupe(ids).take(ytmChartRailCount).toList(),
        nowMs: nowMs,
      );
      continue;
    }
    await _writeChartSurface(
      wiring,
      surface: surfaces[i],
      query: ytmChartQueries[surfaces[i]]!,
      nowMs: nowMs,
    );
  }
  return;
}

Future<void> _writeChartSurface(
  AuroraWiring wiring, {
  required String surface,
  required String query,
  required int nowMs,
}) async {
  try {
    final result = await wiring.ytdlp.search(
      SearchQuery(
        text: query,
        limit: ytmChartRailCount,
        types: const [SearchType.track, SearchType.artist],
      ),
    );
    final tracks = <Track>[];
    result.fold(
      (page) {
        for (final artist in page.artists) {
          wiring.artistNames[artist.id] = artist.name;
        }
        tracks.addAll(page.tracks);
      },
      (error) {},
    );
    for (final track in tracks) {
      await wiring.ensureTrackStored(track);
    }
    final ids = _dedupe(
      tracks.map((t) => t.id).toList(),
    ).take(ytmChartRailCount).toList();
    await _writeOnlineSurface(
      wiring.db,
      surface: surface,
      ids: ids,
      nowMs: nowMs,
    );
  } on Object {
    // One failed chart never blocks the other charts.
  }
}

Future<void> _writeOnlineSurface(
  AuroraDatabase db, {
  required String surface,
  required List<String> ids,
  required int nowMs,
}) async {
  if (ids.isEmpty) {
    return;
  }
  final scored = <Map<String, Object?>>[
    for (var i = 0; i < ids.length; i++)
      <String, Object?>{
        'trackId': ids[i],
        'score': (ids.length - i) / ids.length,
      },
  ];
  await db.customStatement(
    'DELETE FROM reco_snapshots WHERE surface = ?',
    <Object>[surface],
  );
  await db.recoSnapshotsDao.putSnapshot(
    RecoSnapshotsCompanion(
      id: Value('online:$surface'),
      surface: Value(surface),
      json: Value(jsonEncode(scored)),
      computedAt: Value(nowMs),
      ttlMs: Value(onlineRecommendationsTtl.inMilliseconds),
    ),
  );
}

/// Writes one cold-start snapshot row in the bare-list JSON format the
/// Home lane parses, replacing any previous row for [surface].
///
/// The `reco_snapshots` primary key is the row id (not the surface),
/// so a stable `cold:$surface` id plus a surface-scoped delete keeps
/// exactly one row per surface and `bySurface` can never see dupes.
Future<void> _writeColdSurface(
  AuroraDatabase db, {
  required String surface,
  required List<String> ids,
  required int nowMs,
  required bool force,
}) async {
  if (ids.isEmpty) {
    return;
  }
  if (!force && await db.recoSnapshotsDao.isFresh(surface, nowMs)) {
    return;
  }
  if (await _hasFreshEngineRow(db, surface: surface, nowMs: nowMs)) {
    return;
  }
  final scored = <Map<String, Object?>>[
    for (var i = 0; i < ids.length; i++)
      <String, Object?>{
        'trackId': ids[i],
        'score': (ids.length - i) / ids.length,
      },
  ];
  await db.customStatement(
    'DELETE FROM reco_snapshots WHERE surface = ?',
    <Object>[surface],
  );
  await db.recoSnapshotsDao.putSnapshot(
    RecoSnapshotsCompanion(
      id: Value('cold:$surface'),
      surface: Value(surface),
      json: Value(jsonEncode(scored)),
      computedAt: Value(nowMs),
      ttlMs: Value(coldStartSnapshotTtl.inMilliseconds),
    ),
  );
}

/// Whether [surface] currently holds a fresh snapshot the cold writer
/// must not clobber: any row whose id is not `cold:`-prefixed (the reco
/// engine or a future warm pipeline wrote it) inside its own TTL.
/// Missing, stale, and cold-owned rows all return false.
Future<bool> _hasFreshEngineRow(
  AuroraDatabase db, {
  required String surface,
  required int nowMs,
}) async {
  final existing = await db.recoSnapshotsDao.bySurface(surface);
  if (existing == null || existing.id.startsWith('cold:')) {
    return false;
  }
  return nowMs - (existing.computedAt ?? 0) < (existing.ttlMs ?? 0);
}

/// Number of library tracks (cold-start empty gate).
Future<int> _coldTrackCount(AuroraDatabase db) async {
  final row = await db
      .customSelect('SELECT COUNT(*) AS c FROM tracks')
      .getSingle();
  return (row.data['c'] as int?) ?? 0;
}

/// Newest track ids by `created_at` desc.
Future<List<String>> _recentTrackIds(AuroraDatabase db, int limit) async {
  final rows = await db
      .customSelect(
        'SELECT id FROM tracks ORDER BY created_at DESC LIMIT ?',
        variables: <Variable<Object>>[Variable<int>(limit)],
        readsFrom: {db.tracks},
      )
      .get();
  return <String>[for (final row in rows) row.read<String>('id')];
}

/// Distinct track ids from the newest play events (passthrough).
Future<List<String>> _recentEventTrackIds(AuroraDatabase db) async {
  final events = await db.eventsDao.latest(limit: 100);
  final seen = <String>{};
  final ids = <String>[];
  for (final event in events) {
    if (ids.length >= coldStartMixCount) {
      break;
    }
    if (seen.add(event.trackId)) {
      ids.add(event.trackId);
    }
  }
  return ids;
}

/// Bounded id pool feeding the seeded shuffles.
Future<List<String>> _coldTrackIdPool(AuroraDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT id FROM tracks LIMIT ?',
        variables: <Variable<Object>>[
          const Variable<int>(coldStartShufflePoolCap),
        ],
        readsFrom: {db.tracks},
      )
      .get();
  return <String>[for (final row in rows) row.read<String>('id')];
}

/// Newest tracks of the top artist by library track count (Daily-Mix-1
/// seed substitute until artist weights exist).
Future<List<String>> _topArtistTrackIds(
  AuroraDatabase db,
  int limit,
) async {
  final top = await db
      .customSelect(
        'SELECT artist_id AS artist_id, COUNT(*) AS c '
        'FROM track_artists GROUP BY artist_id ORDER BY c DESC LIMIT 1',
        readsFrom: {db.trackArtists},
      )
      .get();
  if (top.isEmpty) {
    return const <String>[];
  }
  final artistId = top.first.read<String>('artist_id');
  final rows = await db
      .customSelect(
        'SELECT ta.track_id AS track_id FROM track_artists ta '
        'JOIN tracks t ON t.id = ta.track_id '
        'WHERE ta.artist_id = ? ORDER BY t.created_at DESC LIMIT ?',
        variables: <Variable<Object>>[
          Variable<String>(artistId),
          Variable<int>(limit),
        ],
        readsFrom: {db.trackArtists, db.tracks},
      )
      .get();
  return <String>[for (final row in rows) row.read<String>('track_id')];
}

Future<List<String>> _searchPinIds(AuroraDatabase db) async {
  try {
    return await _searchPinIdsUnsafe(db);
  } on Exception {
    // A malformed history term must never fail the whole compute.
    return const <String>[];
  }
}

/// Track ids matching the latest search terms (spec 10.6: cold start
/// blends in last searches); at most 5 pins, never fatal.
Future<List<String>> _searchPinIdsUnsafe(AuroraDatabase db) async {
  final history = await db.searchDao.recentHistory(limit: 5);
  final seenTerms = <String>{};
  final ids = <String>[];
  for (final entry in history) {
    final term = entry.query.trim();
    if (term.length < 2 || !seenTerms.add(term.toLowerCase())) {
      continue;
    }
    final hits = await db.tracksDao.searchByTitleLike(term, limit: 10);
    for (final hit in hits) {
      if (ids.length >= 5) {
        return ids;
      }
      if (!ids.contains(hit.id)) {
        ids.add(hit.id);
      }
    }
    if (ids.length >= 5) {
      break;
    }
  }
  return ids;
}

/// Deterministic shuffle: stable shelves until the library changes.
List<String> _seededShuffle(List<String> ids, int seed) =>
    _seededShuffleList(ids, seed);

/// Deterministic shuffle over any list (stable order per seed).
List<T> _seededShuffleList<T>(List<T> items, int seed) {
  final shuffled = [...items]..shuffle(Random(seed));
  return shuffled;
}

/// Day-part index matching the greeting buckets (night/morning/
/// afternoon/evening) so Daily Mix 3 varies by time of day.
int _dayPartIndex(int hour) {
  if (hour < 6) {
    return 0;
  }
  if (hour < 12) {
    return 1;
  }
  if (hour < 18) {
    return 2;
  }
  return 3;
}

/// Order-preserving dedupe.
List<String> _dedupe(List<String> ids) {
  final seen = <String>{};
  return <String>[
    for (final id in ids)
      if (seen.add(id)) id,
  ];
}

/// Alternates two slices (recent, discover, recent, ...) for the
/// made-for-you blend.
List<String> _interleave(List<String> first, Iterable<String> second) {
  final out = <String>[];
  final rest = second.iterator;
  var hasMore = rest.moveNext();
  for (final id in first) {
    out.add(id);
    if (hasMore) {
      out.add(rest.current);
      hasMore = rest.moveNext();
    }
  }
  while (hasMore) {
    out.add(rest.current);
    hasMore = rest.moveNext();
  }
  return out;
}

/// YouTube-Music-style mood chips (single-select filter over the
/// already-loaded snapshot pool; selection re-seeds shelves in memory,
/// no new snapshot rows are written).
enum HomeMood {
  /// High-energy daytime picks.
  enerjik,

  /// Wind-down evening picks.
  rahatlatici,

  /// Feel-good daytime picks.
  keyifli,

  /// High-arousal workout picks.
  antrenman,

  /// Sustained afternoon focus picks.
  odaklanma,

  /// Night-time sleep picks.
  uyku,
}

/// Display label for a [HomeMood] (chip + shelf text).
extension HomeMoodLabel on HomeMood {
  /// Turkish chip label.
  String get label => switch (this) {
    HomeMood.enerjik => 'Enerjik',
    HomeMood.rahatlatici => 'Rahatlatıcı',
    HomeMood.keyifli => 'Keyifli',
    HomeMood.antrenman => 'Antrenman',
    HomeMood.odaklanma => 'Odaklanma',
    HomeMood.uyku => 'Uyku',
  };
}

/// Day-part bucket backing [mood]'s engine-mix lookup.
///
/// Six moods share four buckets by arousal level: high-arousal moods
/// read the morning mix, daytime-positive moods the afternoon mix,
/// wind-down the evening mix, sleep the night mix. Moods sharing a
/// bucket still diverge in the seeded-shuffle fallback below via
/// distinct seeds and heuristics.
TimeOfDayBucket homeMoodBucket(HomeMood mood) => switch (mood) {
  HomeMood.enerjik || HomeMood.antrenman => TimeOfDayBucket.morning,
  HomeMood.odaklanma || HomeMood.keyifli => TimeOfDayBucket.afternoon,
  HomeMood.rahatlatici => TimeOfDayBucket.evening,
  HomeMood.uyku => TimeOfDayBucket.night,
};

/// Existing reco surface id backing [mood] (`mood_mix_<bucket>`,
/// mirrors `RecoSurface.moodSurfaceFor` without importing reco).
String homeMoodSurface(HomeMood mood) =>
    '${HomeSurfaces.moodPrefix}${homeMoodBucket(mood).name}';

/// Tracks per mood shelf (matches the reco 12-track mood mixes).
const int homeMoodShelfCount = 12;

/// Tracks per "Yeniden dinleyin" shelf (recency + replay fill).
const int homeListenAgainCount = 20;

/// Deterministic per-mood shuffle seed: each chip re-seeds stably,
/// distinct across chips.
int homeMoodSeed(HomeMood mood) => 0xC0DE + mood.index * 0x77;

/// Re-seeds [pool] for [mood] entirely in memory (no snapshot writes).
///
/// Orders the already-loaded snapshot pool with a per-mood heuristic
/// over entry-local signals only (score, Why reasons, duration,
/// recency), then seeded-shuffles the top slice so each chip is stable
/// yet distinct:
///
/// - [HomeMood.enerjik]: high-engagement first (`like`/`replay`
///   reasons), then score desc — replayed favourites read as energy.
/// - [HomeMood.rahatlatici]: longest duration first, calmer (lower)
///   scores breaking ties — sustained tracks unwind.
/// - [HomeMood.keyifli]: liked first, then recent (`recency` reasons,
///   newest `createdAt`) — fresh favourites.
/// - [HomeMood.antrenman]: replayed first, then longest duration —
///   sustained bangers carry a workout.
/// - [HomeMood.odaklanma]: longest duration first, preferring
///   `completion`/`time` reasons — finishable, fits the day-part.
/// - [HomeMood.uyku]: longest duration first with score ascending as
///   the tiebreak — long and low-stimulation.
///
/// Pure and total: empty pools return empty, never throws.
List<HomeRecoEntry> applyHomeMood(List<HomeRecoEntry> pool, HomeMood mood) {
  if (pool.isEmpty) {
    return const <HomeRecoEntry>[];
  }
  final ranked = [...pool]..sort(_homeMoodComparator(mood));
  return _seededShuffleList(
    ranked.take(homeMoodShelfCount).toList(),
    homeMoodSeed(mood),
  );
}

/// Merges [recent] plays with [replayHeavy] picks for the
/// "Yeniden dinleyin" shelf: recency first, replay fill, deduped by
/// track id and capped at [count]. Pure, never throws.
List<HomeRecoEntry> listenAgainEntries({
  required List<HomeRecoEntry> recent,
  required List<HomeRecoEntry> replayHeavy,
  int count = homeListenAgainCount,
}) {
  final seen = <String>{};
  final out = <HomeRecoEntry>[];
  for (final entry in [...recent, ...replayHeavy]) {
    if (out.length >= count) {
      break;
    }
    if (seen.add(entry.track.id)) {
      out.add(entry);
    }
  }
  return out;
}

/// Comparator implementing the per-mood heuristic (see [applyHomeMood]).
Comparator<HomeRecoEntry> _homeMoodComparator(HomeMood mood) {
  bool hasReason(HomeRecoEntry entry, String key) =>
      entry.reasons.any((reason) => reason.key == key);
  int engagement(HomeRecoEntry entry) =>
      (hasReason(entry, 'like') ? 2 : 0) + (hasReason(entry, 'replay') ? 1 : 0);
  int byScoreDesc(HomeRecoEntry a, HomeRecoEntry b) =>
      b.score.compareTo(a.score);
  int byScoreAsc(HomeRecoEntry a, HomeRecoEntry b) =>
      a.score.compareTo(b.score);
  int byDurationDesc(HomeRecoEntry a, HomeRecoEntry b) =>
      b.track.durationMs.compareTo(a.track.durationMs);
  int byNewest(HomeRecoEntry a, HomeRecoEntry b) =>
      b.track.createdAt.compareTo(a.track.createdAt);
  int tiebreak(HomeRecoEntry a, HomeRecoEntry b) =>
      a.track.id.compareTo(b.track.id);

  int chain(HomeRecoEntry a, HomeRecoEntry b, List<int Function()> steps) {
    for (final step in steps) {
      final order = step();
      if (order != 0) {
        return order;
      }
    }
    return tiebreak(a, b);
  }

  return switch (mood) {
    HomeMood.enerjik => (a, b) => chain(a, b, [
      () => engagement(b).compareTo(engagement(a)),
      () => byScoreDesc(a, b),
    ]),
    HomeMood.rahatlatici => (a, b) => chain(a, b, [
      () => byDurationDesc(a, b),
      () => byScoreAsc(a, b),
    ]),
    HomeMood.keyifli => (a, b) => chain(a, b, [
      () => (hasReason(b, 'like') ? 0 : 1).compareTo(
        hasReason(a, 'like') ? 0 : 1,
      ),
      () => (hasReason(b, 'recency') ? 0 : 1).compareTo(
        hasReason(a, 'recency') ? 0 : 1,
      ),
      () => byNewest(a, b),
    ]),
    HomeMood.antrenman => (a, b) => chain(a, b, [
      () => (hasReason(b, 'replay') ? 0 : 1).compareTo(
        hasReason(a, 'replay') ? 0 : 1,
      ),
      () => byDurationDesc(a, b),
      () => byScoreDesc(a, b),
    ]),
    HomeMood.odaklanma => (a, b) => chain(a, b, [
      () => byDurationDesc(a, b),
      () => ((hasReason(b, 'completion') || hasReason(b, 'time')) ? 0 : 1)
          .compareTo(
            (hasReason(a, 'completion') || hasReason(a, 'time')) ? 0 : 1,
          ),
      () => byScoreDesc(a, b),
    ]),
    HomeMood.uyku => (a, b) => chain(a, b, [
      () => byDurationDesc(a, b),
      () => byScoreAsc(a, b),
    ]),
  };
}
