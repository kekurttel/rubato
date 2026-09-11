import 'package:drift/drift.dart';

/// Catalog tables: tracks, joins, artists, albums, genres, artworks.
///
/// Column names and types mirror spec section 6 exactly. Booleans are
/// stored as `INT 0/1` (not Drift `bool`) so the on-disk schema matches
/// the spec byte-for-byte; mappers convert to/from `bool`.
@DataClassName('DbTrack')
class Tracks extends Table {
  /// Composite `${providerId}:${sourceId}` key.
  TextColumn get id => text()();

  /// Owning provider (`local`, `fake`, `ytdlp`).
  TextColumn get providerId => text()();

  /// Provider-scoped id (MYT `(_ID_)` suffix, video id, ...).
  TextColumn get sourceTrackId => text()();

  /// Clean display title (never raw `(_ID_)` filename).
  TextColumn get title => text()();

  /// Duration in milliseconds (0 when unknown).
  IntColumn get durationMs => integer().withDefault(const Constant(0))();

  /// Explicit flag as 0/1.
  IntColumn get explicit => integer().withDefault(const Constant(0))();

  /// Parent album id, if known.
  TextColumn get albumId => text().nullable()();

  /// Release year, if known.
  IntColumn get year => integer().nullable()();

  /// Content hash (first+last 64KB + length) for dedupe.
  TextColumn get audioHash => text().nullable()();

  /// On-disk path when a usable local file exists.
  TextColumn get localPath => text().nullable()();

  /// Verified download persisted, as 0/1.
  IntColumn get isDownloaded => integer().withDefault(const Constant(0))();

  /// Stream URL expiry (epoch ms, null for local files).
  IntColumn get streamExpiresAt => integer().nullable()();

  /// Row creation time (UTC epoch ms).
  IntColumn get createdAt => integer()();

  /// Row update time (UTC epoch ms).
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {providerId, sourceTrackId},
  ];
}

/// Track <-> artist credits in order.
@DataClassName('DbTrackArtist')
class TrackArtists extends Table {
  /// Owning track id.
  TextColumn get trackId => text()();

  /// Credited artist id.
  TextColumn get artistId => text()();

  /// Credit order.
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {trackId, artistId};

  @override
  String get tableName => 'track_artists';
}

/// Track <-> genre membership.
@DataClassName('DbTrackGenre')
class TrackGenres extends Table {
  /// Owning track id.
  TextColumn get trackId => text()();

  /// Genre id.
  TextColumn get genreId => text()();

  @override
  Set<Column<Object>> get primaryKey => {trackId, genreId};

  @override
  String get tableName => 'track_genres';
}

/// Artists table (spec section 6).
@DataClassName('DbArtist')
class Artists extends Table {
  /// Composite `${providerId}:${sourceId}` id.
  TextColumn get id => text()();

  /// Owning provider.
  TextColumn get providerId => text().nullable()();

  /// Provider-scoped id.
  TextColumn get sourceId => text().nullable()();

  /// Display name.
  TextColumn get name => text()();

  /// Artwork URL, if the provider supplied one.
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Albums table (spec section 6).
@DataClassName('DbAlbum')
class Albums extends Table {
  /// Composite `${providerId}:${sourceId}` id.
  TextColumn get id => text()();

  /// Owning provider.
  TextColumn get providerId => text().nullable()();

  /// Provider-scoped id.
  TextColumn get sourceId => text().nullable()();

  /// Display title.
  TextColumn get title => text()();

  /// Release year, if known.
  IntColumn get year => integer().nullable()();

  /// Cover artwork id, if cached.
  TextColumn get artworkId => text().nullable()();

  /// Known track count (0 when unknown).
  IntColumn get trackCount => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Genres table (spec section 6).
@DataClassName('DbGenre')
class Genres extends Table {
  /// Genre id.
  TextColumn get id => text()();

  /// Display name (unique).
  TextColumn get name => text().unique()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Artworks table (spec section 6).
@DataClassName('DbArtwork')
class Artworks extends Table {
  /// Artwork id.
  TextColumn get id => text()();

  /// Remote URL the bytes were fetched from, if any.
  TextColumn get url => text().nullable()();

  /// App-cache path of the persisted bytes, if any.
  TextColumn get localPath => text().nullable()();

  /// Dominant color as ARGB int.
  IntColumn get dominantArgb => integer().nullable()();

  /// Pixel width, if known.
  IntColumn get width => integer().nullable()();

  /// Pixel height, if known.
  IntColumn get height => integer().nullable()();

  /// Last fetch/update time (UTC epoch ms).
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
