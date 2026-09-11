import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:meta/meta.dart';

/// Engine-side processing state (mirrors `just_audio`, spec section 8).
enum EngineProcessing {
  /// Nothing loaded.
  idle,

  /// Opening the source.
  loading,

  /// Streaming bytes (Stream-mode buffering).
  buffering,

  /// Ready to play.
  ready,

  /// Natural end of the item.
  completed,
}

/// Player-state frame pushed by the engine.
@immutable
final class EngineState {
  /// Creates a frame.
  const EngineState({required this.playing, required this.processing});

  /// Whether audio is audible.
  final bool playing;

  /// Source processing state.
  final EngineProcessing processing;
}

/// Audio-output boundary behind the controller (spec section 8).
///
/// The app injects [JustAudioEngine]; tests inject a fake. Headset /
/// bluetooth play-pause arrives here as engine state changes (media
/// buttons route through the audio handler into the controller).
abstract class AudioEngine {
  /// Player-state frames.
  Stream<EngineState> get state;

  /// Position frames (throttled by the engine).
  Stream<Duration> get position;

  /// Duration frames (null until the source header parses).
  Stream<Duration?> get duration;

  /// Fires on headset disconnect / audio becoming noisy.
  Stream<void> get becomingNoisy;

  /// Current position (synchronous read for the previous-track rule).
  Duration get positionNow;

  /// Current duration, if known.
  Duration? get durationNow;

  /// Loads a provider-authorized stream URL.
  Future<void> setSourceUri(Uri uri, {Map<String, String>? headers});

  /// Loads a local file.
  Future<void> setSourceFile(String path);

  /// Starts (or resumes) playback.
  Future<void> play();

  /// Suspends playback (keeps the source).
  Future<void> pause();

  /// Unloads the source (idle path).
  Future<void> stop();

  /// Seeks within the current item.
  Future<void> seek(Duration position);

  /// Sets volume 0..1.
  Future<void> setVolume(double volume);

  /// Releases native resources.
  Future<void> dispose();
}

/// Configures the shared audio session (focus + ducking, spec section 8).
///
/// Music configuration: transient focus loss ducks; permanent loss and
/// headset disconnect pause (the controller subscribes to the engine
/// `becomingNoisy` stream, which this session feeds).
Future<void> configureAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
}

/// Whether [uri] is a platform URI (`content://`/`file://`) rather than
/// a raw filesystem path. Pure (no I/O), safe in unit tests.
bool isContentOrFileUri(String uri) {
  final lower = uri.toLowerCase();
  return lower.startsWith('content://') || lower.startsWith('file://');
}

/// Maps a local playable to the `just_audio` URI.
///
/// `content://` (MediaStore scan, scoped storage) and `file://` URIs
/// parse directly; raw filesystem paths go through `Uri.file`. Pure
/// (no I/O): unit-testable without a device. `Uri.file(contentUri)`
/// mangles to `file:///content%3A...` and never plays — the device-proven
/// local-playback break.
Uri localPlaybackUri(String path) {
  if (isContentOrFileUri(path)) {
    return Uri.parse(path);
  }
  return Uri.file(path);
}

/// `just_audio` engine (ExoPlayer/Media3 on Android under the hood).
final class JustAudioEngine implements AudioEngine {
  /// Creates the engine over [player] (a fresh one by default).
  JustAudioEngine({ja.AudioPlayer? player})
    : _player = player ?? ja.AudioPlayer();

  final ja.AudioPlayer _player;
  StreamSubscription<void>? _noisySub;
  final StreamController<void> _noisy = StreamController<void>.broadcast();

  /// Starts session wiring (call once from app bootstrap).
  Future<void> init() async {
    await configureAudioSession();
    final session = await AudioSession.instance;
    await _noisySub?.cancel();
    _noisySub = session.becomingNoisyEventStream.listen((_) {
      if (!_noisy.isClosed) {
        _noisy.add(null);
      }
    });
  }

  @override
  Stream<void> get becomingNoisy => _noisy.stream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Duration? get durationNow => _player.duration;

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Duration get positionNow => _player.position;

  @override
  Stream<EngineState> get state => _player.playerStateStream.map(
    (s) => EngineState(
      playing: s.playing,
      processing: switch (s.processingState) {
        ja.ProcessingState.idle => EngineProcessing.idle,
        ja.ProcessingState.loading => EngineProcessing.loading,
        ja.ProcessingState.buffering => EngineProcessing.buffering,
        ja.ProcessingState.ready => EngineProcessing.ready,
        ja.ProcessingState.completed => EngineProcessing.completed,
      },
    ),
  );

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSourceFile(String path) =>
      _player.setAudioSource(ja.AudioSource.uri(localPlaybackUri(path)));

  @override
  Future<void> setSourceUri(Uri uri, {Map<String, String>? headers}) =>
      _player.setAudioSource(ja.AudioSource.uri(uri, headers: headers));

  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 1).toDouble());

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    await _noisySub?.cancel();
    await _noisy.close();
    await _player.dispose();
  }
}
