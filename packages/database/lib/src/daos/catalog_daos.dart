import 'package:aurora_database/src/aurora_db.dart';
import 'package:drift/drift.dart';

/// Thin track data access (no business logic, spec section 6).
///
/// Join-table writes (`track_artists`, `track_genres`) live here so the
/// library repository can upsert a track and its credits atomically.
class TracksDao {
  /// Creates the DAO.
  TracksDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Inserts or replaces one track row.
  Future<void> upsertTrack(TracksCompanion entry) =>
      _db.into(_db.tracks).insertOnConflictUpdate(entry);

  /// Upserts many tracks in one batch (scan path).
  Future<void> upsertAll(List<TracksCompanion> entries) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.tracks, entries);
    });
  }

  /// Fetches a track by its composite id.
  Future<DbTrack?> getById(String id) =>
      (_db.select(_db.tracks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Fetches by the `(provider_id, source_track_id)` unique key.
  Future<DbTrack?> getByProviderSource(
    String providerId,
    String sourceTrackId,
  ) =>
      (_db.select(_db.tracks)..where(
            (t) =>
                t.providerId.equals(providerId) &
                t.sourceTrackId.equals(sourceTrackId),
          ))
          .getSingleOrNull();

  /// Lists tracks of one album.
  Future<List<DbTrack>> listByAlbum(String albumId) =>
      (_db.select(_db.tracks)
            ..where((t) => t.albumId.equals(albumId))
            ..orderBy([(t) => OrderingTerm.asc(t.title)]))
          .get();

  /// Case-insensitive title fallback when FTS is unavailable.
  Future<List<DbTrack>> searchByTitleLike(String query, {int limit = 20}) =>
      (_db.select(_db.tracks)
            ..where((t) => t.title.like('%$query%'))
            ..orderBy([(t) => OrderingTerm.asc(t.title)])
            ..limit(limit))
          .get();

  /// Marks the verified on-disk location after a scan or download.
  Future<void> setLocalFile(
    String id, {
    required String localPath,
    required bool isDownloaded,
    required int updatedAt,
  }) => (_db.update(_db.tracks)..where((t) => t.id.equals(id))).write(
    TracksCompanion(
      localPath: Value(localPath),
      isDownloaded: Value(isDownloaded ? 1 : 0),
      updatedAt: Value(updatedAt),
    ),
  );

  /// Clears the local path when the file vanished (playback skips).
  Future<void> markFileMissing(String id, {required int updatedAt}) =>
      (_db.update(_db.tracks)..where((t) => t.id.equals(id))).write(
        TracksCompanion(
          localPath: const Value<String?>(null),
          isDownloaded: const Value(0),
          updatedAt: Value(updatedAt),
        ),
      );

  /// Deletes a track row (joins are cleaned by foreign-key cascades
  /// where enforced, else by [deleteJoinsFor]).
  Future<int> deleteById(String id) =>
      (_db.delete(_db.tracks)..where((t) => t.id.equals(id))).go();

  /// Removes join rows for [trackId] (call inside the same transaction
  /// as the track upsert during rescans).
  Future<void> deleteJoinsFor(String trackId) async {
    await (_db.delete(
      _db.trackArtists,
    )..where((r) => r.trackId.equals(trackId))).go();
    await (_db.delete(
      _db.trackGenres,
    )..where((r) => r.trackId.equals(trackId))).go();
  }

  /// Replaces artist credits for one track.
  Future<void> setArtists(String trackId, List<String> artistIds) async {
    await (_db.delete(
      _db.trackArtists,
    )..where((r) => r.trackId.equals(trackId))).go();
    if (artistIds.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.trackArtists,
        <TrackArtistsCompanion>[
          for (var i = 0; i < artistIds.length; i++)
            TrackArtistsCompanion(
              trackId: Value(trackId),
              artistId: Value(artistIds[i]),
              position: Value(i),
            ),
        ],
      );
    });
  }

  /// Replaces genre membership for one track.
  Future<void> setGenres(String trackId, List<String> genreIds) async {
    await (_db.delete(
      _db.trackGenres,
    )..where((r) => r.trackId.equals(trackId))).go();
    if (genreIds.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.trackGenres,
        <TrackGenresCompanion>[
          for (final genreId in genreIds)
            TrackGenresCompanion(
              trackId: Value(trackId),
              genreId: Value(genreId),
            ),
        ],
      );
    });
  }

  /// Artist ids for [trackId] in credit order.
  Future<List<String>> artistIdsFor(String trackId) async {
    final rows =
        await (_db.select(_db.trackArtists)
              ..where((r) => r.trackId.equals(trackId))
              ..orderBy([(r) => OrderingTerm.asc(r.position)]))
            .get();
    return <String>[for (final r in rows) r.artistId];
  }

  /// Genre ids for [trackId].
  Future<List<String>> genreIdsFor(String trackId) async {
    final rows = await (_db.select(
      _db.trackGenres,
    )..where((r) => r.trackId.equals(trackId))).get();
    return <String>[for (final r in rows) r.genreId];
  }
}

/// Thin artist data access (no business logic).
class ArtistsDao {
  /// Creates the DAO.
  ArtistsDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Inserts or replaces one artist.
  Future<void> upsertArtist(ArtistsCompanion entry) =>
      _db.into(_db.artists).insertOnConflictUpdate(entry);

  /// Upserts many artists in one batch.
  Future<void> upsertAll(List<ArtistsCompanion> entries) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.artists, entries);
    });
  }

  /// Fetches an artist by id.
  Future<DbArtist?> getById(String id) => (_db.select(
    _db.artists,
  )..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Lists all artists ordered by name.
  Future<List<DbArtist>> listAll({int? limit}) {
    final query = _db.select(_db.artists)
      ..orderBy([(a) => OrderingTerm.asc(a.name)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }
}

/// Thin album data access (no business logic).
class AlbumsDao {
  /// Creates the DAO.
  AlbumsDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Inserts or replaces one album.
  Future<void> upsertAlbum(AlbumsCompanion entry) =>
      _db.into(_db.albums).insertOnConflictUpdate(entry);

  /// Upserts many albums in one batch.
  Future<void> upsertAll(List<AlbumsCompanion> entries) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.albums, entries);
    });
  }

  /// Fetches an album by id.
  Future<DbAlbum?> getById(String id) =>
      (_db.select(_db.albums)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Lists all albums ordered by title.
  Future<List<DbAlbum>> listAll({int? limit}) {
    final query = _db.select(_db.albums)
      ..orderBy([(a) => OrderingTerm.asc(a.title)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  /// Points one album at its cached cover artwork (scan path).
  Future<void> setArtworkId(String id, {required String artworkId}) =>
      (_db.update(_db.albums)..where((a) => a.id.equals(id))).write(
        AlbumsCompanion(artworkId: Value(artworkId)),
      );
}

/// Thin artwork data access (no business logic).
///
/// Rows hold the app-cache path of persisted cover bytes; albums link
/// via `albums.artwork_id`, while tracks resolve by the stable
/// `local-art-<sourceTrackId>` id convention (the tracks table carries
/// no artwork column by design).
class ArtworksDao {
  /// Creates the DAO.
  ArtworksDao(this._db);

  /// Underlying database.
  final AuroraDatabase _db;

  /// Inserts or replaces one artwork row.
  Future<void> upsertArtwork(ArtworksCompanion entry) =>
      _db.into(_db.artworks).insertOnConflictUpdate(entry);

  /// Upserts many artwork rows in one batch (scan path).
  Future<void> upsertAll(List<ArtworksCompanion> entries) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.artworks, entries);
    });
  }

  /// Fetches an artwork row by id.
  Future<DbArtwork?> getById(String id) =>
      (_db.select(
        _db.artworks,
      )..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Cached file path for [id], or null when absent/blank.
  Future<String?> localPathFor(String id) async {
    final row = await getById(id);
    final path = row?.localPath;
    return (path == null || path.isEmpty) ? null : path;
  }
}
