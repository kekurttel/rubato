import 'package:drift/drift.dart';

/// Library + listening tables: playlists, entries, events, stats, profile.
///
/// Times are UTC epoch milliseconds. Flags are `INT 0/1` per spec.
@DataClassName('DbPlaylist')
class Playlists extends Table {
  /// Playlist id (uuid v7; well-known strings for system lists).
  TextColumn get id => text()();

  /// Display title.
  TextColumn get title => text()();

  /// Optional user description.
  TextColumn get description => text().nullable()();

  /// Cover artwork id, if any.
  TextColumn get artworkId => text().nullable()();

  /// Built-in system playlist, as 0/1.
  IntColumn get isSystem => integer().withDefault(const Constant(0))();

  /// Creation time (UTC epoch ms).
  IntColumn get createdAt => integer().nullable()();

  /// Last modification time (UTC epoch ms).
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Playlist membership (PK is the pair per spec section 6).
@DataClassName('DbPlaylistEntry')
class PlaylistEntries extends Table {
  /// Owning playlist id.
  TextColumn get playlistId => text()();

  /// Member track id.
  TextColumn get trackId => text()();

  /// Zero-based order inside the playlist.
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// Time the track was added (UTC epoch ms).
  IntColumn get addedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, trackId};

  @override
  String get tableName => 'playlist_entries';
}

/// One flushed listening observation per row (spec sections 5 + 9).
@DataClassName('DbPlayEvent')
class PlayEvents extends Table {
  /// Event id (uuid v7).
  TextColumn get id => text()();

  /// Played track id.
  TextColumn get trackId => text()();

  /// Playback session id.
  TextColumn get sessionId => text()();

  /// Playback start (UTC epoch ms).
  IntColumn get startedAt => integer()();

  /// Playback end, if the window closed (UTC epoch ms).
  IntColumn get endedAt => integer().nullable()();

  /// Track length at play time, in milliseconds.
  IntColumn get durationMs => integer().nullable()();

  /// Milliseconds actually heard.
  IntColumn get listenedMs => integer().nullable()();

  /// `listenedMs / max(durationMs, 1)`, clamped 0..1.
  RealColumn get completionRatio => real().nullable()();

  /// User moved on before 0.85, as 0/1.
  IntColumn get skipped => integer().nullable()();

  /// Position of the skip, if skipped.
  IntColumn get skipAtMs => integer().nullable()();

  /// Where playback originated (PlaySource name).
  TextColumn get source => text().nullable()();

  /// Local-time bucket name.
  TextColumn get timeOfDayBucket => text().nullable()();

  /// `startedAt.weekday % 7`.
  IntColumn get dayOfWeek => integer().nullable()();

  /// Playback speed multiplier.
  RealColumn get playbackSpeed => real().nullable()();

  /// Device was offline during playback, as 0/1.
  IntColumn get wasOffline => integer().nullable()();

  /// Seek gestures observed during this event.
  IntColumn get seekCount => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'play_events';
}

/// Incremental per-track listening rollup (spec section 5).
@DataClassName('DbUserTrackStat')
class UserTrackStats extends Table {
  /// Observed track id.
  TextColumn get trackId => text()();

  /// Started plays (noise-filtered).
  IntColumn get playCount => integer().nullable()();

  /// Skipped plays.
  IntColumn get skipCount => integer().nullable()();

  /// Plays with `completionRatio` >= 0.85.
  IntColumn get completeCount => integer().nullable()();

  /// Restarts within 10s of a complete (or replays within 30s).
  IntColumn get replayCount => integer().nullable()();

  /// Total heard milliseconds across all plays.
  IntColumn get totalListenMs => integer().nullable()();

  /// Last play time (UTC epoch ms).
  IntColumn get lastPlayedAt => integer().nullable()();

  /// -1 dislike, 0 none, 1 like.
  IntColumn get likeState => integer().nullable()();

  /// Time-decayed aggregate score.
  RealColumn get decayedScore => real().nullable()();

  /// Last update time (UTC epoch ms).
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};

  @override
  String get tableName => 'user_track_stats';
}

/// Single-row versioned taste profile (always `id = 1`).
@DataClassName('DbPreferenceProfile')
class PreferenceProfile extends Table {
  /// Always 1 (single-row table).
  IntColumn get id => integer()();

  /// Schema version (starts at 1).
  IntColumn get version => integer().nullable()();

  /// Versioned JSON payload.
  TextColumn get json => text()();

  /// Last update time (UTC epoch ms).
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'preference_profile';
}
