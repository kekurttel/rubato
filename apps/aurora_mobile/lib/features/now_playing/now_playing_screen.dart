import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/library/library_widgets.dart';
import 'package:aurora_mobile/features/now_playing/mini_player_view.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_providers.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_service.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full-screen Now Playing (spec 13.8): dismissible down, artwork
/// scrim, source badge, stream/download controls, slider seek,
/// transport, shuffle/queue/repeat, queue sheet with the radio
/// toggle, and local-only lyrics.
class NowPlayingScreen extends ConsumerWidget {
  /// Creates the now playing screen.
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(nowPlayingProvider).valueOrNull;
    final service = ref.watch(nowPlayingServiceProvider);
    final track = info?.track;
    if (info == null || track == null || service == null) {
      return AuroraScaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: 'Close player',
          ),
          title: const Text('Now Playing'),
        ),
        body: const SafeArea(
          child: EmptyState(
            title: 'Nothing playing yet',
            message: 'Pick a track and it shows up here.',
          ),
        ),
      );
    }
    return AuroraScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  tooltip: 'Close player',
                ),
                const Spacer(),
                _SourceBadgePill(info: info),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _Artwork(info: info, service: service),
                    const SizedBox(height: 16),
                    _TitleBlock(
                      info: info,
                      service: service,
                    ),
                    const SizedBox(height: 12),
                    _ActionRow(
                      info: info,
                      service: service,
                      track: track,
                    ),
                    _SeekRow(info: info, service: service),
                    _TransportRow(info: info, service: service),
                    _ModeRow(
                      info: info,
                      service: service,
                    ),
                    if (info.lyrics != null) _LyricsBlock(lyrics: info.lyrics!),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Source badge pill: `Local` / `Stream` / `Downloaded` + quality.
class _SourceBadgePill extends StatelessWidget {
  /// Creates the pill.
  const _SourceBadgePill({required this.info});

  /// Current frame.
  final NowPlayingInfo info;

  @override
  Widget build(BuildContext context) {
    final label = StringBuffer('[${sourceBadgeLabel(info.badge)}]');
    if (info.qualityLabel != null && info.qualityLabel!.isNotEmpty) {
      label.write(' ${info.qualityLabel}');
    }
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AuroraColors.bg2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label.toString(), style: AuroraType.labelSmall),
    );
  }
}

/// Artwork with scrim; horizontal swipe skips prev/next.
class _Artwork extends ConsumerWidget {
  /// Creates the artwork.
  const _Artwork({required this.info, required this.service});

  /// Current frame.
  final NowPlayingInfo info;

  /// Player boundary.
  final NowPlayingService service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = info.track!;
    final art = ref.watch(localTrackArtProvider(track.id)).valueOrNull;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          unawaited(service.next());
        } else if (velocity > 0) {
          unawaited(service.previous());
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: AuroraColors.accentWash,
              blurRadius: 48,
              spreadRadius: -12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              CoverImage(
                monogram: track.title,
                localPath: art,
                imageUrl: art == null ? trackFallbackThumbnailUrl(track) : null,
                size: MediaQuery.sizeOf(context).shortestSide - 32,
                borderRadius: 28,
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AuroraColors.scrim,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Title (fade on overflow) + tappable artist line.
class _TitleBlock extends StatelessWidget {
  /// Creates the block.
  const _TitleBlock({required this.info, required this.service});

  /// Current frame.
  final NowPlayingInfo info;

  /// Player boundary.
  final NowPlayingService service;

  @override
  Widget build(BuildContext context) {
    final track = info.track!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.title,
            style: AuroraType.displayLarge,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: track.artistIds.isEmpty
                ? null
                : () => context.push(
                    '/artist/${Uri.encodeComponent(track.artistIds.first)}',
                  ),
            child: Text(
              service.artistLine(track),
              style: AuroraType.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Like / playlist / download / stream-toggle / more row.
class _ActionRow extends StatelessWidget {
  /// Creates the row.
  const _ActionRow({
    required this.info,
    required this.service,
    required this.track,
  });

  /// Current frame.
  final NowPlayingInfo info;

  /// Player boundary.
  final NowPlayingService service;

  /// Current track.
  final Track track;

  @override
  Widget build(BuildContext context) {
    final downloadState = info.downloadState;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LikeButton(
            likeState: info.likeState,
            onChanged: service.setLike,
          ),
          IconButton(
            onPressed: () => AddToPlaylistSheet.show(context, track.id),
            icon: const Icon(Icons.playlist_add_outlined),
            tooltip: 'Add to playlist',
          ),
          if (downloadState == null && shouldShowDownloadAction(track))
            IconButton(
              onPressed: () => downloadCurrentTrack(context, service),
              icon: const Icon(Icons.download_outlined),
              tooltip: 'Download',
            )
          else if (downloadState != null)
            DownloadGlyph(
              state: downloadState,
              progress: info.downloadProgress,
              onTap: downloadState == DownloadState.completed
                  ? null
                  : () => downloadCurrentTrack(context, service),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Stream', style: AuroraType.bodySmall),
              Switch(
                value: info.useStream,
                onChanged: (next) => service.setUseStream(useStream: next),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _MoreSheet.show(context, track),
            icon: const Icon(Icons.more_vert),
            tooltip: 'More actions',
          ),
        ],
      ),
    );
  }
}

/// Position slider with current / remaining labels.
class _SeekRow extends StatelessWidget {
  /// Creates the row.
  const _SeekRow({required this.info, required this.service});

  /// Current frame.
  final NowPlayingInfo info;

  /// Player boundary.
  final NowPlayingService service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Slider(
            value: info.progress,
            onChanged: (value) => service.seek(
              Duration(
                milliseconds: (info.duration.inMilliseconds * value).round(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatPlayerDuration(info.position),
                style: AuroraType.bodySmall,
              ),
              Text(
                '-${formatPlayerDuration(info.remaining)}',
                style: AuroraType.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Prev / play / next transport.
class _TransportRow extends StatelessWidget {
  /// Creates the row.
  const _TransportRow({required this.info, required this.service});

  /// Current frame.
  final NowPlayingInfo info;

  /// Player boundary.
  final NowPlayingService service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: service.previous,
            icon: const Icon(Icons.skip_previous),
            iconSize: 40,
            tooltip: 'Previous',
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: service.toggle,
            icon: Icon(
              info.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
            ),
            iconSize: 64,
            color: AuroraColors.textHi,
            tooltip: info.isPlaying ? 'Pause' : 'Play',
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: service.next,
            icon: const Icon(Icons.skip_next),
            iconSize: 40,
            tooltip: 'Next',
          ),
        ],
      ),
    );
  }
}

/// Shuffle / queue / repeat row.
class _ModeRow extends StatelessWidget {
  /// Creates the row.
  const _ModeRow({required this.info, required this.service});

  /// Current frame.
  final NowPlayingInfo info;

  /// Player boundary.
  final NowPlayingService service;

  @override
  Widget build(BuildContext context) {
    final repeatIcon = switch (info.repeat) {
      RepeatSetting.off => Icons.repeat_outlined,
      RepeatSetting.one => Icons.repeat_one_on_outlined,
      RepeatSetting.all => Icons.repeat_on_outlined,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => service.setShuffle(enabled: !info.shuffle),
            icon: Icon(
              Icons.shuffle_outlined,
              color: info.shuffle ? AuroraColors.accent : AuroraColors.textMid,
            ),
            tooltip: 'Shuffle',
          ),
          IconButton(
            onPressed: () => QueueSheet.show(context),
            icon: const Icon(Icons.queue_music_outlined),
            tooltip: 'Queue',
          ),
          IconButton(
            onPressed: service.cycleRepeat,
            icon: Icon(
              repeatIcon,
              color: info.repeat == RepeatSetting.off
                  ? AuroraColors.textMid
                  : AuroraColors.accent,
            ),
            tooltip: 'Repeat',
          ),
        ],
      ),
    );
  }
}

/// Local-only lyrics block (hidden when no sidecar exists).
class _LyricsBlock extends StatelessWidget {
  /// Creates the block.
  const _LyricsBlock({required this.lyrics});

  /// Parsed local LRC / embedded lyrics text.
  final String lyrics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lyrics', style: AuroraType.labelSmall),
          const SizedBox(height: 8),
          Text(lyrics, style: AuroraType.bodyMedium),
        ],
      ),
    );
  }
}

/// Overflow sheet: go to album / artist.
abstract final class _MoreSheet {
  /// Shows the sheet for [track].
  static Future<void> show(BuildContext context, Track track) =>
      showAuroraBottomSheet<void>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (track.albumId != null)
                ListTile(
                  leading: const Icon(Icons.album_outlined),
                  title: const Text('Go to album'),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push(
                      '/album/${Uri.encodeComponent(track.albumId!)}',
                    );
                  },
                ),
              if (track.artistIds.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Go to artist'),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.push(
                      '/artist/${Uri.encodeComponent(track.artistIds.first)}',
                    );
                  },
                ),
            ],
          ),
        ),
      );
}

/// Queue sheet: current, next up, reorder, radio toggle.
abstract final class QueueSheet {
  /// Shows the queue sheet.
  static Future<void> show(BuildContext context) => showAuroraBottomSheet<void>(
    context: context,
    builder: (context) => const _QueueBody(),
  );
}

/// Queue sheet body (watches live frames).
class _QueueBody extends ConsumerWidget {
  /// Creates the body.
  const _QueueBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(nowPlayingProvider).valueOrNull;
    final service = ref.watch(nowPlayingServiceProvider);
    if (info == null || service == null) {
      return const SizedBox.shrink();
    }
    final upcoming = info.queue.length > info.currentIndex + 1
        ? info.queue.sublist(info.currentIndex + 1)
        : const <Track>[];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Radio', style: AuroraType.titleSmall),
              subtitle: const Text(
                'Keep playing similar tracks.',
                style: AuroraType.bodySmall,
              ),
              value: info.radioEnabled,
              onChanged: (next) => service.setRadioEnabled(enabled: next),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text('Next up', style: AuroraType.labelSmall),
            ),
            Flexible(
              child: ReorderableListView(
                shrinkWrap: true,
                onReorderItem: service.reorderQueue,
                children: [
                  for (var i = 0; i < upcoming.length; i++)
                    ListTile(
                      key: ValueKey(upcoming[i].id),
                      title: Text(
                        upcoming[i].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        service.artistLine(upcoming[i]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
