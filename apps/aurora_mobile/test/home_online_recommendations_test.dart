import 'dart:convert';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_database/aurora_database.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:aurora_reco/aurora_reco.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

class _FakeAudioEngine extends Fake implements AudioEngine {
  @override
  Stream<EngineState> get state => const Stream.empty();

  @override
  Stream<Duration> get position => const Stream.empty();

  @override
  Stream<Duration?> get duration => const Stream.empty();

  @override
  Stream<void> get becomingNoisy => const Stream.empty();
}

class _TestClock implements Clock {
  int _nowMs = 1700000000000;

  @override
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(_nowMs, isUtc: true);

  @override
  int nowEpochMs() => _nowMs;

  @override
  DateTime nowUtc() => now();

  void advance(Duration duration) {
    _nowMs += duration.inMilliseconds;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuroraDatabase db;
  late _TestClock clock;
  late AuroraWiring wiring;

  setUp(() async {
    db = AuroraDatabase.inMemory();
    clock = _TestClock();
    final local = LocalFilesProvider();
    final ytdlp = YtdlpProvider(clock: clock);
    final registry = ProviderRegistry(
      local: local,
      ytdlp: ytdlp,
    );
    final handler = AuroraAudioHandler();
    final controller = PlaybackController(
      providers: registry,
      engine: _FakeAudioEngine(),
      handler: handler,
      queue: QueueController(),
      events: ListeningEventSink(clock: clock, writer: (_) async {}),
      store: InMemoryPlaybackStore(),
      clock: clock,
    );
    final manager = DownloadManager(
      downloads: db.downloadsDao,
      tracks: db.tracksDao,
      outputDir: Directory.systemTemp,
      executor: ({
        required track,
        required quality,
        required outputDir,
        required onProgress,
      }) async => const Success(''),
      clock: clock,
    );

    wiring = AuroraWiring(
      db: db,
      clock: clock,
      local: local,
      fake: null,
      ytdlp: ytdlp,
      providers: registry,
      audioHandler: handler,
      playback: controller,
      downloads: manager,
      recoScheduler: RecoScheduler(),
      downloadDir: Directory.systemTemp,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'enrichHomeWithOnlineRecommendations fails gracefully when offline',
    () async {
      // Should never throw even with no network connection
      await expectLater(
        enrichHomeWithOnlineRecommendations(wiring, force: true),
        completes,
      );
    },
  );

  test('caching respects 4-hour TTL unless forced', () async {
    final nowMs = clock.nowEpochMs();
    final scored = [
      {'trackId': 'ytdlp:t1', 'score': 1.0},
    ];

    // Seed an existing online:discover snapshot
    await db.recoSnapshotsDao.putSnapshot(
      RecoSnapshotsCompanion(
        id: const Value('online:discover'),
        surface: const Value(HomeSurfaces.discover),
        json: Value(jsonEncode(scored)),
        computedAt: Value(nowMs),
        ttlMs: Value(onlineRecommendationsTtl.inMilliseconds),
      ),
    );

    // With force = false within TTL, it early returns and does not re-fetch
    await enrichHomeWithOnlineRecommendations(wiring);
    final snapshot = await db.recoSnapshotsDao.bySurface(HomeSurfaces.discover);
    expect(snapshot, isNotNull);
    expect(snapshot!.id, 'online:discover');
    expect(snapshot.computedAt, nowMs);

    // Advance clock past 4 hours
    clock.advance(const Duration(hours: 5));

    // Force = true allows recompute
    await enrichHomeWithOnlineRecommendations(wiring, force: true);
  });

  test('ensureOnlineTrackStored persists track and artist', () async {
    final now = clock.nowUtc();
    const artistId = 'ytdlp:channel-tarkan';
    wiring.artistNames[artistId] = 'Tarkan';

    final track = Track(
      id: 'ytdlp:song1',
      providerId: 'ytdlp',
      sourceTrackId: 'song1',
      title: 'Kuzu Kuzu',
      durationMs: 230000,
      artistIds: const [artistId],
      createdAt: now,
      updatedAt: now,
    );

    await wiring.ensureTrackStored(track);

    final storedTrack = await db.tracksDao.getById('ytdlp:song1');
    expect(storedTrack, isNotNull);
    expect(storedTrack!.title, 'Kuzu Kuzu');

    final artistRow = await db.artistsDao.getById(artistId);
    expect(artistRow, isNotNull);
    expect(artistRow!.name, 'Tarkan');

    final artistIds = await db.tracksDao.artistIdsFor('ytdlp:song1');
    expect(artistIds, contains(artistId));

    // Calling resolveTrack resolves artist name correctly
    final resolved = await wiring.resolveTrack('ytdlp:song1');
    expect(resolved, isNotNull);
    expect(wiring.artistLineFor(resolved!), 'Tarkan');
  });
}
