import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:flutter_test/flutter_test.dart';

Track _netTrack(String id) => Track(
  id: 'net:$id',
  providerId: 'net',
  sourceTrackId: id,
  title: 'Stream $id',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  durationMs: 180000,
);

/// Engine fake that records stream headers and can fail `setSourceUri`.
final class HeaderEngine implements AudioEngine {
  HeaderEngine();

  final StreamController<EngineState> _state =
      StreamController<EngineState>.broadcast();
  final StreamController<Duration> _position =
      StreamController<Duration>.broadcast();

  /// Headers received per `setSourceUri` call (null = header-free).
  final List<Map<String, String>?> uriHeaders = <Map<String, String>?>[];

  /// Loaded file paths, in order.
  final List<String> loadedFiles = <String>[];

  /// Remaining `setSourceUri` failures before loads succeed.
  int failUriTimes = 0;

  int setSourceUriCalls = 0;

  @override
  Duration positionNow = Duration.zero;

  @override
  Duration? durationNow;

  void _emit(EngineState state) {
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
    _emit(
      const EngineState(
        playing: false,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> play() async {
    _emit(
      const EngineState(
        playing: true,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) async {
    positionNow = position;
  }

  @override
  Future<void> setSourceFile(String path) async {
    loadedFiles.add(path);
    _emit(
      const EngineState(
        playing: false,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> setSourceUri(Uri uri, {Map<String, String>? headers}) async {
    setSourceUriCalls++;
    uriHeaders.add(headers);
    if (failUriTimes > 0) {
      failUriTimes--;
      throw Exception('HTTP 403 Forbidden');
    }
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

/// Stream provider stub: authorized streams, countable resolves.
final class StreamStubProvider extends MusicProvider {
  StreamStubProvider({this.handleHeaders = const <String, String>{}});

  /// Headers to attach to every resolved stream handle.
  Map<String, String> handleHeaders;

  /// Track ids whose resolve fails.
  final Set<String> failIds = <String>{};

  /// Whether every resolve fails (missing-file path).
  bool failAllResolve = false;

  /// Local-file track ids (loaded via `setSourceFile`, header-free).
  final Set<String> localIds = <String>{};

  /// `resolvePlayable` call count (verifies the once-only retry).
  int resolveCalls = 0;

  @override
  String get id => 'net';

  @override
  String get displayName => 'Stub stream';

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
    resolveCalls++;
    if (failAllResolve || failIds.contains(track.id)) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Stub file is missing',
          details: 'fileMissing:${track.id}',
        ),
      );
    }
    if (localIds.contains(track.id)) {
      return Success(
        MediaHandle(
          kind: MediaHandleKind.localFile,
          uri: '/tmp/${track.sourceTrackId}.mp3',
          qualityLabel: Quality.original.name,
        ),
      );
    }
    return Success(
      MediaHandle(
        kind: MediaHandleKind.authorizedStream,
        uri: 'https://googlevideo.example/videoplayback?id=${track.id}',
        qualityLabel: quality.name,
        headers: handleHeaders,
      ),
    );
  }

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async =>
      Success(SearchPage(providerId: id, fetchedAt: DateTime.utc(2026)));
}

/// Minimal local stub for the registry's required `local` slot.
final class LocalStubProvider extends MusicProvider {
  LocalStubProvider();

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
  ) async => Success(
    MediaHandle(
      kind: MediaHandleKind.localFile,
      uri: '/tmp/${track.sourceTrackId}.mp3',
      qualityLabel: Quality.original.name,
    ),
  );

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async =>
      Success(SearchPage(providerId: id, fetchedAt: DateTime.utc(2026)));
}

PlaybackController _streamController({
  required HeaderEngine engine,
  required StreamStubProvider provider,
  required FakeClock clock,
  Duration skipDelay = const Duration(seconds: 30),
}) => PlaybackController(
  providers: ProviderRegistry(
    local: LocalStubProvider(),
    ytdlp: provider,
  ),
  engine: engine,
  handler: AuroraAudioHandler(),
  queue: QueueController(),
  events: ListeningEventSink(
    clock: clock,
    writer: (events) async {},
  ),
  store: InMemoryPlaybackStore(),
  clock: clock,
  missingSkipDelay: skipDelay,
);

void main() {
  test('authorizedStream sends browser headers by default', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = HeaderEngine();
    final provider = StreamStubProvider();
    final controller = _streamController(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_netTrack('a'));

    expect(controller.info.status, PlaybackStatus.playing);
    expect(engine.uriHeaders, hasLength(1));
    final headers = engine.uriHeaders.single;
    expect(headers, isNotNull);
    expect(headers, defaultStreamHeaders);
    expect(headers!['User-Agent'], contains('Chrome'));
    expect(headers['Accept'], '*/*');
  });

  test('authorizedStream keeps provider headers when present', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = HeaderEngine();
    final provider = StreamStubProvider(
      handleHeaders: const <String, String>{
        'Authorization': 'Bearer stub',
        'User-Agent': 'Custom/1.0',
      },
    );
    final controller = _streamController(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_netTrack('a'));

    expect(controller.info.status, PlaybackStatus.playing);
    expect(engine.uriHeaders.single, provider.handleHeaders);
  });

  test('localFile loads header-free via setSourceFile', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = HeaderEngine();
    final provider = StreamStubProvider()..localIds.add('net:file');
    final controller = _streamController(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_netTrack('file'));

    expect(controller.info.status, PlaybackStatus.playing);
    expect(engine.loadedFiles, hasLength(1));
    expect(engine.setSourceUriCalls, 0);
    expect(engine.uriHeaders, isEmpty);
  });

  test('user play escapes error and plays again (no brick)', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = HeaderEngine();
    final provider = StreamStubProvider()..failAllResolve = true;
    final controller = _streamController(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);
    final errors = <PlaybackError>[];
    final sub = controller.errors.listen(errors.add);
    addTearDown(sub.cancel);

    await controller.playTrack(_netTrack('a'));
    expect(controller.info.status, PlaybackStatus.error);
    expect(errors, hasLength(1));
    expect(errors.single.trackId, 'net:a');

    // Fresh user intent recovers without a restart.
    provider.failAllResolve = false;
    await controller.playTrack(_netTrack('b'));
    expect(controller.info.status, PlaybackStatus.playing);
    expect(controller.info.track?.id, 'net:b');
  });

  test('resume from error reloads instead of illegal transition', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = HeaderEngine();
    final provider = StreamStubProvider()..failAllResolve = true;
    final controller = _streamController(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_netTrack('a'));
    expect(controller.info.status, PlaybackStatus.error);

    // Notification / mini-player play button retries the failed item.
    provider.failAllResolve = false;
    await controller.resume();
    expect(controller.info.status, PlaybackStatus.playing);
    expect(controller.info.track?.id, 'net:a');
  });

  test('source error re-resolves once, then plays', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = HeaderEngine()..failUriTimes = 1;
    final provider = StreamStubProvider();
    final controller = _streamController(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);
    final errors = <PlaybackError>[];
    final sub = controller.errors.listen(errors.add);
    addTearDown(sub.cancel);

    await controller.playTrack(_netTrack('a'));

    expect(controller.info.status, PlaybackStatus.playing);
    // Initial resolve + exactly one fresh retry.
    expect(provider.resolveCalls, 2);
    expect(engine.setSourceUriCalls, 2);
    // Retried load carries headers too.
    for (final headers in engine.uriHeaders) {
      expect(headers, defaultStreamHeaders);
    }
    expect(errors, isEmpty);
  });

  test('persistent source error emits one item error after retry', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = HeaderEngine()..failUriTimes = 99;
    final provider = StreamStubProvider();
    final controller = _streamController(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);
    final errors = <PlaybackError>[];
    final sub = controller.errors.listen(errors.add);
    addTearDown(sub.cancel);

    await controller.playTrack(_netTrack('a'));

    expect(controller.info.status, PlaybackStatus.error);
    expect(provider.resolveCalls, 2);
    expect(engine.setSourceUriCalls, 2);
    // The UI snackbar source fires exactly once per failed item.
    expect(errors, hasLength(1));
    expect(errors.single.trackId, 'net:a');
    // The queue survives the failure.
    expect(controller.queue.length, 1);
  });

  test('next from error loads the next item', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = HeaderEngine();
    final provider = StreamStubProvider()..failIds.add('net:a');
    final controller = _streamController(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playQueue(<Track>[_netTrack('a'), _netTrack('b')]);
    expect(controller.info.status, PlaybackStatus.error);

    // Like next-while-paused, the next item loads without autoplaying
    // (the failure cleared `_wantsPlaying`); the machine left error.
    await controller.next();
    expect(controller.info.status, PlaybackStatus.ready);
    expect(controller.info.track?.id, 'net:b');

    // And a normal resume plays it — no brick, no illegal transition.
    await controller.resume();
    expect(controller.info.status, PlaybackStatus.playing);
  });
}
