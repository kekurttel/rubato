import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_database/aurora_database.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/library/library_widgets.dart';
import 'package:aurora_mobile/features/playlist/playlist_detail_screen.dart';
import 'package:aurora_mobile/features/search/search_providers.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_music_source_local/aurora_music_source_local.dart';
import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:aurora_reco/aurora_reco.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final int _nowMs = 1700000000000;

  @override
  DateTime now() => DateTime.fromMillisecondsSinceEpoch(_nowMs, isUtc: true);

  @override
  int nowEpochMs() => _nowMs;

  @override
  DateTime nowUtc() => now();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuroraDatabase db;
  late _TestClock clock;
  late AuroraWiring wiring;
  late MethodChannel channel;

  setUp(() async {
    db = AuroraDatabase.inMemory();
    clock = _TestClock();
    channel = MethodChannel(
      'aurora.player/youtube_test_${DateTime.now().millisecondsSinceEpoch}',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'playlist') {
            return <String, dynamic>{
              'title': 'Mocked YouTube Playlist',
              'items': <dynamic>[
                <String, dynamic>{
                  'videoId': 'dQw4w9WgXcQ',
                  'title': 'Never Gonna Give You Up',
                  'uploader': 'Rick Astley',
                  'channelId': 'UCuAXFkgsw1L7xaCfnd5JJOw',
                  'durationSec': 213,
                  'thumbnailUrl':
                      'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
                },
              ],
            };
          }
          return null;
        });

    final local = LocalFilesProvider();
    final bridge = NewPipeBridge(channel: channel);
    final ytdlp = YtdlpProvider(newpipe: bridge, clock: clock);
    final registry = ProviderRegistry(local: local, ytdlp: ytdlp);
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

    manager.changes.listen((jobs) {
      wiring.jobsByTrack
        ..clear()
        ..addAll({for (final job in jobs) job.trackId: job});
    });
  });

  tearDown(() async {
    await db.close();
  });

  test('importYouTubePlaylist stores playlist, tracks, and artists', () async {
    final container = ProviderContainer(overrides: wiring.overrides());
    addTearDown(container.dispose);

    final library = container.read(libraryServiceProvider)!;
    final playlist = await library.importYouTubePlaylist(
      'https://www.youtube.com/playlist?list=PL12345',
    );

    expect(playlist, isNotNull);
    expect(playlist!.title, 'Mocked YouTube Playlist');

    final trackIds = await library.playlistTrackIds(playlist.id);
    expect(trackIds.length, 1);

    final track = await wiring.resolveTrack(trackIds.first);
    expect(track, isNotNull);
    expect(track!.title, 'Never Gonna Give You Up');
    expect(track.providerId, 'ytdlp');
    expect(track.sourceTrackId, 'dQw4w9WgXcQ');
    expect(track.durationMs, 213000);
    expect(library.artistLine(track), 'Rick Astley');
  });

  test('importYouTubePlaylist returns null on empty input', () async {
    final container = ProviderContainer(overrides: wiring.overrides());
    addTearDown(container.dispose);

    final library = container.read(libraryServiceProvider)!;
    final result = await library.importYouTubePlaylist('   ');
    expect(result, isNull);
  });

  testWidgets('YouTubePlaylistImportButton shows dialog on tap',
      (tester) async {
    final container = ProviderContainer(overrides: wiring.overrides());
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: YouTubePlaylistImportButton(),
          ),
        ),
      ),
    );

    expect(find.text('Import YouTube Playlist'), findsOneWidget);
    await tester.tap(find.text('Import YouTube Playlist'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('YouTube playlist link or ID'), findsOneWidget);
  });

  testWidgets('PlaylistDetailScreen renders Download all and Play buttons',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: wiring.overrides());
    addTearDown(container.dispose);

    final library = container.read(libraryServiceProvider)!;
    final playlist = await library.importYouTubePlaylist(
      'https://www.youtube.com/playlist?list=PL12345',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: PlaylistDetailScreen(playlistId: playlist!.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Download all'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);

    await tester.tap(find.text('Download all'));
    await tester.pumpAndSettle();

    expect(find.text('Download quality'), findsOneWidget);

    await tester.tap(find.text('Low'));
    await tester.pumpAndSettle();

    expect(find.text('Queued 1 track.'), findsOneWidget);
  });

  testWidgets(
      'PlaylistDetailScreen notifies when all tracks already downloaded',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: wiring.overrides());
    addTearDown(container.dispose);

    final library = container.read(libraryServiceProvider)!;
    final playlist = await library.importYouTubePlaylist(
      'https://www.youtube.com/playlist?list=PL12345',
    );
    final trackIds = await library.playlistTrackIds(playlist!.id);
    final track = (await wiring.resolveTrack(trackIds.first))!;

    // Enqueue track beforehand
    final searchActions = container.read(searchActionsProvider)!;
    await searchActions.enqueueDownload(track, Quality.low);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: PlaylistDetailScreen(playlistId: playlist.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Download all'));
    await tester.pumpAndSettle();

    expect(
      find.text('All tracks are already queued or downloaded.'),
      findsOneWidget,
    );
  });
}
