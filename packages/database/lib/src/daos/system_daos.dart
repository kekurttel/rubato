import 'package:aurora_database/src/aurora_db.dart';
import 'package:drift/drift.dart';

/// Queue persistence (cap 200 enforced by callers, spec section 8).
class QueueDao {
  /// Creates the DAO.
  QueueDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Replaces the whole queue (persist every 5s + on pause/track change).
  Future<void> replaceAll(List<QueueItemsCompanion> entries) async {
    await _db.transaction(() async {
      await _db.delete(_db.queueItems).go();
      if (entries.isEmpty) {
        return;
      }
      final capped = entries.length > 200 ? entries.sublist(0, 200) : entries;
      await _db.batch((batch) {
        batch.insertAll(_db.queueItems, capped);
      });
    });
  }

  /// Current queue in position order.
  Future<List<DbQueueItem>> ordered() => (_db.select(
    _db.queueItems,
  )..orderBy([(q) => OrderingTerm.asc(q.position)])).get();

  /// Clears the queue (stop path).
  Future<int> clear() => _db.delete(_db.queueItems).go();
}

/// Download-job queue (state machine in spec section 12).
class DownloadsDao {
  /// Creates the DAO.
  DownloadsDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Inserts or replaces a job row.
  Future<void> upsertJob(DownloadJobsCompanion entry) =>
      _db.into(_db.downloadJobs).insertOnConflictUpdate(entry);

  /// Fetches a job by id.
  Future<DbDownloadJob?> getById(String id) => (_db.select(
    _db.downloadJobs,
  )..where((j) => j.id.equals(id))).getSingleOrNull();

  /// Jobs in one [state], newest-first.
  Future<List<DbDownloadJob>> byState(String state, {int limit = 100}) =>
      (_db.select(_db.downloadJobs)
            ..where((j) => j.state.equals(state))
            ..orderBy([(j) => OrderingTerm.desc(j.updatedAt)])
            ..limit(limit))
          .get();

  /// All jobs newest-first (Downloads tab).
  Future<List<DbDownloadJob>> listAll({int limit = 200}) =>
      (_db.select(_db.downloadJobs)
            ..orderBy([(j) => OrderingTerm.desc(j.updatedAt)])
            ..limit(limit))
          .get();

  /// Updates progress + counters of an active job.
  Future<int> updateProgress(
    String id, {
    required double progress,
    required int bytesReceived,
    required int updatedAt,
  }) => (_db.update(_db.downloadJobs)..where((j) => j.id.equals(id))).write(
    DownloadJobsCompanion(
      progress: Value(progress),
      bytesReceived: Value(bytesReceived),
      updatedAt: Value(updatedAt),
    ),
  );

  /// Transitions a job to [state] with optional error details.
  Future<int> setState(
    String id, {
    required String state,
    required int updatedAt,
    String? errorCode,
    String? errorMessage,
  }) => (_db.update(_db.downloadJobs)..where((j) => j.id.equals(id))).write(
    DownloadJobsCompanion(
      state: Value(state),
      errorCode: Value(errorCode),
      errorMessage: Value(errorMessage),
      updatedAt: Value(updatedAt),
    ),
  );
}

/// FTS search + search history (spec section 11).
class SearchDao {
  /// Creates the DAO.
  SearchDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Full-text track search over `tracks_fts` (title/artist/album).
  ///
  /// Falls back to an empty list when the FTS table is missing (fresh
  /// install before `onCreate` ran) instead of throwing into the UI.
  Future<List<DbTrack>> searchTracksFts(String query, {int limit = 20}) async {
    final escaped = query.replaceAll('"', '""');
    try {
      final rows = await _db
          .customSelect(
            'SELECT tracks.* FROM tracks '
            'JOIN tracks_fts ON tracks.rowid = tracks_fts.rowid '
            'WHERE tracks_fts MATCH ? '
            'LIMIT ?',
            variables: <Variable<Object>>[
              Variable<String>('"$escaped"*'),
              Variable<int>(limit),
            ],
            readsFrom: {_db.tracks},
          )
          .get();
      return <DbTrack>[
        for (final row in rows) _db.tracks.map(row.data),
      ];
    } on Exception {
      return <DbTrack>[];
    }
  }

  /// Upserts the FTS sidecar for one track (repo writes after insert).
  Future<void> upsertFtsEntry({
    required int rowId,
    required String title,
    String artistNames = '',
    String albumTitle = '',
  }) async {
    await _db.customStatement(
      'INSERT INTO tracks_fts(rowid, title, artist_names, album_title) '
      'VALUES (?, ?, ?, ?) '
      'ON CONFLICT(rowid) DO UPDATE SET '
      'title=excluded.title, artist_names=excluded.artist_names, '
      'album_title=excluded.album_title',
      <Object?>[rowId, title, artistNames, albumTitle],
    );
  }

  /// Records one search string.
  Future<void> addHistory(SearchHistoryCompanion entry) =>
      _db.into(_db.searchHistory).insertOnConflictUpdate(entry);

  /// Last [limit] searches, newest-first (cap 50 per spec).
  Future<List<DbSearchHistory>> recentHistory({int limit = 50}) =>
      (_db.select(_db.searchHistory)
            ..orderBy([(h) => OrderingTerm.desc(h.createdAt)])
            ..limit(limit))
          .get();

  /// Deletes one history row (swipe-to-delete).
  Future<int> deleteHistory(String id) =>
      (_db.delete(_db.searchHistory)..where((h) => h.id.equals(id))).go();

  /// Clears search history (privacy page).
  Future<int> clearHistory() => _db.delete(_db.searchHistory).go();
}

/// Persisted reco snapshots with TTL (spec 10.8).
class RecoSnapshotDao {
  /// Creates the DAO.
  RecoSnapshotDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Inserts or replaces a snapshot for a surface.
  Future<void> putSnapshot(RecoSnapshotsCompanion entry) =>
      _db.into(_db.recoSnapshots).insertOnConflictUpdate(entry);

  /// Fetches the snapshot for [surface], or null when absent.
  Future<DbRecoSnapshot?> bySurface(String surface) => (_db.select(
    _db.recoSnapshots,
  )..where((s) => s.surface.equals(surface))).getSingleOrNull();

  /// Whether the snapshot for [surface] is fresh at [nowEpochMs].
  Future<bool> isFresh(String surface, int nowEpochMs) async {
    final snapshot = await bySurface(surface);
    if (snapshot == null) {
      return false;
    }
    final computedAt = snapshot.computedAt ?? 0;
    final ttlMs = snapshot.ttlMs ?? 0;
    return nowEpochMs - computedAt < ttlMs;
  }
}

/// Generic metadata cache with TTL (search 12h, details 7d, art 30d).
class CacheDao {
  /// Creates the DAO.
  CacheDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Fetches a fresh entry, or null when missing/stale.
  Future<DbMetadataCache?> getFresh(String key, int nowEpochMs) async {
    final row = await (_db.select(
      _db.metadataCache,
    )..where((c) => c.key.equals(key))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final fetchedAt = row.fetchedAt ?? 0;
    final ttlMs = row.ttlMs ?? 0;
    if (nowEpochMs - fetchedAt >= ttlMs) {
      return null;
    }
    return row;
  }

  /// Inserts or replaces a cache entry.
  Future<void> put(MetadataCacheCompanion entry) =>
      _db.into(_db.metadataCache).insertOnConflictUpdate(entry);

  /// Deletes expired rows (maintenance job).
  Future<void> deleteExpired(int nowEpochMs) => _db.customStatement(
    'DELETE FROM metadata_cache WHERE fetched_at + ttl_ms <= ?',
    <Object?>[nowEpochMs],
  );

  /// Builds a namespaced cache key (`provider+kind+sourceId`).
  static String keyFor(String providerId, String kind, String sourceId) =>
      '$providerId:$kind:$sourceId';
}
