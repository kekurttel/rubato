import 'dart:async';

import 'package:audio_service/audio_service.dart';
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

  @override
  Duration positionNow = Duration.zero;

  @override
  Duration? durationNow;

  void _emit(EngineState state) {
    if (!_state.isClosed) {
      _state.add(state);
    }
  }

  void pushPosition(Duration position) {
    positionNow = position;
    if (!_position.isClosed) {
      _position.add(position);
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
    _emit(
      const EngineState(
        playing: false,
        processing: EngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> setSourceUri(Uri uri, {Map<String, String>? headers}) async {
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

/// Local stub with configurable artwork (null = no cached art).
final class StubLocalProvider extends MusicProvider {
  StubLocalProvider({this.artworkResult});

  /// Artwork served by [artwork] (null means "not found").
  final Artwork? artworkResult;

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
  Future<Result<Artwork, AppError>> artwork(Track track) async {
    final art = artworkResult;
    if (art == null) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'No artwork in stub',
          details: track.id,
        ),
      );
    }
    return Success(art);
  }

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
      Success(
        SearchPage(providerId: id, fetchedAt: DateTime.utc(2026)),
      );
}

PlaybackController _controller({
  required FakeAudioEngine engine,
  required AuroraAudioHandler handler,
  Artwork? artwork,
  MediaItemResolver? mediaItemResolver,
}) => PlaybackController(
  providers: ProviderRegistry(
    local: StubLocalProvider(artworkResult: artwork),
  ),
  engine: engine,
  handler: handler,
  queue: QueueController(),
  events: ListeningEventSink(
    clock: FakeClock(DateTime.utc(2026)),
    writer: (events) async {},
  ),
  store: InMemoryPlaybackStore(),
  clock: FakeClock(DateTime.utc(2026)),
  mediaItemResolver: mediaItemResolver,
);

void main() {
  test('track load publishes MediaItem with online thumbnail artUri', () async {
    final handler = AuroraAudioHandler();
    final controller = _controller(
      engine: FakeAudioEngine(),
      handler: handler,
      artwork: Artwork(
        id: 'ytdlp-art-track-0',
        updatedAt: DateTime.utc(2026),
        url: 'https://example.com/thumb0.jpg',
      ),
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_track(0));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final item = handler.mediaItem.value;
    expect(item?.id, 'local:track-0');
    expect(item?.title, 'Song 0');
    expect(
      item?.artUri,
      Uri.parse('https://example.com/thumb0.jpg'),
    );
  });

  test('track load maps local artwork file to a file artUri', () async {
    final handler = AuroraAudioHandler();
    final controller = _controller(
      engine: FakeAudioEngine(),
      handler: handler,
      artwork: Artwork(
        id: 'local-art-track-0',
        updatedAt: DateTime.utc(2026),
        localPath: '/tmp/artwork/local-track-0.jpg',
      ),
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_track(0));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(
      handler.mediaItem.value?.artUri,
      Uri.file('/tmp/artwork/local-track-0.jpg'),
    );
  });

  test('missing artwork degrades to a null artUri, item still set', () async {
    final handler = AuroraAudioHandler();
    final controller = _controller(
      engine: FakeAudioEngine(),
      handler: handler,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_track(0));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final item = handler.mediaItem.value;
    expect(item?.id, 'local:track-0');
    expect(item?.artUri, isNull);
  });

  test('YouTube 11-char id falls back to thumbnail artUri', () async {
    final handler = AuroraAudioHandler();
    final controller = _controller(
      engine: FakeAudioEngine(),
      handler: handler,
    );
    addTearDown(controller.dispose);

    final track = _track(0).copyWith(sourceTrackId: 'dQw4w9WgXcQ');
    await controller.playTrack(track);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final item = handler.mediaItem.value;
    expect(
      item?.artUri,
      Uri.parse('https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg'),
    );
  });

  test('app resolver metadata wins (artist/album/art)', () async {
    final handler = AuroraAudioHandler();
    final controller = _controller(
      engine: FakeAudioEngine(),
      handler: handler,
      mediaItemResolver: (track) async => trackToMediaItem(
        track,
        artist: 'Some Artist',
        album: 'Some Album',
        artUri: Uri.parse('https://example.com/app.jpg'),
      ),
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_track(0));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final item = handler.mediaItem.value;
    expect(item?.artist, 'Some Artist');
    expect(item?.album, 'Some Album');
    expect(item?.artUri, Uri.parse('https://example.com/app.jpg'));
  });

  test('transport state toggles pause/play with playback', () async {
    final handler = AuroraAudioHandler();
    final controller = _controller(
      engine: FakeAudioEngine(),
      handler: handler,
    );
    addTearDown(controller.dispose);

    await controller.playTrack(_track(0));
    var state = handler.playbackState.value;
    expect(state.playing, isTrue);
    expect(
      state.controls.map((c) => c.action),
      contains(MediaAction.pause),
    );
    expect(
      state.controls.map((c) => c.action),
      isNot(contains(MediaAction.play)),
    );

    await controller.pause();
    state = handler.playbackState.value;
    expect(state.playing, isFalse);
    expect(
      state.controls.map((c) => c.action),
      contains(MediaAction.play),
    );
    expect(
      state.controls.map((c) => c.action),
      contains(MediaAction.skipToNext),
    );
    expect(
      state.controls.map((c) => c.action),
      contains(MediaAction.skipToPrevious),
    );
    expect(state.systemActions, contains(MediaAction.seek));
  });

  test('position ticks keep playbackState position live', () async {
    final engine = FakeAudioEngine();
    final handler = AuroraAudioHandler();
    final controller = _controller(engine: engine, handler: handler);
    addTearDown(controller.dispose);

    await controller.playTrack(_track(0));
    engine.pushPosition(const Duration(seconds: 7));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(
      handler.playbackState.value.updatePosition,
      const Duration(seconds: 7),
    );
  });

  test('OS gestures drive the controller (play/pause/skip/seek/stop)',
      () async {
    final handler = AuroraAudioHandler();
    final controller = _controller(
      engine: FakeAudioEngine(),
      handler: handler,
    );
    addTearDown(controller.dispose);

    await controller.playQueue(<Track>[_track(0), _track(1)]);
    await controller.pause();
    expect(controller.info.status, PlaybackStatus.paused);

    await handler.play();
    expect(controller.info.status, PlaybackStatus.playing);

    await handler.pause();
    expect(controller.info.status, PlaybackStatus.paused);

    await handler.seek(const Duration(seconds: 30));
    expect(controller.info.position, const Duration(seconds: 30));

    await handler.skipToNext();
    expect(controller.info.track?.id, 'local:track-1');

    // A fresh item starts at position zero, so previous steps back
    // (above 3s it would restart instead, per the spec rule).
    await handler.seek(Duration.zero);
    await handler.skipToPrevious();
    expect(controller.info.track?.id, 'local:track-0');

    await handler.stop();
    expect(controller.info.status, PlaybackStatus.idle);
    expect(handler.mediaItem.value, isNull);
  });
}
