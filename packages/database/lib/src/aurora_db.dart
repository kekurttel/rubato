import 'dart:io';

import 'package:aurora_core/aurora_core.dart'
    show Clock, FakeClock, SystemClock;
import 'package:aurora_database/src/daos/activity_daos.dart';
import 'package:aurora_database/src/daos/catalog_daos.dart';
import 'package:aurora_database/src/daos/system_daos.dart';
import 'package:aurora_database/src/tables/catalog_tables.dart';
import 'package:aurora_database/src/tables/library_tables.dart';
import 'package:aurora_database/src/tables/system_tables.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'aurora_db.g.dart';

/// Drift database, schema v1 (spec section 6).
///
/// - `PRAGMA journal_mode = WAL`, `busy_timeout = 2500`, `foreign_keys = ON`
///   are applied in [beforeOpen] on every open (including in-memory tests).
/// - Times are UTC epoch milliseconds; mappers convert to `DateTime`.
/// - `tracks_fts` (FTS5) is an external-content table over `tracks` kept
///   in sync by triggers for `title`; repos enrich `artist_names` /
///   `album_title` via [SearchDao.upsertFtsEntry] after each scan.
/// - DAOs hold no business logic; repositories compose them.
@DriftDatabase(
  tables: [
    Tracks,
    TrackArtists,
    TrackGenres,
    Artists,
    Albums,
    Genres,
    Artworks,
    Playlists,
    PlaylistEntries,
    PlayEvents,
    UserTrackStats,
    PreferenceProfile,
    QueueItems,
    PlaybackState,
    DownloadJobs,
    SearchHistory,
    RecoSnapshots,
    MetadataCache,
  ],
)
class AuroraDatabase extends _$AuroraDatabase {
  /// Opens over an explicit executor (tests inject in-memory here).
  AuroraDatabase(super.e, {this.clock = const SystemClock()});

  /// Opens the production file database under the app documents dir.
  ///
  /// Synchronous same-isolate open (not createInBackground): the background
  /// isolate open raced with the first concurrent queries at startup
  /// (PRAGMA journal_mode hit SQLITE_LOCKED). busy_timeout runs first so
  /// the WAL switch waits out stale locks instead of throwing.
  factory AuroraDatabase.openDefault({Clock clock = const SystemClock()}) =>
      AuroraDatabase(
        LazyDatabase(() async {
          final dir = await getApplicationDocumentsDirectory();
          final file = File(p.join(dir.path, 'aurora.db'));
          return NativeDatabase(
            file,
            setup: (rawDb) {
              rawDb
                ..execute('PRAGMA busy_timeout = 2500;')
                ..execute('PRAGMA journal_mode = WAL;')
                ..execute('PRAGMA foreign_keys = ON;');
            },
          );
        }),
        clock: clock,
      );

  /// Opens an in-memory database (migration + DAO tests).
  factory AuroraDatabase.inMemory({Clock? clock}) => AuroraDatabase(
    NativeDatabase.memory(
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    ),
    clock: clock ?? FakeClock(DateTime.utc(2026)),
  );

  /// Injectable clock for TTL checks (never `DateTime.now()` here).
  final Clock clock;

  /// Current epoch milliseconds (UTC).
  int get nowEpochMs => clock.nowEpochMs();

  /// Thin track + artist + album access.
  late final TracksDao tracksDao = TracksDao(this);

  /// Artist rows.
  late final ArtistsDao artistsDao = ArtistsDao(this);

  /// Album rows.
  late final AlbumsDao albumsDao = AlbumsDao(this);

  /// Cached cover-artwork rows.
  late final ArtworksDao artworksDao = ArtworksDao(this);

  /// Listening events.
  late final EventsDao eventsDao = EventsDao(this);

  /// Per-track rollups.
  late final StatsDao statsDao = StatsDao(this);

  /// Single-row taste profile.
  late final ProfileDao profileDao = ProfileDao(this);

  /// Playlists + entries.
  late final PlaylistsDao playlistsDao = PlaylistsDao(this);

  /// Persisted queue.
  late final QueueDao queueDao = QueueDao(this);

  /// Download jobs.
  late final DownloadsDao downloadsDao = DownloadsDao(this);

  /// FTS search + history.
  late final SearchDao searchDao = SearchDao(this);

  /// Reco snapshots.
  late final RecoSnapshotDao recoSnapshotsDao = RecoSnapshotDao(this);

  /// Metadata cache.
  late final CacheDao cacheDao = CacheDao(this);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexesAndFts();
    },
    onUpgrade: (m, from, to) async {
      // v1 is the first shipped schema; future versions add real
      // step-by-step migrations here with tests (spec Phase 6.1).
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode = WAL;');
      await customStatement('PRAGMA busy_timeout = 2500;');
      await customStatement('PRAGMA foreign_keys = ON;');
      // Fresh files created outside `onCreate` (e.g. restored backups)
      // still get indexes + FTS; `IF NOT EXISTS` keeps this idempotent.
      await _createIndexesAndFts();
    },
  );

  /// Creates spec section 6 indexes, the FTS5 table, and sync triggers.
  ///
  /// Idempotent (`IF NOT EXISTS`) so `beforeOpen` can safely re-run it.
  Future<void> _createIndexesAndFts() async {
    for (final statement in auroraIndexStatements) {
      await customStatement(statement);
    }
    await customStatement(auroraFtsStatement);
    for (final trigger in auroraFtsTriggers) {
      await customStatement(trigger);
    }
  }

  /// Spec section 6 indexes (exact columns).
  ///
  /// Each statement is a named constant so entries stay short; the list
  /// below only references them (adjacent literals inside a list would
  /// trip `no_adjacent_strings_in_list`).
  @visibleForTesting
  static const String idxPlayEventsTrackStarted =
      'CREATE INDEX IF NOT EXISTS idx_play_events_track_started '
      'ON play_events(track_id, started_at DESC)';

  /// Index on `play_events(started_at DESC)`.
  @visibleForTesting
  static const String idxPlayEventsStarted =
      'CREATE INDEX IF NOT EXISTS idx_play_events_started '
      'ON play_events(started_at DESC)';

  /// Index on `user_track_stats(decayed_score DESC)`.
  @visibleForTesting
  static const String idxStatsDecayed =
      'CREATE INDEX IF NOT EXISTS idx_stats_decayed '
      'ON user_track_stats(decayed_score DESC)';

  /// Index on `user_track_stats(last_played_at DESC)`.
  @visibleForTesting
  static const String idxStatsLastPlayed =
      'CREATE INDEX IF NOT EXISTS idx_stats_last_played '
      'ON user_track_stats(last_played_at DESC)';

  /// Index on `tracks(album_id)`.
  @visibleForTesting
  static const String idxTracksAlbum =
      'CREATE INDEX IF NOT EXISTS idx_tracks_album ON tracks(album_id)';

  /// Index on `tracks(title)`.
  @visibleForTesting
  static const String idxTracksTitle =
      'CREATE INDEX IF NOT EXISTS idx_tracks_title ON tracks(title)';

  /// Index on `download_jobs(state, updated_at)`.
  @visibleForTesting
  static const String idxDownloadsStateUpdated =
      'CREATE INDEX IF NOT EXISTS idx_downloads_state_updated '
      'ON download_jobs(state, updated_at)';

  /// Index on `playlist_entries(playlist_id, position)`.
  @visibleForTesting
  static const String idxPlaylistEntriesPos =
      'CREATE INDEX IF NOT EXISTS idx_playlist_entries_pos '
      'ON playlist_entries(playlist_id, position)';

  /// Index on `queue_items(position)`.
  @visibleForTesting
  static const String idxQueuePosition =
      'CREATE INDEX IF NOT EXISTS idx_queue_position ON queue_items(position)';

  /// All spec section 6 indexes in creation order.
  @visibleForTesting
  static const List<String> auroraIndexStatements = <String>[
    idxPlayEventsTrackStarted,
    idxPlayEventsStarted,
    idxStatsDecayed,
    idxStatsLastPlayed,
    idxTracksAlbum,
    idxTracksTitle,
    idxDownloadsStateUpdated,
    idxPlaylistEntriesPos,
    idxQueuePosition,
  ];

  /// FTS5 external-content table over `tracks` (spec section 6).
  @visibleForTesting
  static const String auroraFtsStatement =
      'CREATE VIRTUAL TABLE IF NOT EXISTS tracks_fts USING '
      "fts5(title, artist_names, album_title, content='tracks', "
      "content_rowid='rowid')";

  /// Trigger syncing `tracks_fts` after inserts.
  @visibleForTesting
  static const String trgTracksInsert =
      'CREATE TRIGGER IF NOT EXISTS tracks_ai AFTER INSERT ON tracks BEGIN '
      'INSERT INTO tracks_fts(rowid, title, artist_names, album_title) '
      "VALUES (new.rowid, new.title, '', ''); END";

  /// Trigger syncing `tracks_fts` after deletes.
  @visibleForTesting
  static const String trgTracksDelete =
      'CREATE TRIGGER IF NOT EXISTS tracks_ad AFTER DELETE ON tracks BEGIN '
      'INSERT INTO tracks_fts(tracks_fts, rowid, title, artist_names, '
      "album_title) VALUES('delete', old.rowid, old.title, '', ''); END";

  /// Trigger syncing `tracks_fts` after updates.
  @visibleForTesting
  static const String trgTracksUpdate =
      'CREATE TRIGGER IF NOT EXISTS tracks_au AFTER UPDATE ON tracks BEGIN '
      'INSERT INTO tracks_fts(tracks_fts, rowid, title, artist_names, '
      "album_title) VALUES('delete', old.rowid, old.title, '', ''); "
      'INSERT INTO tracks_fts(rowid, title, artist_names, album_title) '
      "VALUES (new.rowid, new.title, '', ''); END";

  /// Triggers keeping `tracks_fts.title` in sync.
  ///
  /// `artist_names` / `album_title` are enriched by explicit repo writes
  /// (see `SearchDao.upsertFtsEntry`) because triggers cannot cheaply
  /// join the credit tables on every scan batch.
  @visibleForTesting
  static const List<String> auroraFtsTriggers = <String>[
    trgTracksInsert,
    trgTracksDelete,
    trgTracksUpdate,
  ];
}
