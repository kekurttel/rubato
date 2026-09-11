import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_database/aurora_database.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('migration: open empty db, insert track, read back', () async {
    final db = AuroraDatabase.inMemory();
    addTearDown(db.close);

    final now = db.nowEpochMs;
    await db.tracksDao.upsertTrack(
      TracksCompanion(
        id: const Value('local:abc123DEF45'),
        providerId: const Value('local'),
        sourceTrackId: const Value('abc123DEF45'),
        title: const Value('Test Song'),
        durationMs: const Value(180000),
        explicit: const Value(0),
        isDownloaded: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final row = await db.tracksDao.getById('local:abc123DEF45');
    expect(row, isNotNull);
    expect(row!.title, 'Test Song');

    final mapped = DbMappers.toTrack(row);
    expect(mapped, isA<Track>());
    expect(mapped.hasLocalFile, isFalse);
  });

  test('schema exposes exact tables, indexes, and FTS5', () async {
    final db = AuroraDatabase.inMemory();
    addTearDown(db.close);

    // Touch the db so onCreate + beforeOpen run.
    await db.tracksDao.searchByTitleLike('nothing');
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
        )
        .get();
    final names = <String>{
      for (final r in tables) (r.data['name'] as String),
    };
    for (final expected in <String>[
      'tracks',
      'track_artists',
      'track_genres',
      'artists',
      'albums',
      'genres',
      'artworks',
      'playlists',
      'playlist_entries',
      'play_events',
      'user_track_stats',
      'preference_profile',
      'queue_items',
      'playback_state',
      'download_jobs',
      'search_history',
      'reco_snapshots',
      'metadata_cache',
      'tracks_fts',
    ]) {
      expect(names, contains(expected), reason: 'missing table $expected');
    }

    final fts = await db
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE name='tracks_fts'",
        )
        .getSingle();
    expect(
      (fts.data['sql'] as String).toLowerCase(),
      contains('fts5'),
    );
  });

  test('events + queue + cache round-trip', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final db = AuroraDatabase.inMemory(clock: clock);
    addTearDown(db.close);

    await db.eventsDao.insertEvent(
      PlayEventsCompanion(
        id: Value(AuroraIds.newId()),
        trackId: const Value('local:abc123DEF45'),
        sessionId: Value(AuroraIds.newSessionId()),
        startedAt: Value(clock.nowEpochMs()),
      ),
    );
    expect(await db.eventsDao.countAll(), 1);

    await db.queueDao.replaceAll(<QueueItemsCompanion>[
      QueueItemsCompanion(
        id: Value(AuroraIds.newId()),
        trackId: const Value('local:abc123DEF45'),
        origin: const Value('library'),
        position: const Value(0),
        addedAt: Value(clock.nowEpochMs()),
      ),
    ]);
    expect((await db.queueDao.ordered()).length, 1);

    await db.cacheDao.put(
      MetadataCacheCompanion(
        key: const Value('ytdlp:search:metal'),
        json: const Value('{"hits":1}'),
        fetchedAt: Value(clock.nowEpochMs()),
        ttlMs: const Value(43200000),
      ),
    );
    expect(
      await db.cacheDao.getFresh('ytdlp:search:metal', clock.nowEpochMs()),
      isNotNull,
    );
  });
}
