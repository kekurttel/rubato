import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_providers.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_service.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Spotify-style bottom player bar for wide (desktop/tablet) screens.
///
/// Three zones: track identity + like (left), transport + seek (center),
/// volume + expand (right). Renders nothing until a track loads; the
/// mobile shell keeps using the mini-player instead.
class DesktopPlayerBar extends ConsumerWidget {
  /// Creates the desktop player bar.
  const DesktopPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(nowPlayingProvider).valueOrNull;
    final service = ref.watch(nowPlayingServiceProvider);
    final track = info?.track;
    if (info == null || track == null || service == null) {
      return const SizedBox.shrink();
    }
    final art = ref.watch(localTrackArtProvider(track.id)).valueOrNull;
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      height: 88,
      decoration: const BoxDecoration(
        color: AuroraColors.bg1,
        border: Border(top: BorderSide(color: AuroraColors.bg3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CoverImage(
                  monogram: track.title,
                  localPath: art,
                  imageUrl: art == null
                      ? trackFallbackThumbnailUrl(track)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: AuroraType.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.artistLine(track),
                        style: AuroraType.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                LikeButton(
                  likeState: info.likeState,
                  onChanged: (next) =>
                      unawaited(service.setLike(next)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => unawaited(
                        service.setShuffle(enabled: !info.shuffle),
                      ),
                      icon: Icon(
                        info.shuffle
                            ? Icons.shuffle_on_outlined
                            : Icons.shuffle_outlined,
                      ),
                      color: info.shuffle ? accent : AuroraColors.textMid,
                      tooltip: 'Shuffle',
                    ),
                    IconButton(
                      onPressed: () => unawaited(service.previous()),
                      icon: const Icon(Icons.skip_previous),
                      tooltip: 'Previous',
                    ),
                    IconButton.filled(
                      onPressed: () => unawaited(service.toggle()),
                      icon: Icon(
                        info.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      tooltip: info.isPlaying ? 'Pause' : 'Play',
                    ),
                    IconButton(
                      onPressed: () => unawaited(service.next()),
                      icon: const Icon(Icons.skip_next),
                      tooltip: 'Next',
                    ),
                    IconButton(
                      onPressed: () => unawaited(service.cycleRepeat()),
                      icon: Icon(
                        info.repeat == RepeatSetting.one
                            ? Icons.repeat_one_on_outlined
                            : Icons.repeat_outlined,
                      ),
                      color: info.repeat == RepeatSetting.off
                          ? AuroraColors.textMid
                          : accent,
                      tooltip: 'Repeat',
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        _format(info.position),
                        style: AuroraType.bodySmall,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: info.progress,
                        onChanged: (value) {
                          final target = Duration(
                            milliseconds:
                                (info.duration.inMilliseconds * value)
                                    .round(),
                          );
                          unawaited(service.seek(target));
                        },
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        _format(info.duration),
                        style: AuroraType.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.volume_down_outlined,
                  color: AuroraColors.textMid,
                ),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: info.volume.clamp(0, 1).toDouble(),
                    onChanged: (value) =>
                        unawaited(service.setVolume(value)),
                  ),
                ),
                IconButton(
                  onPressed: () => unawaited(context.push('/now-playing')),
                  icon: const Icon(Icons.open_in_full_outlined),
                  tooltip: 'Now playing',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats [duration] as `m:ss` (empty when unknown).
String _format(Duration duration) {
  if (duration.inMilliseconds <= 0) {
    return '';
  }
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
