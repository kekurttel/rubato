import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_database/aurora_database.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/downloads/download_providers.dart';
import 'package:aurora_mobile/features/downloads/downloads_service.dart';
import 'package:aurora_mobile/features/home/home_providers.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/library/library_service.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_providers.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_service.dart';
import 'package:aurora_mobile/features/search/search_providers.dart';
import 'package:aurora_mobile/features/search/search_service.dart';
import 'package:aurora_mobile/features/you/you_providers.dart';
import 'package:aurora_mobile/features/you/you_service.dart';
import 'package:aurora_mobile/features/you/youtube_account.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_music_source_fake/aurora_music_source_fake.dart';
import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:aurora_reco/aurora_reco.dart';
import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wiring shared with the UI (null in widget tests without overrides).
///
/// Lets the post-first-frame auto scan and the Library rescan button
/// reach the database + local provider without threading the object
/// through every widget.
final Provider<AuroraWiring?> auroraWiringProvider = Provider<AuroraWiring?>(
  (ref) => null,
);

/// App-layer integration (spec sections 7 + 14).
///
/// Constructs the production object graph once in [buildAuroraWiring]:
/// file database, provider registry (local + fake + yt-dlp), audio
/// handler, playback controller, download manager, and the reco
/// scheduler. The thin adapter classes below bridge those objects to
/// the nullable feature-service providers the tabs already watch, so
/// widgets never import Drift companions or provider internals.
///
/// Deliberately partial (integration pass, Agents A-D own the
/// packages): snapshot-driven Home surfaces, radio refill, playback
/// resume pointer, and M3U file picking are documented gaps in
/// `known gaps' of the integration report.
final class AuroraWiring {
  /// Creates the wiring over already-constructed collaborators.
  AuroraWiring({
    required this.db,
    required this.clock,
    required this.local,
    required this.fake,
    required this.ytdlp,
    required this.providers,
    required this.audioHandler,
    required this.playback,
    required this.downloads,
    required this.recoScheduler,
    required this.downloadDir,
  });

  /// File database (production documents dir).
  final AuroraDatabase db;

  /// Shared clock.
  final Clock clock;

  /// On-device files provider.
  final LocalFilesProvider local;

  /// Deterministic fake catalog (null in release builds).
  final FakeMusicProvider? fake;

  /// yt-dlp online provider.
  final YtdlpProvider ytdlp;

  /// Provider registry (local always present).
  final ProviderRegistry providers;

  /// Lock-screen / notification bridge for `AudioService.init`.
  final AuroraAudioHandler audioHandler;

  /// Player orchestration.
  final PlaybackController playback;

  /// Download queue.
  final DownloadManager downloads;

  /// Debounced reco wake-up (spec section 14).
  final RecoScheduler recoScheduler;

  /// App-private download directory.
  final Directory downloadDir;

  /// Artist id -> display name (filled from search/library reads).
  final Map<String, String> artistNames = <String, String>{};

  /// Library refresh hook (set by [overrides]; fired on download changes).
  void Function()? onLibraryInvalidated;

  /// Track id -> like state (-1/0/1, written through `StatsDao`).
  final Map<String, int> likeStates = <String, int>{};

  /// User metadata overrides: title, description and custom artwork path.
  final Map<String, Map<String, String>> trackMetadata =
      <String, Map<String, String>>{};

  /// Returns the user-facing title, applying a saved metadata override.
  String displayTitleFor(Track track) =>
      trackMetadata[track.id]?['title']?.trim().isNotEmpty == true
      ? trackMetadata[track.id]!['title']!.trim()
      : track.title;

  /// Returns the saved description override, when present.
  String? descriptionFor(Track track) =>
      trackMetadata[track.id]?['description'];

  /// Returns the saved custom artwork path, when present.
  String? customArtworkFor(Track track) => trackMetadata[track.id]?['artwork'];

  /// Persists user-edited title, description and artwork metadata.
  Future<void> saveTrackMetadata(
    Track track, {
    required String title,
    required String description,
    String? artworkPath,
  }) async {
    final entry = <String, String>{
      'title': title.trim().isEmpty ? track.title : title.trim(),
      'description': description.trim(),
    };
    if (artworkPath != null && artworkPath.trim().isNotEmpty) {
      entry['artwork'] = artworkPath.trim();
    } else if (trackMetadata[track.id]?['artwork'] != null) {
      entry['artwork'] = trackMetadata[track.id]!['artwork']!;
    }
    trackMetadata[track.id] = entry;
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = <String, dynamic>{};
      for (final item in trackMetadata.entries) {
        all[item.key] = item.value;
      }
      await prefs.setString('aurora.trackMetadata', jsonEncode(all));
    } on Object {
      // In-memory override remains active if persistence fails.
    }
    onLibraryInvalidated?.call();
  }

  /// Restores saved track metadata overrides from local preferences.
  Future<void> loadTrackMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('aurora.trackMetadata');
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      for (final entry in decoded.entries) {
        if (entry.value is Map) {
          trackMetadata[entry.key.toString()] = <String, String>{
            for (final value in (entry.value as Map).entries)
              value.key.toString(): value.value.toString(),
          };
        }
      }
    } on Object {
      // Metadata is optional; corrupt preferences are ignored.
    }
  }

  /// Latest download jobs by track id (mirrors manager `changes`).
  final Map<String, DownloadJob> jobsByTrack = <String, DownloadJob>{};

  /// Stream-vs-file toggle (stored here; the controller build
  /// always prefers the verified local file — see known gaps).
  bool useStream = false;

  /// Display artist line for [track] (ids resolved via the cache).
  String artistLineFor(Track track) {
    if (track.artistIds.isEmpty) {
      return 'Unknown artist';
    }
    final names = <String>[
      for (final id in track.artistIds)
        if (artistNames[id] != null) artistNames[id]!,
    ];
    if (names.isEmpty) {
      return 'Unknown artist';
    }
    return names.join(', ');
  }

  /// Resolves one track row with its artist/genre joins, if present.
  Future<Track?> resolveTrack(String trackId) async {
    final row = await db.tracksDao.getById(trackId);
    if (row == null) {
      return null;
    }
    final artistIds = await db.tracksDao.artistIdsFor(trackId);
    for (final artistId in artistIds) {
      if (artistNames[artistId] == null) {
        final artistRow = await db.artistsDao.getById(artistId);
        if (artistRow != null) {
          artistNames[artistId] = artistRow.name;
        }
      }
    }
    return DbMappers.toTrack(
      row,
      artistIds: artistIds,
      genreIds: await db.tracksDao.genreIdsFor(trackId),
    );
  }

  /// Persists an online track in the database if not already stored.
  Future<void> ensureTrackStored(Track track) =>
      _ensureOnlineTrackStored(this, track);

  /// Riverpod overrides injecting every feature service.
  List<Override> overrides() {
    final home = _WiredHomeRecoService(this);
    final actions = _WiredHomeActions(this);
    final search = _WiredCatalogSearchService(this);
    final searchActions = _WiredSearchActions(this);
    final library = _WiredLibraryService(this);
    onLibraryInvalidated = library.ping;
    final downloadsService = _WiredDownloadsService(this);
    final nowPlaying = _WiredNowPlayingService(this);
    final you = _WiredYouService(this);
    return <Override>[
      auroraWiringProvider.overrideWithValue(this),
      homeRecoServiceProvider.overrideWithValue(home),
      homeActionsProvider.overrideWithValue(actions),
      catalogSearchServiceProvider.overrideWithValue(search),
      searchActionsProvider.overrideWithValue(searchActions),
      libraryServiceProvider.overrideWithValue(library),
      downloadsServiceProvider.overrideWithValue(downloadsService),
      nowPlayingServiceProvider.overrideWithValue(nowPlaying),
      youServiceProvider.overrideWithValue(you),
    ];
  }
}

/// Builds the production wiring (call once from `main`).
///
/// Never throws for missing optionals (yt-dlp binary, audio focus):
/// providers report `offline` and the UI falls back to library mode.
Future<AuroraWiring> buildAuroraWiring() async {
  const clock = SystemClock();
  final db = AuroraDatabase.openDefault();
  final local = LocalFilesProvider();
  final fake = kDebugMode ? FakeMusicProvider(clock: clock) : null;
  final ytdlp = await _buildYtdlpProvider();
  final registry = ProviderRegistry(
    local: local,
    fake: fake,
    ytdlp: ytdlp,
  );
  final handler = AuroraAudioHandler();
  final scheduler = RecoScheduler();
  final events = ListeningEventSink(
    clock: clock,
    writer: (events) async {
      await db.eventsDao.insertAll(<PlayEventsCompanion>[
        for (final event in events) _eventCompanion(event),
      ]);
    },
    // Phase 1 sink contract: persist events now; the debounced
    // profile/snapshot recompute (UpdateProfileFromEvents use-case)
    // is a known gap, so the wake-up only prunes stale cache rows.
    onEventsFlushed: () => scheduler.schedule(() async {
      await db.cacheDao.deleteExpired(clock.nowEpochMs());
    }),
  );
  late final AuroraWiring wiring;
  final store = _DbPlaybackStore(db);
  final controller = PlaybackController(
    providers: registry,
    engine: JustAudioEngine(),
    handler: handler,
    queue: QueueController(),
    events: events,
    store: store,
    clock: clock,
    likeWriter: ({required trackId, required likeState}) async {
      wiring.likeStates[trackId] = likeState;
      await db.statsDao.setLikeState(
        trackId,
        likeState: likeState,
        updatedAt: clock.nowEpochMs(),
      );
      // The Liked tab reads through the library streams: without this
      // ping a heart tap in Now Playing never refreshes it.
      wiring.onLibraryInvalidated?.call();
    },
    likeStateReader: (trackId) => wiring.likeStates[trackId] ?? 0,
    trackResolver: (ids) async {
      final out = <String, Track>{};
      for (final id in ids) {
        final track = await wiring.resolveTrack(id);
        if (track != null) {
          out[id] = track;
        }
      }
      return out;
    },
    mediaItemResolver: (track) => resolveMediaItem(wiring, track),
    streamFallback: (track, handle) =>
        _streamFallbackFile(ytdlp, track: track, handle: handle),
  );
  final docs = await getApplicationDocumentsDirectory();
  final downloadDir = await _initialDownloadDir(docs);
  // Share the provider's Piped mirror (persisted `aurora.piped.lastGood`)
  // with the downloader: `/streams` reuses the last-good mirror, and
  // `_streamFallbackFile` benefits automatically (it re-fetches
  // `handle.uri`, now the proxy URL).
  // The downloader shares the provider's explode client (not a second
  // instance) so the account-cookie sync point in
  // `YouTubeAccount.syncToBridge` covers queue downloads and the
  // stream-fallback fetcher alike. `ExplodeClient` keeps no per-call
  // state (fresh manifest/download clients per call), so sharing is
  // safe under concurrent queue + playback use.
  final downloader = YtdlpDownloader(explode: ytdlp.explode);
  final manager = DownloadManager(
    downloads: db.downloadsDao,
    tracks: db.tracksDao,
    outputDir: downloadDir,
    clock: clock,
    executor:
        ({
          required track,
          required quality,
          required outputDir,
          required onProgress,
        }) => _executeDownload(
          downloader,
          track: track,
          quality: quality,
          outputDir: outputDir,
          onProgress: onProgress,
        ),
  );
  wiring = AuroraWiring(
    db: db,
    clock: clock,
    local: local,
    fake: fake,
    ytdlp: ytdlp,
    providers: registry,
    audioHandler: handler,
    playback: controller,
    downloads: manager,
    recoScheduler: scheduler,
    downloadDir: downloadDir,
  );
  await wiring.loadTrackMetadata();
  wiring.jobsByTrack.addAll({
    for (final job in await manager.listAll()) job.trackId: job,
  });
  // Hydrate in-memory like states so hearts reflect persisted likes
  // immediately after restart (the map is otherwise write-only until
  // the first tap). Best-effort: an empty map just shows unliked.
  try {
    final rows = await db
        .customSelect(
          'SELECT track_id AS track_id, like_state AS like_state '
          'FROM user_track_stats WHERE like_state IN (1, -1)',
          readsFrom: {db.userTrackStats},
        )
        .get();
    for (final row in rows) {
      final state = row.read<int?>('like_state');
      if (state == 1 || state == -1) {
        wiring.likeStates[row.read<String>('track_id')] = state!;
      }
    }
  } on Exception {
    // Hearts fall back to unliked until the next tap persists.
  }
  manager.changes.listen((jobs) {
    wiring.jobsByTrack
      ..clear()
      ..addAll({for (final job in jobs) job.trackId: job});
    wiring.onLibraryInvalidated?.call();
  });
  // Push a stored YouTube session (if any) into the native extractor
  // so authenticated requests work from the first frame. Best-effort.
  unawaited(YouTubeAccount.syncToBridge(ytdlp));
  return wiring;
}

/// SharedPreferences key for the last-good Piped API mirror.
///
/// The Piped fleet comes and goes; remembering the working host skips
/// dead mirrors on the next launch (process-local fast path lives in
/// `PipedSearchClient` itself).
const String pipedLastGoodPrefsKey = 'aurora.piped.lastGood';

/// Builds the online provider with the persisted Piped mirror.
///
/// Loads [pipedLastGoodPrefsKey] (null when never saved) and persists
/// every new working mirror best-effort; any failure falls back to a
/// default provider so startup never breaks on a bad preference.
/// Never throws.
Future<YtdlpProvider> _buildYtdlpProvider() async {
  String? lastGood;
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(pipedLastGoodPrefsKey);
    if (raw != null && raw.trim().isNotEmpty) {
      lastGood = raw.trim();
    }
  } on Object {
    lastGood = null;
  }
  try {
    final piped = PipedSearchClient(
      initialWorkingBaseUrl: lastGood,
      onWorkingBaseUrl: (base) {
        unawaited(_persistPipedHost(base));
      },
    );
    // The `/streams` path shares this exact instance, so search wins
    // and stream wins reuse the same last-good mirror + persistence.
    return YtdlpProvider(
      explode: ExplodeClient(pipedSearch: piped),
      pipedStreams: PipedStreamsClient(searchClient: piped),
    );
  } on Object {
    return YtdlpProvider();
  }
}

/// Persists a new working Piped [base] URL (best-effort, never throws).
Future<void> _persistPipedHost(String base) async {
  final trimmed = base.trim();
  if (trimmed.isEmpty) {
    return;
  }
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(pipedLastGoodPrefsKey, trimmed);
  } on Object {
    // The in-memory fast path stands without persistence.
  }
}

/// Initial download folder honoring the persisted location choice.
///
/// Reads [downloadLocationPrefsKey] (default app-private) and resolves
/// it via [resolveDownloadDir]; any failure falls back to the
/// app-private folder so startup never breaks on a bad preference.
Future<Directory> _initialDownloadDir(Directory docs) async {
  var location = DownloadLocation.externalMusic;
  try {
    final prefs = await SharedPreferences.getInstance();
    location =
        DownloadLocation.fromName(prefs.getString(downloadLocationPrefsKey)) ??
        DownloadLocation.externalMusic;
  } on Exception {
    location = DownloadLocation.externalMusic;
  }
  try {
    return await resolveDownloadDir(location);
  } on Exception {
    final fallback = Directory(
      '${docs.path}${Platform.pathSeparator}downloads',
    );
    try {
      await fallback.create(recursive: true);
    } on Exception {
      // The queue manager creates the folder on demand as well.
    }
    return fallback;
  }
}

/// Full system-notification metadata for [track] (MediaSession item).
///
/// Artist comes from the wiring name cache (null when unknown, so the
/// notification never prints a literal "Unknown artist" line); album
/// title from the albums table; art from the owning provider's cached
/// artwork — the local embedded/thumbnail file URI when present, else
/// the online thumbnail URL, else null. Never throws: failures degrade
/// to the basic id/title item.
Future<MediaItem> resolveMediaItem(AuroraWiring wiring, Track track) async {
  String? artist;
  try {
    final line = wiring.artistLineFor(track);
    artist = line == 'Unknown artist' ? null : line;
  } on Object {
    artist = null;
  }
  String? album;
  try {
    final albumId = track.albumId;
    if (albumId != null && albumId.isNotEmpty) {
      album = (await wiring.db.albumsDao.getById(albumId))?.title;
    }
  } on Object {
    album = null;
  }
  Uri? artUri;
  final customArt = wiring.customArtworkFor(track);
  if (customArt != null && customArt.isNotEmpty) {
    artUri = Uri.file(customArt);
  }
  try {
    if (artUri != null) {
      return trackToMediaItem(
        track,
        artist: artist,
        album: album,
        artUri: artUri,
        titleOverride: wiring.displayTitleFor(track),
        description: wiring.descriptionFor(track),
      );
    }
    final provider = wiring.providers.byId(track.providerId);
    final resolved = (await provider.artwork(track)).valueOrNull;
    final path = resolved?.localPath;
    final url = resolved?.url;
    if (path != null && path.isNotEmpty) {
      artUri = Uri.file(path);
    } else if (url != null && url.isNotEmpty) {
      artUri = Uri.tryParse(url);
    } else {
      final fallback = trackFallbackThumbnailUrl(track);
      if (fallback != null) {
        artUri = Uri.tryParse(fallback);
      }
    }
  } on Object {
    final fallback = trackFallbackThumbnailUrl(track);
    artUri = fallback != null ? Uri.tryParse(fallback) : null;
  }
  return trackToMediaItem(
    track,
    artist: artist,
    album: album,
    artUri: artUri,
  );
}

/// Maps a flushed listening event to its Drift companion row.
PlayEventsCompanion _eventCompanion(PlayEvent event) => PlayEventsCompanion(
  id: Value(event.id),
  trackId: Value(event.trackId),
  sessionId: Value(event.sessionId),
  startedAt: Value(event.startedAt.toUtc().millisecondsSinceEpoch),
  endedAt: Value(event.endedAt?.toUtc().millisecondsSinceEpoch),
  durationMs: Value(event.durationMs),
  listenedMs: Value(event.listenedMs),
  completionRatio: Value(event.completionRatio),
  skipped: Value(event.skipped ? 1 : 0),
  skipAtMs: Value(event.skipAtMs),
  source: Value(event.source.name),
  timeOfDayBucket: Value(event.timeOfDayBucket.name),
  dayOfWeek: Value(event.dayOfWeek),
  playbackSpeed: Value(event.playbackSpeed),
  wasOffline: Value(event.wasOffline ? 1 : 0),
  seekCount: Value(event.seekCount),
);

/// Public export of [_ensureOnlineTrackStored].
Future<void> ensureOnlineTrackStored(
  AuroraWiring wiring,
  Track track,
) => _ensureOnlineTrackStored(wiring, track);

/// Persists an online [track] (+ credited artists) so the download
/// queue can own it.
///
/// Device-proven need: online search tracks are ephemeral (never in the
/// `tracks` table), so `DownloadManager.enqueue` failed every online
/// download with `notFound` (`track-gone`) and the Downloads tab stayed
/// empty. Existing rows are never touched (no clobber of `localPath` /
/// `is_downloaded` from a re-download), and the auto-inserted FTS row is
/// blanked so online tracks never leak into "On this device" results.
/// Never throws: on failure the later enqueue still runs and reports.
Future<void> _ensureOnlineTrackStored(
  AuroraWiring wiring,
  Track track,
) async {
  if (track.providerId == 'local') {
    return;
  }
  try {
    final existing = await wiring.db.tracksDao.getById(track.id);
    if (existing != null) {
      return;
    }
    final nowMs = wiring.clock.nowEpochMs();
    await wiring.db.transaction(() async {
      await wiring.db.tracksDao.upsertTrack(
        TracksCompanion(
          id: Value(track.id),
          providerId: Value(track.providerId),
          sourceTrackId: Value(track.sourceTrackId),
          title: Value(track.title),
          durationMs: Value(track.durationMs),
          createdAt: Value(nowMs),
          updatedAt: Value(nowMs),
        ),
      );
      final creditIds = <String>[];
      for (final artistId in track.artistIds) {
        final name = wiring.artistNames[artistId];
        if (name == null || name.isEmpty) {
          continue;
        }
        final sourceId = artistId.startsWith('${track.providerId}:')
            ? artistId.substring(track.providerId.length + 1)
            : artistId;
        await wiring.db.artistsDao.upsertArtist(
          ArtistsCompanion(
            id: Value(artistId),
            providerId: Value(track.providerId),
            sourceId: Value(sourceId),
            name: Value(name),
          ),
        );
        creditIds.add(artistId);
      }
      if (creditIds.isNotEmpty) {
        await wiring.db.tracksDao.setArtists(track.id, creditIds);
      }
    });
    final rowId = await _rowIdFor(wiring.db, track.id);
    if (rowId != null) {
      await wiring.db.searchDao.upsertFtsEntry(rowId: rowId, title: '');
    }
    developer.log(
      'persist online track=${track.id} artists=${track.artistIds.length}',
      name: 'AURORA_DIAG',
    );
  } on Exception {
    // Enqueue below still runs; a missing row surfaces as notFound there.
  }
}

/// `tracks.rowid` for one composite [id] (null when absent).
Future<int?> _rowIdFor(AuroraDatabase db, String id) async {
  try {
    final rows = await db
        .customSelect(
          'SELECT rowid AS rowid FROM tracks WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
          readsFrom: {db.tracks},
        )
        .get();
    if (rows.isEmpty) {
      return null;
    }
    return rows.first.read<int>('rowid');
  } on Exception {
    return null;
  }
}

/// Track ids with `like_state == 1`, most-recent first.
///
/// Source of truth for the Liked tab (every like path writes
/// `user_track_stats`; no code ever maintained the legacy `liked`
/// system-playlist entries). Empty on any failure so callers degrade
/// to their other source instead of erroring. Never throws.
Future<List<String>> _likedTrackIds(AuroraWiring wiring) async {
  try {
    final rows = await wiring.db
        .customSelect(
          'SELECT track_id AS track_id FROM user_track_stats '
          'WHERE like_state = 1 ORDER BY updated_at DESC',
          readsFrom: {wiring.db.userTrackStats},
        )
        .get();
    return <String>[for (final row in rows) row.read<String>('track_id')];
  } on Exception {
    return const <String>[];
  }
}

/// Short one-line cause for an escaping search [error] (≤80 chars).
String _shortSearchCause(Object error) {
  final oneLine = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  if (oneLine.isEmpty) {
    return 'unknown error';
  }
  return oneLine.length > 80 ? '${oneLine.substring(0, 80)}…' : oneLine;
}

/// Fetches a gated stream [handle] to the stream cache and returns the
/// file path (null when the fetch fails).
///
/// Cache dir is `<temp>/stream_cache` (never the download dir, so a
/// stream-while-downloading never collides with queue targets); files
/// are reused across sessions (`<videoId>.<ext>`, extension from the
/// handle MIME). Never throws.
Future<String?> _streamFallbackFile(
  YtdlpProvider ytdlp, {
  required Track track,
  required MediaHandle handle,
}) async {
  try {
    if (track.providerId != ytdlp.id || handle.isLocalFile) {
      return null;
    }
    if (handle.uri.isEmpty) {
      return null;
    }
    final tmp = await getTemporaryDirectory();
    final dir = Directory(
      '${tmp.path}${Platform.pathSeparator}stream_cache',
    );
    await dir.create(recursive: true);
    final mime = (handle.mimeType ?? '').toLowerCase();
    final ext = (mime.contains('opus') || mime.contains('webm'))
        ? 'webm'
        : 'm4a';
    final file = File(
      '${dir.path}${Platform.pathSeparator}${track.sourceTrackId}.$ext',
    );
    // Single cache-hit probe per fallback, off the UI isolate.
    // ignore: avoid_slow_async_io
    if (await file.exists() && await file.length() > 0) {
      developer.log(
        'stream fallback cache hit vid=${track.sourceTrackId}',
        name: 'AURORA_DIAG',
      );
      return file.path;
    }
    final host = Uri.tryParse(handle.uri)?.host ?? '?';
    developer.log(
      'stream fallback fetch vid=${track.sourceTrackId} host=$host ext=$ext',
      name: 'AURORA_DIAG',
    );
    final downloaded = await ytdlp.explode.downloadUrl(
      url: handle.uri,
      videoId: track.sourceTrackId,
      outputDir: dir,
      fileExt: ext,
    );
    return downloaded.valueOrNull;
  } on Exception {
    return null;
  }
}

/// One download transfer for the queue manager.
///
/// Local files are copied byte-for-byte (never moved); yt-dlp tracks
/// go through the audio-only CLI downloader. Anything else fails with
/// a clear provider error instead of hanging the queue.
Future<Result<String, AppError>> _executeDownload(
  YtdlpDownloader downloader, {
  required Track track,
  required Quality quality,
  required Directory outputDir,
  required void Function(double progress) onProgress,
}) async {
  if (track.providerId == 'local' && track.hasLocalFile) {
    final src = File(track.localPath!);
    if (!src.existsSync()) {
      return const Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Original file is missing',
          details: 'downloads:file-missing',
        ),
      );
    }
    final safeId = track.id.replaceAll(RegExp('[^A-Za-z0-9_-]'), '_');
    final dot = track.localPath!.lastIndexOf('.');
    final ext = dot >= 0 ? track.localPath!.substring(dot) : '.m4a';
    final sep = Platform.pathSeparator;
    final tmp = File('${outputDir.path}$sep$safeId.part');
    final dst = File('${outputDir.path}$sep$safeId$ext');
    await outputDir.create(recursive: true);
    await src.copy(tmp.path);
    onProgress(1);
    await tmp.rename(dst.path);
    return Success(
      await _friendlyDownloadPath(
        outputDir,
        track.title,
        ext,
        dst,
      ),
    );
  }
  if (track.providerId == 'ytdlp') {
    final result = await downloader.download(
      YtdlpDownloadRequest(
        videoId: track.sourceTrackId,
        outputDir: outputDir,
        quality: quality,
      ),
      onProgress: onProgress,
    );
    switch (result) {
      case Failure(:final error):
        return Failure(error);
      case Success(value: final outcome):
        final path = await _friendlyDownloadPath(
          outputDir,
          track.title,
          '.m4a',
          File(outcome.filePath),
        );
        return Success(path);
    }
  }
  return const Failure(
    AppError(
      code: AppErrorCode.provider,
      message: 'Downloads support local and online tracks in v1',
      details: 'downloads:unsupported-provider',
    ),
  );
}

Future<String> _friendlyDownloadPath(
  Directory outputDir,
  String rawTitle,
  String extension,
  File source,
) async {
  final title = rawTitle.trim().isEmpty ? 'Untitled' : rawTitle.trim();
  final safe = title
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'[.]$'), '');
  final base = safe.isEmpty ? 'Untitled' : safe;
  var target = File(
    '${outputDir.path}${Platform.pathSeparator}$base$extension',
  );
  if (source.path != target.path && target.existsSync()) {
    var index = 2;
    while (File(
      '${outputDir.path}${Platform.pathSeparator}$base ($index)$extension',
    ).existsSync()) {
      index++;
    }
    target = File(
      '${outputDir.path}${Platform.pathSeparator}$base ($index)$extension',
    );
  }
  if (source.path != target.path) {
    await source.rename(target.path);
  }
  return target.path;
}

/// Queue persistence over `QueueDao`.
///
/// The resume pointer (`playback_state` single row) has no DAO in the
/// database package yet, so position restore stays in memory — see
/// known gaps. Queue order itself survives process death.
final class _DbPlaybackStore implements PlaybackStore {
  /// Creates the store over the database.
  _DbPlaybackStore(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  StoredPlayback? _memoryState;

  @override
  Future<StoredQueue> loadQueue() async {
    final rows = await _db.queueDao.ordered();
    if (rows.isEmpty) {
      return StoredQueue.empty;
    }
    return StoredQueue(
      items: <QueueItem>[
        for (final row in rows)
          QueueItem(
            id: row.id,
            trackId: row.trackId ?? '',
            origin:
                PlaySource.values.asNameMap()[row.origin] ?? PlaySource.queue,
            addedAt: DateTime.fromMillisecondsSinceEpoch(
              row.addedAt ?? 0,
              isUtc: true,
            ),
            frozenScore: row.frozenScore,
          ),
      ],
      // Playhead index is not persisted (no DAO for the single
      // resume row yet); restore starts at the head — known gap.
      index: 0,
    );
  }

  @override
  Future<void> saveQueue(StoredQueue snapshot) async {
    await _db.queueDao.replaceAll(<QueueItemsCompanion>[
      for (var i = 0; i < snapshot.items.length; i++)
        QueueItemsCompanion(
          id: Value(snapshot.items[i].id),
          trackId: Value(snapshot.items[i].trackId),
          origin: Value(snapshot.items[i].origin.name),
          position: Value(i),
          frozenScore: Value(snapshot.items[i].frozenScore),
          addedAt: Value(
            snapshot.items[i].addedAt.toUtc().millisecondsSinceEpoch,
          ),
        ),
    ]);
  }

  @override
  Future<StoredPlayback?> loadState() async => _memoryState;

  @override
  Future<void> saveState(StoredPlayback state) async {
    _memoryState = state;
  }
}

/// Search boundary over the on-device FTS index + yt-dlp provider.
final class _WiredCatalogSearchService implements CatalogSearchService {
  /// Creates the service.
  _WiredCatalogSearchService(this._wiring);

  final AuroraWiring _wiring;

  @override
  Future<SearchPage> searchLocal(SearchQuery query) async {
    final text = query.text.trim();
    final now = _wiring.clock.nowUtc();
    if (text.length < 2) {
      return SearchPage(providerId: 'local', fetchedAt: now);
    }
    final rows = await _wiring.db.searchDao.searchTracksFts(
      text,
      limit: query.limit,
    );
    final tracks = <Track>[];
    for (final row in rows) {
      tracks.add(
        DbMappers.toTrack(
          row,
          artistIds: await _wiring.db.tracksDao.artistIdsFor(row.id),
          genreIds: await _wiring.db.tracksDao.genreIdsFor(row.id),
        ),
      );
    }
    final lower = text.toLowerCase();
    final artists = <Artist>[
      for (final row in await _wiring.db.artistsDao.listAll())
        if (row.name.toLowerCase().contains(lower)) DbMappers.toArtist(row),
    ];
    final albums = <Album>[
      for (final row in await _wiring.db.albumsDao.listAll())
        if (row.title.toLowerCase().contains(lower)) DbMappers.toAlbum(row),
    ];
    for (final artist in artists) {
      _wiring.artistNames[artist.id] = artist.name;
    }
    unawaited(
      _wiring.db.searchDao.addHistory(
        SearchHistoryCompanion(
          id: Value(AuroraIds.newId()),
          query: Value(text),
          createdAt: Value(_wiring.clock.nowEpochMs()),
        ),
      ),
    );
    return SearchPage(
      providerId: 'local',
      fetchedAt: now,
      tracks: tracks,
      artists: artists.take(query.limit).toList(),
      albums: albums.take(query.limit).toList(),
    );
  }

  @override
  Future<SearchPage> searchOnline(SearchQuery query) async {
    final now = _wiring.clock.nowUtc();
    if (query.text.trim().length < 2) {
      return SearchPage(providerId: 'ytdlp', fetchedAt: now);
    }
    final health = await _wiring.ytdlp.checkHealth();
    if (health != ProviderHealth.online && health != ProviderHealth.degraded) {
      return SearchPage(providerId: 'ytdlp', fetchedAt: now);
    }
    Result<SearchPage, AppError> result;
    try {
      result = await _wiring.ytdlp.search(query);
    } on Object catch (error) {
      // Defense in depth: the provider chain catches Object per
      // runtime and should never throw, but an escaping Error must
      // still surface as a typed search failure (which runtimes ran),
      // never as a raw crash in the Search tab.
      throw AppException(
        AppError(
          code: AppErrorCode.network,
          message: 'Online search failed (${_shortSearchCause(error)})',
          details: 'ytdlp:search-exit',
          cause: error,
        ),
      );
    }
    return result.fold(
      (page) {
        for (final artist in page.artists) {
          _wiring.artistNames[artist.id] = artist.name;
        }
        return page;
      },
      // Never swallow provider failures into an empty page: throw
      // the typed error so the Search tab shows the real reason
      // (which mirror failed, timeout, ...) instead of silence.
      (error) => throw AppException(error),
    );
  }

  @override
  Stream<ProviderHealth> onlineHealth() => _wiring.ytdlp.health();
}

/// Search row actions over the playback controller + download queue.
final class _WiredSearchActions implements SearchActions {
  /// Creates the actions.
  _WiredSearchActions(this._wiring);

  final AuroraWiring _wiring;

  @override
  String artistLine(Track track) => _wiring.artistLineFor(track);

  @override
  String? artworkUrlFor(Track track) {
    if (track.providerId != _wiring.ytdlp.id) {
      return null;
    }
    final url = _wiring.ytdlp.searcher.artworkByVideoId[track.sourceTrackId];
    return url == null || url.isEmpty ? null : url;
  }

  @override
  Future<String?> playStream(Track track) async {
    await _wiring.playback.playTrack(track);
    // `playTrack` awaits the full resolve+load, so the controller info
    // already carries the concrete failure (which runtime + why) when
    // the item could not start. Null means playback started.
    final info = _wiring.playback.info;
    if (info.status == PlaybackStatus.error) {
      final message = info.errorMessage;
      return message == null || message.isEmpty ? 'Playback failed' : message;
    }
    return null;
  }

  @override
  Future<String?> enqueueDownload(Track track, Quality quality) async {
    await _ensureOnlineTrackStored(_wiring, track);
    final result = await _wiring.downloads.enqueue(
      trackId: track.id,
      quality: quality,
    );
    // Null means the job was queued; otherwise the short enqueue
    // refusal (quota, missing track, ...) for a snackbar.
    return result.fold((_) => null, (error) => error.message);
  }

  @override
  DownloadState? downloadStateFor(String trackId) =>
      _wiring.jobsByTrack[trackId]?.state;

  @override
  double downloadProgressFor(String trackId) =>
      _wiring.jobsByTrack[trackId]?.progress ?? 0;
}

/// Download queue boundary over [DownloadManager].
final class _WiredDownloadsService implements DownloadsService {
  /// Creates the service.
  _WiredDownloadsService(this._wiring);

  final AuroraWiring _wiring;

  @override
  Stream<List<DownloadJob>> watchJobs() async* {
    yield await _wiring.downloads.listAll();
    yield* _wiring.downloads.changes;
  }

  @override
  Future<String?> trackTitle(String trackId) async {
    final track = await _wiring.resolveTrack(trackId);
    return track?.title;
  }

  @override
  Future<void> pause(String jobId) => _wiring.downloads.pause(jobId);

  @override
  Future<void> resume(String jobId) => _wiring.downloads.resume(jobId);

  @override
  Future<void> retry(String jobId) => _wiring.downloads.retry(jobId);

  @override
  Future<void> cancel(String jobId) => _wiring.downloads.cancel(jobId);

  @override
  void updateDownloadSettings({
    bool? wifiOnly,
    Quality? quality,
    int? concurrency,
  }) {
    _wiring.downloads.updateSettings(
      _wiring.downloads.settings.copyWith(
        wifiOnly: wifiOnly,
        quality: quality,
        concurrency: concurrency,
      ),
    );
  }

  @override
  Future<(DownloadLocation, String)> restoreDownloadLocation() async {
    var location = DownloadLocation.appPrivate;
    try {
      final prefs = await SharedPreferences.getInstance();
      location =
          DownloadLocation.fromName(
            prefs.getString(downloadLocationPrefsKey),
          ) ??
          DownloadLocation.appPrivate;
    } on Exception {
      location = DownloadLocation.appPrivate;
    }
    try {
      final dir = await resolveDownloadDir(location);
      _wiring.downloads.outputDir = dir;
      return (location, dir.path);
    } on Exception {
      return (location, _wiring.downloads.outputDir.path);
    }
  }

  @override
  Future<String> setDownloadLocation(DownloadLocation location) async {
    final dir = await resolveDownloadDir(location);
    _wiring.downloads.outputDir = dir;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(downloadLocationPrefsKey, location.name);
    } on Exception {
      // The in-memory folder switch stands without persistence.
    }
    return dir.path;
  }
}

/// Library boundary over playlists/tracks/artists/albums DAOs.
///
/// Streams are one-shot reads re-emitted after every local mutation
/// (the DAOs expose futures, not watches); external writers such as
/// the scanner invalidate by re-reading on next subscribe.
final class _WiredLibraryService implements LibraryService {
  /// Creates the service.
  _WiredLibraryService(this._wiring);

  /// Shared wiring.
  final AuroraWiring _wiring;

  final StreamController<void> _ticks = StreamController<void>.broadcast();

  Stream<List<T>> _watched<T>(Future<List<T>> Function() read) async* {
    yield await read();
    await for (final _ in _ticks.stream) {
      yield await read();
    }
  }

  void _ping() {
    if (!_ticks.isClosed) {
      _ticks.add(null);
    }
  }

  /// Re-reads every library stream (call when downloads complete, etc.).
  void ping() => _ping();

  Future<List<Track>> _resolveIds(List<String> ids) async {
    final out = <Track>[];
    for (final id in ids) {
      final track = await _wiring.resolveTrack(id);
      if (track != null) {
        out.add(track);
      }
    }
    return out;
  }

  @override
  Stream<List<Track>> watchLiked() => _watched(() async {
    // Source of truth is `user_track_stats.like_state == 1`: every
    // like path (library, home, now-playing/playback writer) persists
    // there, while nothing ever wrote the legacy `liked`
    // system-playlist entries (so that query alone stays empty
    // forever). The legacy entries union first for backward
    // compatibility; stats likes follow most-recent first.
    final seen = <String>{};
    final ordered = <String>[];
    try {
      final entries = await _wiring.db.playlistsDao.entriesFor('liked');
      for (final e in entries) {
        if (seen.add(e.trackId)) {
          ordered.add(e.trackId);
        }
      }
    } on Exception {
      // Legacy entries are best-effort; stats likes below still apply.
    }
    for (final id in await _likedTrackIds(_wiring)) {
      if (seen.add(id)) {
        ordered.add(id);
      }
    }
    return _resolveIds(ordered);
  });

  @override
  Stream<List<Playlist>> watchPlaylists() => _watched(() async {
    final rows = await _wiring.db.playlistsDao.listAll();
    return [for (final row in rows) DbMappers.toPlaylist(row)];
  });

  @override
  Stream<List<Album>> watchAlbums() => _watched(() async {
    final rows = await _wiring.db.albumsDao.listAll();
    return [for (final row in rows) DbMappers.toAlbum(row)];
  });

  @override
  Stream<List<Artist>> watchArtists() => _watched(() async {
    final rows = await _wiring.db.artistsDao.listAll();
    for (final row in rows) {
      _wiring.artistNames[row.id] = row.name;
    }
    return [for (final row in rows) DbMappers.toArtist(row)];
  });

  @override
  Stream<List<Track>> watchDownloads() => _watched(() async {
    final jobs = await _wiring.downloads.completedJobs();
    // Library shows verified downloads only (failed/canceled stay
    // on the Downloads tab with retry).
    return _resolveIds([
      for (final job in jobs)
        if (job.state == DownloadState.completed) job.trackId,
    ]);
  });

  @override
  Stream<List<Track>> watchRecentlyPlayed() => _watched(() async {
    final stats = await _wiring.db.statsDao.recentlyPlayed(limit: 50);
    return _resolveIds([for (final s in stats) s.trackId]);
  });

  @override
  Future<List<String>> playlistTrackIds(String playlistId) async {
    final entries = await _wiring.db.playlistsDao.entriesFor(playlistId);
    return [for (final e in entries) e.trackId];
  }

  @override
  Future<Playlist> createPlaylist(String title) async {
    final now = _wiring.clock.nowEpochMs();
    final playlist = Playlist(
      id: AuroraIds.newId(),
      title: title,
      createdAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
    );
    await _wiring.db.playlistsDao.upsertPlaylist(
      PlaylistsCompanion(
        id: Value(playlist.id),
        title: Value(title),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    _ping();
    return playlist;
  }

  @override
  Future<void> renamePlaylist(String playlistId, String title) async {
    final existing = await _wiring.db.playlistsDao.getById(playlistId);
    if (existing == null || existing.isSystem == 1) {
      return;
    }
    await _wiring.db.playlistsDao.upsertPlaylist(
      PlaylistsCompanion(
        id: Value(existing.id),
        title: Value(title),
        description: Value(existing.description),
        artworkId: Value(existing.artworkId),
        isSystem: Value(existing.isSystem),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(_wiring.clock.nowEpochMs()),
      ),
    );
    _ping();
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    await _wiring.db.playlistsDao.deletePlaylist(playlistId);
    _ping();
  }

  @override
  Future<void> addToPlaylist(String playlistId, String trackId) async {
    final entries = await _wiring.db.playlistsDao.entriesFor(playlistId);
    await _wiring.db.playlistsDao.addEntry(
      PlaylistEntriesCompanion(
        playlistId: Value(playlistId),
        trackId: Value(trackId),
        position: Value(entries.length),
        addedAt: Value(_wiring.clock.nowEpochMs()),
      ),
    );
    _ping();
  }

  @override
  Future<void> removeFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    await _wiring.db.playlistsDao.removeEntry(playlistId, trackId);
    _ping();
  }

  @override
  Future<void> reorderEntry(String playlistId, int from, int to) async {
    final entries = await _wiring.db.playlistsDao.entriesFor(playlistId);
    if (from < 0 || from >= entries.length || to < 0 || to >= entries.length) {
      return;
    }
    final ordered = entries.toList();
    final entry = ordered.removeAt(from);
    ordered.insert(to, entry);
    for (var i = 0; i < ordered.length; i++) {
      await _wiring.db.playlistsDao.addEntry(
        PlaylistEntriesCompanion(
          playlistId: Value(playlistId),
          trackId: Value(ordered[i].trackId),
          position: Value(i),
          addedAt: Value(ordered[i].addedAt),
        ),
      );
    }
    _ping();
  }

  @override
  Future<M3uImportResult> importM3u() async {
    // No file-picker dependency is wired in this integration pass;
    // report an honest empty import instead of failing the tab.
    return const M3uImportResult(
      playlistId: '',
      imported: 0,
      missing: 0,
    );
  }

  static String _extractPlaylistId(String input) {
    final trimmed = input.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.queryParameters.containsKey('list')) {
      final listParam = uri.queryParameters['list']!.trim();
      if (listParam.isNotEmpty) {
        return _stripBrowsePrefix(listParam);
      }
    }
    return _stripBrowsePrefix(trimmed);
  }

  /// Strips the `VL` browse prefix YouTube Music uses for library
  /// playlists (`VL<id>` → `<id>`); anything else passes through.
  static String _stripBrowsePrefix(String id) =>
      id.startsWith('VL') && id.length > 2 ? id.substring(2) : id;

  static String _slug(String raw) => raw
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  @override
  Future<Playlist?> importYouTubePlaylist(String urlOrId) async {
    final input = urlOrId.trim();
    if (input.isEmpty) {
      return null;
    }
    final playlistId = _extractPlaylistId(input);

    Map<String, dynamic>? data;
    try {
      data = await _wiring.ytdlp.newpipe.playlist(input);
    } on Object catch (_) {
      data = null;
    }

    if (data == null || (data['items'] as List?)?.isEmpty == true) {
      final piped = _wiring.ytdlp.explode.pipedSearch;
      try {
        data = await piped.getPlaylist(playlistId);
      } on Object catch (_) {
        data = null;
      }
    }

    if (data == null) {
      return null;
    }

    final rawItems = data['items'];
    if (rawItems is! List || rawItems.isEmpty) {
      return null;
    }

    final rawTitle = data['title'] as String?;
    final title = (rawTitle != null && rawTitle.trim().isNotEmpty)
        ? rawTitle.trim()
        : 'YouTube Playlist';

    // YouTube playlist imports are idempotent. A stable local id lets a
    // second tap open the already-imported list instead of creating a copy.
    final stableId = 'ytm:$playlistId';
    final existing = await _wiring.db.playlistsDao.getById(stableId);
    if (existing != null) {
      return DbMappers.toPlaylist(existing);
    }
    final now = _wiring.clock.nowUtc();
    final nowMs = _wiring.clock.nowEpochMs();
    await _wiring.db.playlistsDao.upsertPlaylist(
      PlaylistsCompanion(
        id: Value(stableId),
        title: Value(title),
        createdAt: Value(nowMs),
        updatedAt: Value(nowMs),
      ),
    );
    final playlist = Playlist(
      id: stableId,
      title: title,
      createdAt: now,
      updatedAt: now,
    );

    for (final rawItem in rawItems) {
      if (rawItem is! Map) {
        continue;
      }
      final videoId = rawItem['videoId'] as String?;
      if (videoId == null || videoId.trim().isEmpty) {
        continue;
      }
      final itemTitle = (rawItem['title'] as String?)?.trim();
      final uploader = (rawItem['uploader'] as String?)?.trim() ?? '';
      final channelId = (rawItem['channelId'] as String?)?.trim() ?? '';
      final durationSec = rawItem['durationSec'] is num
          ? (rawItem['durationSec'] as num).toInt()
          : 0;

      final trackId = AuroraIds.trackId('ytdlp', videoId.trim());
      final artistId = uploader.isNotEmpty
          ? AuroraIds.trackId(
              'ytdlp',
              channelId.isNotEmpty
                  ? 'channel-$channelId'
                  : 'channel-${_slug(uploader)}',
            )
          : null;

      if (artistId != null && uploader.isNotEmpty) {
        _wiring.artistNames[artistId] = uploader;
      }

      final track = Track(
        id: trackId,
        providerId: 'ytdlp',
        sourceTrackId: videoId.trim(),
        title: (itemTitle != null && itemTitle.isNotEmpty)
            ? itemTitle
            : 'Untitled',
        createdAt: now,
        updatedAt: now,
        durationMs: durationSec <= 0 ? 0 : durationSec * 1000,
        artistIds: artistId != null ? <String>[artistId] : const <String>[],
      );

      await _wiring.ensureTrackStored(track);
      await addToPlaylist(playlist.id, track.id);
    }

    _ping();
    return playlist;
  }

  @override
  String artistLine(Track track) => _wiring.artistLineFor(track);

  @override
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) =>
      _wiring.playback.playQueue(
        tracks,
        startIndex: startIndex,
        origin: PlaySource.library,
      );

  @override
  int likeStateFor(String trackId) => _wiring.likeStates[trackId] ?? 0;

  @override
  Future<void> setLike(String trackId, int likeState) async {
    _wiring.likeStates[trackId] = likeState;
    await _wiring.db.statsDao.setLikeState(
      trackId,
      likeState: likeState,
      updatedAt: _wiring.clock.nowEpochMs(),
    );
    _ping();
  }
}

/// Home boundary over reco snapshots with a local-data fallback.
///
/// Until the ComputeHomeSnapshots use-case persists snapshots, every
/// surface falls back to decayed-score / recency stats so Home stays
/// populated from local data only (Phase 4 DoD), marked with `cold`
/// or `replay` reasons.
final class _WiredHomeRecoService implements HomeRecoService {
  /// Creates the service.
  _WiredHomeRecoService(this._wiring);

  final AuroraWiring _wiring;

  Future<List<HomeRecoEntry>> _fromStats({
    required int limit,
    required bool recentFirst,
  }) async {
    final stats = recentFirst
        ? await _wiring.db.statsDao.recentlyPlayed(limit: limit)
        : await _wiring.db.statsDao.topByDecayedScore(limit: limit);
    final out = <HomeRecoEntry>[];
    for (final stat in stats) {
      final row = DbMappers.toStats(stat);
      final track = await _wiring.resolveTrack(row.trackId);
      if (track == null) {
        continue;
      }
      out.add(
        HomeRecoEntry(
          track: track,
          score: row.decayedScore.clamp(0, 1).toDouble(),
          reasons: <HomeWhyReason>[
            HomeWhyReason(
              key: recentFirst ? 'recency' : 'replay',
              contribution: row.decayedScore,
            ),
          ],
        ),
      );
    }
    return out;
  }

  @override
  Future<List<HomeRecoEntry>> entriesFor(String surface) async {
    final snapshot = await _wiring.db.recoSnapshotsDao.bySurface(surface);
    final raw = snapshot?.json;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final out = <HomeRecoEntry>[];
          for (final item in decoded) {
            if (item is! Map<String, dynamic>) {
              continue;
            }
            final id = item['trackId'];
            if (id is! String) {
              continue;
            }
            final track = await _wiring.resolveTrack(id);
            if (track == null) {
              continue;
            }
            final score = item['score'];
            out.add(
              HomeRecoEntry(
                track: track,
                score: ((score is num) ? score : 0).clamp(0, 1).toDouble(),
                reasons: const <HomeWhyReason>[
                  HomeWhyReason(key: 'cold', contribution: 0),
                ],
              ),
            );
          }
          if (out.isNotEmpty) {
            return out;
          }
        }
      } on FormatException {
        // Fall through to the stats fallback below.
      }
    }
    if (surface == HomeSurfaces.recentlyPlayed ||
        surface == HomeSurfaces.continueListening) {
      return _fromStats(limit: 20, recentFirst: true);
    }
    return _fromStats(limit: 20, recentFirst: false);
  }

  @override
  Future<List<ContinueItem>> continueListening() async {
    // Album/playlist progress aggregation is not wired yet.
    return const <ContinueItem>[];
  }

  @override
  Future<void> recompute() async {
    // Coalesce pull-to-refresh through the scheduler; the full
    // snapshot recompute use-case is a known gap, so this pass
    // prunes stale cache rows instead of blocking the header.
    await _wiring.recoScheduler.flushNow(() async {
      await _wiring.db.cacheDao.deleteExpired(_wiring.clock.nowEpochMs());
    });
  }

  @override
  Stream<ProviderHealth> onlineHealth() => _wiring.ytdlp.health();
}

/// Home row/card actions over the playback controller.
final class _WiredHomeActions implements HomeActions {
  /// Creates the actions.
  _WiredHomeActions(this._wiring);

  final AuroraWiring _wiring;

  @override
  String artistLine(Track track) => _wiring.artistLineFor(track);

  @override
  Future<void> playTracks(
    List<Track> tracks, {
    int startIndex = 0,
    PlaySource origin = PlaySource.reco,
  }) => _wiring.playback.playQueue(
    tracks,
    startIndex: startIndex,
    origin: origin,
  );

  @override
  int likeStateFor(String trackId) => _wiring.likeStates[trackId] ?? 0;

  @override
  Future<void> setLike(String trackId, int likeState) async {
    _wiring.likeStates[trackId] = likeState;
    await _wiring.db.statsDao.setLikeState(
      trackId,
      likeState: likeState,
      updatedAt: _wiring.clock.nowEpochMs(),
    );
    // Home has no stream of its own: ping the library streams so the
    // Liked tab refreshes after a Home-surface like.
    _wiring.onLibraryInvalidated?.call();
  }
}

/// Now Playing boundary over [PlaybackController] frames.
final class _WiredNowPlayingService implements NowPlayingService {
  /// Creates the service.
  _WiredNowPlayingService(this._wiring);

  final AuroraWiring _wiring;

  NowPlayingInfo _frame(PlaybackInfo info) {
    final controller = _wiring.playback;
    final items = controller.queue.items;
    final queue = <Track>[
      for (final item in items)
        if (controller.queue.trackById(item.trackId) != null)
          controller.queue.trackById(item.trackId)!,
    ];
    final track = info.track;
    return NowPlayingInfo(
      isPlaying: info.isPlaying,
      position: info.position,
      duration: info.duration,
      shuffle: info.shuffle,
      repeat: switch (info.repeatMode) {
        RepeatMode.off => RepeatSetting.off,
        RepeatMode.one => RepeatSetting.one,
        RepeatMode.all => RepeatSetting.all,
      },
      likeState: track == null ? 0 : _wiring.likeStates[track.id] ?? 0,
      badge: track == null
          ? SourceBadge.local
          : track.isDownloaded
          ? SourceBadge.downloaded
          : track.providerId == 'local'
          ? SourceBadge.local
          : SourceBadge.stream,
      useStream: _wiring.useStream,
      radioEnabled: controller.radioEnabled,
      track: track,
      downloadState: track == null
          ? null
          : _wiring.jobsByTrack[track.id]?.state,
      downloadProgress: track == null
          ? 0
          : _wiring.jobsByTrack[track.id]?.progress ?? 0,
      queue: queue,
      currentIndex: controller.queue.currentIndex,
      volume: info.volume,
    );
  }

  @override
  Stream<NowPlayingInfo> watch() => _wiring.playback.stream.map(_frame);

  @override
  Future<void> toggle() => _wiring.playback.toggle();

  @override
  Future<void> next() => _wiring.playback.next();

  @override
  Future<void> previous() => _wiring.playback.previous();

  @override
  Future<void> seek(Duration position) => _wiring.playback.seek(position);

  @override
  Future<void> setVolume(double volume) => _wiring.playback.setVolume(volume);

  @override
  Future<void> setShuffle({required bool enabled}) =>
      _wiring.playback.setShuffle(enabled: enabled);

  @override
  Future<void> cycleRepeat() {
    final next = switch (_wiring.playback.info.repeatMode) {
      RepeatMode.off => RepeatMode.one,
      RepeatMode.one => RepeatMode.all,
      RepeatMode.all => RepeatMode.off,
    };
    return _wiring.playback.setRepeat(next);
  }

  @override
  Future<void> setLike(int likeState) async {
    final track = _wiring.playback.info.track;
    if (likeState == 1) {
      await _wiring.playback.likeCurrent();
    } else if (likeState == -1) {
      await _wiring.playback.dislikeCurrent();
    } else {
      await _wiring.playback.clearLikeCurrent();
    }
    if (track != null) {
      _wiring.likeStates[track.id] = likeState;
    }
    // The playback like-writer already pings, but this covers wirings
    // without it: the Liked tab must refresh after a heart tap.
    _wiring.onLibraryInvalidated?.call();
  }

  @override
  Future<void> setUseStream({required bool useStream}) async {
    _wiring.useStream = useStream;
  }

  @override
  Future<void> download(Quality quality) async {
    final track = _wiring.playback.info.track;
    if (track == null) {
      return;
    }
    await _ensureOnlineTrackStored(_wiring, track);
    await _wiring.downloads.enqueue(trackId: track.id, quality: quality);
  }

  @override
  Future<void> reorderQueue(int from, int to) async {
    final base = _wiring.playback.queue.currentIndex + 1;
    _wiring.playback.queue.move(base + from, base + to);
  }

  @override
  Future<void> setRadioEnabled({required bool enabled}) async {
    _wiring.playback.radioEnabled = enabled;
  }

  @override
  String artistLine(Track track) => _wiring.artistLineFor(track);
}

/// You-tab boundary over events/stats/playlists DAOs.
///
/// Mix rates, decay half-life, and cache budget are session-local in
/// this pass (spec defaults at startup); persisting them is a known
/// gap. The network log stays empty until provider calls are logged
/// through this layer.
final class _WiredYouService implements YouService {
  /// Creates the service.
  _WiredYouService(this._wiring);

  final AuroraWiring _wiring;

  MixRates _rates = (
    exploitation: AuroraDefaults.exploitationRate,
    adjacent: AuroraDefaults.adjacentRate,
    exploration: AuroraDefaults.explorationRate,
  );
  double _halfLife = AuroraDefaults.decayHalfLifeDays;
  int _cacheMb = AuroraDefaults.artworkCacheMb;

  @override
  Future<YouStats> stats() async {
    final events = await _wiring.db.eventsDao.latest(limit: 500);
    var listenedMs = 0;
    final distinct = <String>{};
    for (final row in events) {
      distinct.add(row.trackId);
      listenedMs += row.listenedMs ?? 0;
    }
    final liked = await _wiring.db.statsDao.topByDecayedScore(limit: 500);
    var likeCount = 0;
    for (final row in liked) {
      if (DbMappers.toStats(row).likeState == 1) {
        likeCount++;
      }
    }
    final playlists = await _wiring.db.playlistsDao.listAll();
    return YouStats(
      tracksPlayed: distinct.length,
      minutesListened: listenedMs ~/ 60000,
      likeCount: likeCount,
      playlistCount: [
        for (final p in playlists)
          if (!DbMappers.toPlaylist(p).isSystem) p,
      ].length,
    );
  }

  @override
  Future<MixRates> mixRates() async => _rates;

  @override
  Future<void> setMixRates(MixRates rates) async {
    _rates = rates;
  }

  @override
  Future<double> decayHalfLifeDays() async => _halfLife;

  @override
  Future<void> setDecayHalfLifeDays(double days) async {
    _halfLife = days.clamp(7, 180).toDouble();
  }

  @override
  Future<int> cacheMb() async => _cacheMb;

  @override
  Future<void> setCacheMb(int megabytes) async {
    _cacheMb = megabytes;
  }

  @override
  Future<String> exportJson() async {
    final events = await _wiring.db.eventsDao.latest(limit: 500);
    final playlists = await _wiring.db.playlistsDao.listAll();
    final payload = <String, Object?>{
      'exportedAt': _wiring.clock.nowUtc().toIso8601String(),
      'events': [
        for (final row in events) DbMappers.toPlayEvent(row).toJson(),
      ],
      'playlists': [
        for (final row in playlists) DbMappers.toPlaylist(row).toJson(),
      ],
    };
    return jsonEncode(payload);
  }

  @override
  Future<void> resetRecommendations() async {
    await _wiring.db.statsDao.resetScores(_wiring.clock.nowEpochMs());
    await _wiring.db.profileDao.deleteProfile();
  }

  @override
  Future<void> deleteHistory() async {
    await _wiring.db.eventsDao.deleteAll();
    await _wiring.db.searchDao.clearHistory();
  }

  @override
  Future<void> deleteEverything() async {
    await deleteHistory();
    await _wiring.db.profileDao.deleteProfile();
    final playlists = await _wiring.db.playlistsDao.listAll();
    for (final row in playlists) {
      await _wiring.db.playlistsDao.deletePlaylist(row.id);
    }
    await _wiring.db.queueDao.clear();
  }

  @override
  List<NetworkCall> networkLog() => const <NetworkCall>[];
}
