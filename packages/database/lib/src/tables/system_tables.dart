import 'package:drift/drift.dart';

/// System tables: queue, playback state, downloads, history, snapshots.
///
/// `playback_state` and `preference_profile` are single-row tables that
/// always use `id = 1`; repositories upsert that row on every write.
@DataClassName('DbQueueItem')
class QueueItems extends Table {
  /// Queue row id (uuid v7).
  TextColumn get id => text()();

  /// Queued track id.
  TextColumn get trackId => text().nullable()();

  /// Where the item was enqueued from (PlaySource name).
  TextColumn get origin => text().nullable()();

  /// Zero-based order.
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// Ranker score frozen at enqueue time, if ranked.
  RealColumn get frozenScore => real().nullable()();

  /// Enqueue time (UTC epoch ms).
  IntColumn get addedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'queue_items';
}

/// Single-row resume pointer (always `id = 1`).
@DataClassName('DbPlaybackState')
class PlaybackState extends Table {
  /// Always 1 (single-row table).
  IntColumn get id => integer()();

  /// Current track id, if any.
  TextColumn get trackId => text().nullable()();

  /// Resume position in milliseconds.
  IntColumn get positionMs => integer().nullable()();

  /// Whether audio was playing, as 0/1.
  IntColumn get isPlaying => integer().nullable()();

  /// Shuffle enabled, as 0/1.
  IntColumn get shuffle => integer().nullable()();

  /// Repeat mode (`off|one|all`).
  TextColumn get repeatMode => text().nullable()();

  /// Playback session id (uuid).
  TextColumn get sessionId => text().nullable()();

  /// Last update time (UTC epoch ms).
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'playback_state';
}

/// Download queue rows (spec sections 5 + 12).
@DataClassName('DbDownloadJob')
class DownloadJobs extends Table {
  /// Job id (uuid v7).
  TextColumn get id => text()();

  /// Track being persisted.
  TextColumn get trackId => text().nullable()();

  /// Lifecycle state (DownloadState name).
  TextColumn get state => text().nullable()();

  /// 0..1 progress of the active phase.
  RealColumn get progress => real().nullable()();

  /// Bytes received so far.
  IntColumn get bytesReceived => integer().nullable()();

  /// Expected total bytes, when reported.
  IntColumn get bytesTotal => integer().nullable()();

  /// Machine-readable failure code of the last attempt.
  TextColumn get errorCode => text().nullable()();

  /// Human-readable failure message of the last attempt.
  TextColumn get errorMessage => text().nullable()();

  /// Attempts made so far (drives backoff, caps at 5).
  IntColumn get attempts => integer().nullable()();

  /// Quality label used for this job.
  TextColumn get qualityLabel => text().nullable()();

  /// Persisted file path once completed.
  TextColumn get filePath => text().nullable()();

  /// Creation time (UTC epoch ms).
  IntColumn get createdAt => integer().nullable()();

  /// Last update time (UTC epoch ms).
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'download_jobs';
}

/// Recent search strings (last 50, swipe to delete).
@DataClassName('DbSearchHistory')
class SearchHistory extends Table {
  /// Row id (uuid v7).
  TextColumn get id => text()();

  /// Raw query text.
  TextColumn get query => text()();

  /// Creation time (UTC epoch ms).
  IntColumn get createdAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'search_history';
}

/// Persisted reco surfaces (spec 10.8) with TTL.
@DataClassName('DbRecoSnapshot')
class RecoSnapshots extends Table {
  /// Snapshot id (uuid v7).
  TextColumn get id => text()();

  /// Surface (`home_made_for_you`, `daily_mix_1`, ...).
  TextColumn get surface => text()();

  /// List of track ids + scores + reasons (JSON).
  TextColumn get json => text()();

  /// Computation time (UTC epoch ms).
  IntColumn get computedAt => integer().nullable()();

  /// Freshness window in milliseconds.
  IntColumn get ttlMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'reco_snapshots';
}

/// Generic provider/metadata cache with TTL (search 12h, details 7d).
@DataClassName('DbMetadataCache')
class MetadataCache extends Table {
  /// Cache key (`provider+kind+sourceId`).
  TextColumn get key => text()();

  /// Cached JSON payload.
  TextColumn get json => text().nullable()();

  /// Fetch time (UTC epoch ms).
  IntColumn get fetchedAt => integer().nullable()();

  /// Freshness window in milliseconds.
  IntColumn get ttlMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  String get tableName => 'metadata_cache';
}
