import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:flutter_test/flutter_test.dart';

Track _track(int i) => Track(
  id: 'local:track-$i',
  providerId: 'local',
  sourceTrackId: 'track-$i',
  title: 'Song $i',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  durationMs: 180000,
);

/// In-memory engine (no platform channels).
final class FakeAudioEngine implements AudioEngine {
  FakeAudioEngine();

  final StreamController<EngineState> _state =
      StreamController<EngineState>.broadcast();
  final StreamController<Duration> _position =
      StreamController<Duration>.broadcast();

  EngineState current = const EngineState(
    playing: false,
    processing: EngineProcessing.idle,
  );

  @override
  Duration positionNow = Duration.zero;

  @override
  Duration? durationNow;

  /// Loaded file paths, in order.
  final List<String> loadedFiles = <String>[];

  /// Seek targets, in order.
  final List<Duration> seeks = <Duration>[];

  int playCalls = 0;
  int pauseCalls = 0;

  void _emit(EngineState state) {
    current = state;
    if (!_state.isClosed) {
      _state.add(state);
    }
  }

  @override
  Stream<void> get becomingNoisy => const Stream<void>.empty();

  @override
  Stream<Duration?> get duration => const Stream<Duration?>.empty();

  @override
  Stream<Duration> get position => _position.stream;

  @override
  Stream<EngineState> get state => _state.stream;

  @override
  Future<void> dispose() async {
    await _state.close();
    await _position.close();
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    _emit(
      const EngineState(
        playing: false,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> play() async {
    playCalls++;
    _emit(
      const EngineState(
        playing: true,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    positionNow = position;
  }

  @override
  Future<void> setSourceFile(String path) async {
    loadedFiles.add(path);
    durationNow = const Duration(minutes: 3);
    _emit(
      const EngineState(
        playing: false,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> setSourceUri(Uri uri, {Map<String, String>? headers}) async {
    loadedFiles.add(uri.toString());
    _emit(
      const EngineState(
        playing: false,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {
    _emit(
      const EngineState(
        playing: false,
        processing: EngineProcessing.idle,
      ),
    );
  }
}

/// Canned local provider (resolves to a fake file path, or fails).
final class StubLocalProvider extends MusicProvider {
  StubLocalProvider({this.failResolve = false});

  /// Whether [resolvePlayable] fails (missing-file path).
  final bool failResolve;

  @override
  String get id => 'local';

  @override
  String get displayName => 'Stub local';

  @override
  bool get supportsDownload => false;

  @override
  bool get supportsSearch => true;

  @override
  bool get supportsStream => true;

  @override
  Stream<ProviderHealth> health() async* {
    yield ProviderHealth.online;
  }

  @override
  Future<Result<Artwork, AppError>> artwork(Track track) async => Failure(
    AppError(
      code: AppErrorCode.notFound,
      message: 'No artwork in stub',
      details: track.id,
    ),
  );

  @override
  Future<Result<AlbumDetails, AppError>> getAlbum(String sourceId) async =>
      Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'No albums in stub',
          details: sourceId,
        ),
      );

  @override
  Future<Result<ArtistDetails, AppError>> getArtist(String sourceId) async =>
      Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'No artists in stub',
          details: sourceId,
        ),
      );

  @override
  Future<Result<Track, AppError>> getTrack(String sourceId) async => Failure(
    AppError(
      code: AppErrorCode.notFound,
      message: 'No tracks in stub',
      details: sourceId,
    ),
  );

  @override
  Future<Result<MediaHandle, AppError>> resolvePlayable(
    Track track,
    Quality quality,
  ) async {
    if (failResolve) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Stub file is missing',
          details: 'fileMissing:${track.id}',
        ),
      );
    }
    return Success(
      MediaHandle(
        kind: MediaHandleKind.localFile,
        uri: '/tmp/${track.sourceTrackId}.mp3',
        qualityLabel: Quality.original.name,
      ),
    );
  }

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async =>
      Success(
        SearchPage(providerId: id, fetchedAt: DateTime.utc(2026)),
      );
}

PlaybackController _controller({
  required FakeAudioEngine engine,
  required InMemoryPlaybackStore store,
  required ListeningEventSink events,
  required FakeClock clock,
  bool failResolve = false,
  Duration skipDelay = Duration.zero,
}) => PlaybackController(
  providers: ProviderRegistry(
    local: StubLocalProvider(failResolve: failResolve),
  ),
  engine: engine,
  handler: AuroraAudioHandler(),
  queue: QueueController(),
  events: events,
  store: store,
  clock: clock,
  missingSkipDelay: skipDelay,
);

void main() {
  test('playTrack loads immediately and reaches playing', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = FakeAudioEngine();
    final store = InMemoryPlaybackStore();
    final written = <PlayEvent>[];
    final controller = _controller(
      engine: engine,
      store: store,
      events: ListeningEventSink(
        clock: clock,
        writer: (events) async => written.addAll(events),
      ),
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_track(0));
    // Mini-player shows the track while the engine catches up.
    expect(controller.info.track?.id, 'local:track-0');
    expect(controller.info.status, PlaybackStatus.playing);
    expect(engine.loadedFiles, hasLength(1));
    expect(store.saveQueueCalls, greaterThan(0));

    clock.advance(const Duration(seconds: 4));
    await controller.pause();
    expect(controller.info.status, PlaybackStatus.paused);
    expect(written, hasLength(1));
    expect(written.first.listenedMs, 4000);
  });

  test('previous restarts above 3s, steps back below', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = FakeAudioEngine();
    final controller = _controller(
      engine: engine,
      store: InMemoryPlaybackStore(),
      events: ListeningEventSink(
        clock: clock,
        writer: (events) async {},
      ),
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playQueue(<Track>[_track(0), _track(1)]);
    await controller.next();
    expect(controller.info.track?.id, 'local:track-1');

    engine.positionNow = const Duration(seconds: 10);
    await controller.previous();
    expect(engine.seeks.last, Duration.zero);
    expect(controller.info.track?.id, 'local:track-1');

    engine.positionNow = const Duration(seconds: 1);
    await controller.previous();
    expect(controller.info.track?.id, 'local:track-0');
  });

  test('missing files error, keep the queue, and auto-skip', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = FakeAudioEngine();
    final controller = _controller(
      engine: engine,
      store: InMemoryPlaybackStore(),
      events: ListeningEventSink(
        clock: clock,
        writer: (events) async {},
      ),
      clock: clock,
      failResolve: true,
    );
    addTearDown(controller.dispose);
    final errors = <PlaybackError>[];
    final sub = controller.errors.listen(errors.add);
    addTearDown(sub.cancel);

    await controller.playQueue(<Track>[_track(0), _track(1)]);
    expect(controller.info.status, PlaybackStatus.error);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(errors, hasLength(2));
    // The queue survived both failures.
    expect(controller.queue.length, 2);
  });

  test('restore reloads queue + position paused', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final store = InMemoryPlaybackStore();
    final firstEngine = FakeAudioEngine();
    final first = _controller(
      engine: firstEngine,
      store: store,
      events: ListeningEventSink(
        clock: clock,
        writer: (events) async {},
      ),
      clock: clock,
    );
    await first.playQueue(<Track>[_track(0), _track(1)]);
    firstEngine.positionNow = const Duration(seconds: 42);
    await first.pause();
    await first.dispose();

    final secondEngine = FakeAudioEngine();
    final second = PlaybackController(
      providers: ProviderRegistry(local: StubLocalProvider()),
      engine: secondEngine,
      handler: AuroraAudioHandler(),
      queue: QueueController(),
      events: ListeningEventSink(
        clock: clock,
        writer: (events) async {},
      ),
      store: store,
      clock: clock,
      trackResolver: (ids) async => <String, Track>{
        for (final id in ids) id: _track(int.parse(id.split('-').last)),
      },
    );
    addTearDown(second.dispose);
    await second.restore();
    expect(second.info.track?.id, 'local:track-0');
    expect(second.info.status, PlaybackStatus.paused);
    expect(
      second.info.position.inSeconds - 42,
      inInclusiveRange(-1, 1),
    );
  });
}
