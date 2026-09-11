import 'package:aurora_database/src/aurora_db.dart';
import 'package:drift/drift.dart';

/// Thin play-event data access (no business logic, spec section 6).
class EventsDao {
  /// Creates the DAO.
  EventsDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Inserts one flushed listening event.
  Future<void> insertEvent(PlayEventsCompanion entry) =>
      _db.into(_db.playEvents).insertOnConflictUpdate(entry);

  /// Inserts many events in a single batch (flush path, spec section 9).
  Future<void> insertAll(List<PlayEventsCompanion> entries) async {
    if (entries.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.playEvents, entries);
    });
  }

  /// Counts all stored events (cold-start gate: < 15 means cold start).
  Future<int> countAll() async {
    final row = await _db
        .customSelect('SELECT COUNT(*) AS c FROM play_events')
        .getSingle();
    return (row.data['c'] as int?) ?? 0;
  }

  /// Latest events newest-first (Home `recently_played` feeds from this).
  Future<List<DbPlayEvent>> latest({int limit = 20}) =>
      (_db.select(_db.playEvents)
            ..orderBy([(e) => OrderingTerm.desc(e.startedAt)])
            ..limit(limit))
          .get();

  /// Events for one track, newest-first.
  Future<List<DbPlayEvent>> eventsForTrack(String trackId, {int limit = 100}) =>
      (_db.select(_db.playEvents)
            ..where((e) => e.trackId.equals(trackId))
            ..orderBy([(e) => OrderingTerm.desc(e.startedAt)])
            ..limit(limit))
          .get();

  /// Events since [sinceEpochMs], oldest-first (reco streaming pages).
  Future<List<DbPlayEvent>> since(int sinceEpochMs, {int limit = 500}) =>
      (_db.select(_db.playEvents)
            ..where((e) => e.startedAt.isBiggerOrEqualValue(sinceEpochMs))
            ..orderBy([(e) => OrderingTerm.asc(e.startedAt)])
            ..limit(limit))
          .get();

  /// Deletes every event (privacy wipe).
  Future<int> deleteAll() => _db.delete(_db.playEvents).go();
}

/// Thin per-track stats access (no business logic).
class StatsDao {
  /// Creates the DAO.
  StatsDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Fetches stats for [trackId], or null when never observed.
  Future<DbUserTrackStat?> getByTrack(String trackId) => (_db.select(
    _db.userTrackStats,
  )..where((s) => s.trackId.equals(trackId))).getSingleOrNull();

  /// Inserts or replaces one stats row.
  Future<void> upsertStats(UserTrackStatsCompanion entry) =>
      _db.into(_db.userTrackStats).insertOnConflictUpdate(entry);

  /// Top tracks by decayed score (ranker candidate pre-sort).
  Future<List<DbUserTrackStat>> topByDecayedScore({int limit = 200}) =>
      (_db.select(_db.userTrackStats)
            ..orderBy([(s) => OrderingTerm.desc(s.decayedScore)])
            ..limit(limit))
          .get();

  /// Recently played tracks (Home continuity).
  Future<List<DbUserTrackStat>> recentlyPlayed({int limit = 20}) =>
      (_db.select(_db.userTrackStats)
            ..orderBy([(s) => OrderingTerm.desc(s.lastPlayedAt)])
            ..limit(limit))
          .get();

  /// Sets the like state (-1/0/1) for [trackId], creating the row.
  Future<void> setLikeState(
    String trackId, {
    required int likeState,
    required int updatedAt,
  }) async {
    final existing = await getByTrack(trackId);
    if (existing == null) {
      await _db
          .into(_db.userTrackStats)
          .insert(
            UserTrackStatsCompanion(
              trackId: Value(trackId),
              likeState: Value(likeState),
              updatedAt: Value(updatedAt),
            ),
          );
    } else {
      await (_db.update(
        _db.userTrackStats,
      )..where((s) => s.trackId.equals(trackId))).write(
        UserTrackStatsCompanion(
          likeState: Value(likeState),
          updatedAt: Value(updatedAt),
        ),
      );
    }
  }

  /// Clears score columns but keeps rows (Reset recommendations).
  Future<int> resetScores(int updatedAt) => _db
      .update(_db.userTrackStats)
      .write(
        UserTrackStatsCompanion(
          decayedScore: const Value(0),
          updatedAt: Value(updatedAt),
        ),
      );
}

/// Single-row preference profile access (always `id = 1`).
class ProfileDao {
  /// Creates the DAO.
  ProfileDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Fetches the profile row, or null before the first write.
  Future<DbPreferenceProfile?> getProfile() => (_db.select(
    _db.preferenceProfile,
  )..where((p) => p.id.equals(1))).getSingleOrNull();

  /// Inserts or replaces the profile row.
  Future<void> putProfile(PreferenceProfileCompanion entry) =>
      _db.into(_db.preferenceProfile).insertOnConflictUpdate(entry);

  /// Deletes the profile (Reset recommendations).
  Future<int> deleteProfile() =>
      (_db.delete(_db.preferenceProfile)..where((p) => p.id.equals(1))).go();
}

/// Playlists + entries (no business logic; ordering lives in callers).
class PlaylistsDao {
  /// Creates the DAO.
  PlaylistsDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Inserts or replaces a playlist.
  Future<void> upsertPlaylist(PlaylistsCompanion entry) =>
      _db.into(_db.playlists).insertOnConflictUpdate(entry);

  /// Fetches a playlist by id.
  Future<DbPlaylist?> getById(String id) => (_db.select(
    _db.playlists,
  )..where((p) => p.id.equals(id))).getSingleOrNull();

  /// Lists all playlists ordered by title.
  Future<List<DbPlaylist>> listAll() => (_db.select(
    _db.playlists,
  )..orderBy([(p) => OrderingTerm.asc(p.title)])).get();

  /// Deletes a playlist and its entries.
  Future<void> deletePlaylist(String playlistId) async {
    await (_db.delete(
      _db.playlistEntries,
    )..where((e) => e.playlistId.equals(playlistId))).go();
    await (_db.delete(
      _db.playlists,
    )..where((p) => p.id.equals(playlistId))).go();
  }

  /// Adds a track (insert-or-ignore on the pair PK; never crashes).
  Future<void> addEntry(PlaylistEntriesCompanion entry) =>
      _db.into(_db.playlistEntries).insertOnConflictUpdate(entry);

  /// Removes one membership.
  Future<int> removeEntry(String playlistId, String trackId) =>
      (_db.delete(_db.playlistEntries)..where(
            (e) => e.playlistId.equals(playlistId) & e.trackId.equals(trackId),
          ))
          .go();

  /// Entries of one playlist in position order.
  Future<List<DbPlaylistEntry>> entriesFor(String playlistId) =>
      (_db.select(_db.playlistEntries)
            ..where((e) => e.playlistId.equals(playlistId))
            ..orderBy([(e) => OrderingTerm.asc(e.position)]))
          .get();
}
