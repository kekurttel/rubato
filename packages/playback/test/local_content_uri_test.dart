import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:flutter_test/flutter_test.dart';

Track _localTrack(String id, String localPath) => Track(
  id: 'local:$id',
  providerId: 'local',
  sourceTrackId: id,
  title: 'Local $id',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  durationMs: 180000,
  localPath: localPath,
);

/// Engine fake distinguishing file vs URI loads.
final class ContentEngine implements AudioEngine {
  ContentEngine();

  final StreamController<EngineState> _state =
      StreamController<EngineState>.broadcast();
  final StreamController<Duration> _position =
      StreamController<Duration>.broadcast();

  /// Raw paths passed to `setSourceFile`.
  final List<String> fileLoads = <String>[];

  /// URIs passed to `setSourceUri` with their headers.
  final List<(Uri, Map<String, String>?)> uriLoads =
      <(Uri, Map<String, String>?)>[];

  /// When true, the next `setSourceUri` throws (ExoPlayer failure).
  bool failNextUri = false;

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
  Duration positionNow = Duration.zero;

  @override
  Duration? durationNow;

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
    fileLoads.add(path);
    _emit(
      const EngineState(
        playing: false,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> setSourceUri(Uri uri, {Map<String, String>? headers}) async {
    uriLoads.add((uri, headers));
    if (failNextUri) {
      failNextUri = false;
      throw Exception('Unable to load content:// (codec/permission)');
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

/// Local stub returning the track's own `localPath` as a localFile handle
/// (mirrors the fixed `LocalFilesProvider` for `content://` rows).
final class ContentLocalProvider extends MusicProvider {
  ContentLocalProvider({this.throwOnResolve = false});

  /// When true, `resolvePlayable` throws (must surface, never escape).
  bool throwOnResolve = false;

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
    if (throwOnResolve) {
      throw StateError('boom');
    }
    final path = track.localPath;
    if (path == null || path.isEmpty) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Local file is missing; skipping without clearing the queue',
          details: 'fileMissing:${track.id}',
        ),
      );
    }
    return Success(
      MediaHandle(
        kind: MediaHandleKind.localFile,
        uri: path,
        qualityLabel: Quality.original.name,
      ),
    );
  }

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async =>
      Success(SearchPage(providerId: id, fetchedAt: DateTime.utc(2026)));
}

PlaybackController _controller({
  required ContentEngine engine,
  required ContentLocalProvider provider,
  required FakeClock clock,
}) => PlaybackController(
  providers: ProviderRegistry(local: provider),
  engine: engine,
  handler: AuroraAudioHandler(),
  queue: QueueController(),
  events: ListeningEventSink(
    clock: clock,
    writer: (events) async {},
  ),
  store: InMemoryPlaybackStore(),
  clock: clock,
  missingSkipDelay: const Duration(seconds: 30),
);

void main() {
  test('localPlaybackUri keeps content/file schemes, files via Uri.file', () {
    expect(
      localPlaybackUri('content://media/external/audio/media/42').scheme,
      'content',
    );
    expect(
      localPlaybackUri('content://media/external/audio/media/42').toString(),
      'content://media/external/audio/media/42',
    );
    expect(localPlaybackUri('file:///sdcard/Music/a.m4a').scheme, 'file');
    expect(localPlaybackUri('/tmp/a.mp3').scheme, 'file');
    expect(isContentOrFileUri('content://media/external/audio/media/1'), isTrue);
    expect(isContentOrFileUri('file:///sdcard/a.m4a'), isTrue);
    expect(isContentOrFileUri('/sdcard/Music/a.m4a'), isFalse);
  });

  test('content:// localFile loads header-free via setSourceUri', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = ContentEngine();
    final provider = ContentLocalProvider();
    final controller = _controller(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(
      _localTrack('42', 'content://media/external/audio/media/42'),
    );

    expect(controller.info.status, PlaybackStatus.playing);
    // Content URIs must not go through Uri.file mangling.
    expect(engine.fileLoads, isEmpty);
    expect(engine.uriLoads, hasLength(1));
    expect(
      engine.uriLoads.single.$1.toString(),
      'content://media/external/audio/media/42',
    );
    expect(engine.uriLoads.single.$2, isNull);
  });

  test('raw path localFile still uses setSourceFile', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = ContentEngine();
    final provider = ContentLocalProvider();
    final controller = _controller(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_localTrack('f', '/tmp/f.mp3'));

    expect(controller.info.status, PlaybackStatus.playing);
    expect(engine.fileLoads, <String>['/tmp/f.mp3']);
    expect(engine.uriLoads, isEmpty);
  });

  test('local engine failure surfaces as Local playback failed', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = ContentEngine()..failNextUri = true;
    final provider = ContentLocalProvider();
    final controller = _controller(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);
    final errors = <PlaybackError>[];
    final sub = controller.errors.listen(errors.add);
    addTearDown(sub.cancel);

    await controller.playTrack(
      _localTrack('42', 'content://media/external/audio/media/42'),
    );

    expect(controller.info.status, PlaybackStatus.error);
    expect(errors, hasLength(1));
    expect(errors.single.message, startsWith('Local playback failed'));
    expect(controller.info.errorMessage, startsWith('Local playback failed'));
  });

  test('throwing local provider surfaces, never escapes playTrack', () async {
    final clock = FakeClock(DateTime.utc(2026));
    final engine = ContentEngine();
    final provider = ContentLocalProvider()..throwOnResolve = true;
    final controller = _controller(
      engine: engine,
      provider: provider,
      clock: clock,
    );
    addTearDown(controller.dispose);
    final errors = <PlaybackError>[];
    final sub = controller.errors.listen(errors.add);
    addTearDown(sub.cancel);

    // Must not throw despite the provider throwing a StateError.
    await controller.playTrack(
      _localTrack('42', 'content://media/external/audio/media/42'),
    );

    expect(controller.info.status, PlaybackStatus.error);
    expect(errors, hasLength(1));
  });
}
