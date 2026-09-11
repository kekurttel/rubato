import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_providers.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_service.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wired mini-player: cover 48, title, artist, play, like, 2px bar.
///
/// Tap or swipe-up opens Now Playing; horizontal swipes skip
/// prev/next (the swipe surface of [AuroraMiniPlayer] plus a
/// vertical drag wrapper). Renders nothing until a track loads.
class WiredMiniPlayer extends ConsumerWidget {
  /// Creates the wired mini-player.
  const WiredMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(nowPlayingProvider).valueOrNull;
    final service = ref.watch(nowPlayingServiceProvider);
    final track = info?.track;
    if (info == null || track == null) {
      return const SizedBox.shrink();
    }
    final art = ref.watch(localTrackArtProvider(track.id)).valueOrNull;
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < 0) {
          unawaited(context.push('/now-playing'));
        }
      },
      child: AuroraMiniPlayer(
        title: track.title,
        artist: service?.artistLine(track) ?? 'Unknown artist',
        isPlaying: info.isPlaying,
        progress: info.progress,
        likeState: info.likeState,
        coverLocalPath: art,
        coverImageUrl: art == null ? trackFallbackThumbnailUrl(track) : null,
        onTap: () => unawaited(context.push('/now-playing')),
        onTogglePlay: service?.toggle,
        onNext: service?.next,
        onPrevious: service?.previous,
        onLikeChanged: service?.setLike,
      ),
    );
  }
}

/// Formats [duration] as `m:ss` (empty when unknown).
String formatPlayerDuration(Duration duration) {
  if (duration.inMilliseconds <= 0) {
    return '';
  }
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Downloads the current track (quality picker, then enqueue).
Future<void> downloadCurrentTrack(
  /// Build context for the picker.
  BuildContext context,

  /// Player boundary.
  NowPlayingService service,
) async {
  final quality = await QualityPickerSheet.show(
    context,
    initial: Quality.high,
  );
  if (quality == null) {
    return;
  }
  await service.download(quality);
}
