import 'package:audio_service/audio_service.dart';
import 'package:aurora_core/aurora_core.dart';
import 'package:flutter/foundation.dart';

/// Builds the audio-service config (foreground notification, spec 8).
///
/// Used by app bootstrap (`AudioService.init`); kept here so channel ids
/// stay in one place. Android 13+ compact actions: prev / play-pause /
/// next. Headset/bluetooth play-pause arrives as media-button intents.
/// The plugin creates the channel at `IMPORTANCE_LOW` natively and uses
/// the existing app icon by default, so no extra assets or manifest
/// entries are needed for the notification itself.
AudioServiceConfig get auroraAudioServiceConfig => const AudioServiceConfig(
  androidNotificationChannelId: 'aurora.playback',
  androidNotificationChannelName: 'Aurora playback',
  androidNotificationChannelDescription: 'Music playback controls',
  // Let Android manage the media notification lifecycle through the
  // MediaSession instead of forcing an ongoing foreground notification.
  // This is required when keeping the media controls alive while paused.
  androidNotificationOngoing: false,
  androidStopForegroundOnPause: false,
  // Let audio_service prefetch MediaItem artwork for Android's media card.
  preloadArtwork: true,
);

/// Maps a [Track] to a lock-screen/notification [MediaItem].
MediaItem trackToMediaItem(
  Track track, {
  String? artist,
  String? album,
  Uri? artUri,
  String? titleOverride,
  String? description,
}) => MediaItem(
  id: track.id,
  title: titleOverride ?? track.title,
  artist: artist,
  album: album,
  duration: track.durationMs > 0
      ? Duration(milliseconds: track.durationMs)
      : null,
  artUri: artUri,
);

/// `audio_service` bridge (notification, lock screen, headset).
///
/// Thin by design: transport callbacks are attached by the
/// `PlaybackController` after construction (either side can be faked in
/// tests). State flows controller → handler → OS; gestures flow OS →
/// handler → controller. Audio focus + ducking are configured on the
/// shared `AudioSession` (see `configureAudioSession`); focus loss
/// surfaces as engine pauses, which the controller mirrors here.
final class AuroraAudioHandler extends BaseAudioHandler {
  /// Creates the handler (the controller attaches transport callbacks).
  AuroraAudioHandler();

  /// OS play gesture.
  Future<void> Function()? onPlayRequest;

  /// OS pause gesture.
  Future<void> Function()? onPauseRequest;

  /// OS seek gesture.
  Future<void> Function(Duration position)? onSeekRequest;

  /// OS next gesture (swipe on the mini-player maps here too).
  Future<void> Function()? onNextRequest;

  /// OS previous gesture.
  Future<void> Function()? onPreviousRequest;

  /// OS stop gesture (clears the notification).
  Future<void> Function()? onStopRequest;

  /// Quick-like action from the Android media notification.
  Future<void> Function()? onLikeRequest;

  /// Attaches transport callbacks (the controller calls this once).
  void attachTransport({
    required Future<void> Function() onPlay,
    required Future<void> Function() onPause,
    required Future<void> Function(Duration position) onSeek,
    required Future<void> Function() onNext,
    required Future<void> Function() onPrevious,
    required Future<void> Function() onStop,
  }) {
    onPlayRequest = onPlay;
    onPauseRequest = onPause;
    onSeekRequest = onSeek;
    onNextRequest = onNext;
    onPreviousRequest = onPrevious;
    onStopRequest = onStop;
  }

  @override
  Future<void> play() async {
    debugPrint('AURORA_DIAG handler play');
    await onPlayRequest?.call();
  }

  @override
  Future<void> pause() async {
    debugPrint('AURORA_DIAG handler pause');
    await onPauseRequest?.call();
  }

  @override
  Future<void> seek(Duration position) async {
    debugPrint('AURORA_DIAG handler seek pos=${position.inMilliseconds}ms');
    await onSeekRequest?.call(position);
  }

  @override
  Future<void> skipToNext() async {
    debugPrint('AURORA_DIAG handler skipToNext');
    await onNextRequest?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    debugPrint('AURORA_DIAG handler skipToPrevious');
    await onPreviousRequest?.call();
  }

  @override
  Future<void> stop() async {
    debugPrint('AURORA_DIAG handler stop');
    await onStopRequest?.call();
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'toggle_like') {
      debugPrint('AURORA_DIAG handler toggle_like');
      await onLikeRequest?.call();
      return null;
    }
    return super.customAction(name, extras);
  }

  /// Publishes the current item (null clears the notification content).
  void setCurrentItem(MediaItem? item) {
    debugPrint(
      'AURORA_DIAG handler mediaitem-set '
      'id=${item?.id} title=${item?.title} '
      'art=${item?.artUri}',
    );
    mediaItem.add(item);
  }

  /// Publishes the queue for the expanded notification / auto clients.
  void setQueueItems(List<MediaItem> items) {
    debugPrint('AURORA_DIAG handler queue-set count=${items.length}');
    queue.add(items);
  }

  /// Publishes transport state (called on every controller transition).
  ///
  /// Single play/pause toggle (Spotify-style): the icon tracks [playing]
  /// so the compact notification + lockscreen never show a stale
  /// play-while-audible button. `seek` stays a system action (lockscreen
  /// scrubber, BT absolute-volume clients); swipe-dismiss clears via [stop].
  void publishState({
    required AudioProcessingState processing,
    required bool playing,
    required Duration position,
    required double speed,
    int? queueIndex,
  }) {
    playbackState.add(
      PlaybackState(
        controls: <MediaControl>[
          MediaControl.custom(
            androidIcon: 'drawable/ic_baseline_favorite_24',
            label: 'Like',
            name: 'toggle_like',
          ),
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const <MediaAction>{MediaAction.seek},
        androidCompactActionIndices: const <int>[0, 2, 3],
        processingState: processing,
        playing: playing,
        updatePosition: position,
        speed: speed,
        queueIndex: queueIndex,
      ),
    );
  }
}
