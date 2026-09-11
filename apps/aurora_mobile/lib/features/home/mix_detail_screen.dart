import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/home/home_providers.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:aurora_mobile/features/library/detail_widgets.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/library/library_widgets.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_providers.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail screen for a recommended mix (e.g. Daily Mix).
///
/// Displays the mix header (cover, title, subtitle, track count,
/// "Play all" and "Shuffle" buttons) and the list of tracks.
class MixDetailScreen extends ConsumerWidget {
  /// Creates a mix detail screen.
  const MixDetailScreen({
    required this.title,
    required this.subtitle,
    required this.entries,
    super.key,
  });

  /// Mix title (e.g. "Daily Mix 1").
  final String title;

  /// Seed line or description (e.g. artist, genre, or time bucket).
  final String subtitle;

  /// Ranked tracks in this mix.
  final List<HomeRecoEntry> entries;

  Future<void> _saveAsPlaylist(
    BuildContext context,
    WidgetRef ref,
    List<Track> tracks,
  ) async {
    final service = ref.read(libraryServiceProvider);
    if (service == null || tracks.isEmpty) {
      return;
    }
    final name = await showPlaylistTitleDialog(
      context,
      title: 'Save as playlist',
      initial: title,
    );
    if (name == null || name.trim().isEmpty || !context.mounted) {
      return;
    }
    final playlist = await service.createPlaylist(name.trim());
    for (final track in tracks) {
      await service.addToPlaylist(playlist.id, track.id);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved ${tracks.length} tracks to ${playlist.title}.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(homeActionsProvider);
    final playingId = ref.watch(nowPlayingProvider).valueOrNull?.track?.id;
    final tracks = [for (final entry in entries) entry.track];

    final first = entries.isEmpty ? null : entries.first;
    final firstId = first?.track.id;
    final localArt = firstId == null
        ? null
        : ref.watch(localTrackArtProvider(firstId)).valueOrNull;
    final fallbackUrl = localArt == null && first != null
        ? trackFallbackThumbnailUrl(first.track)
        : null;

    return AuroraScaffold(
      appBar: AppBar(title: Text(title)),
      body: tracks.isEmpty
          ? const SafeArea(
              child: EmptyState(
                title: 'No tracks in this mix',
                message: 'Mix tracks will appear here once refreshed.',
              ),
            )
          : ListView(
              children: [
                _MixHeader(
                  title: title,
                  subtitle: subtitle,
                  tracks: tracks,
                  coverMonogram: first?.track.title ?? title,
                  coverLocalPath: localArt,
                  coverImageUrl: fallbackUrl,
                  onPlayAll: actions == null
                      ? null
                      : () {
                          unawaited(actions.playTracks(tracks));
                        },
                  onShuffle: actions == null
                      ? null
                      : () {
                          final shuffled = List<Track>.of(tracks)..shuffle();
                          unawaited(actions.playTracks(shuffled));
                        },
                  onSaveAsPlaylist: () => _saveAsPlaylist(context, ref, tracks),
                ),
                const Divider(height: 1),
                for (var i = 0; i < tracks.length; i++)
                  LocalTrackTile(
                    key: ValueKey(tracks[i].id),
                    track: tracks[i],
                    artistLine:
                        actions?.artistLine(tracks[i]) ?? 'Unknown artist',
                    isPlaying: tracks[i].id == playingId,
                    onTap: actions == null
                        ? null
                        : () {
                            unawaited(
                              actions.playTracks(tracks, startIndex: i),
                            );
                          },
                    onOverflowTap: () => DetailTrackOverflow.show(
                      context,
                      ref: ref,
                      track: tracks[i],
                      origin: PlaySource.reco,
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

/// Header row for the mix detail page: cover, title, subtitle, buttons.
class _MixHeader extends StatelessWidget {
  const _MixHeader({
    required this.title,
    required this.subtitle,
    required this.tracks,
    required this.coverMonogram,
    this.coverLocalPath,
    this.coverImageUrl,
    this.onPlayAll,
    this.onShuffle,
    this.onSaveAsPlaylist,
  });

  final String title;
  final String subtitle;
  final List<Track> tracks;
  final String coverMonogram;
  final String? coverLocalPath;
  final String? coverImageUrl;
  final VoidCallback? onPlayAll;
  final VoidCallback? onShuffle;
  final VoidCallback? onSaveAsPlaylist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverImage(
                monogram: coverMonogram,
                localPath: coverLocalPath,
                imageUrl: coverImageUrl,
                size: 100,
                borderRadius: 16,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AuroraType.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AuroraType.bodyMedium.copyWith(
                          color: AuroraColors.textMid,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${tracks.length} tracks',
                      style: AuroraType.bodySmall.copyWith(
                        color: AuroraColors.textLow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (onPlayAll != null)
                FilledButton.icon(
                  onPressed: onPlayAll,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play all'),
                ),
              if (onPlayAll != null && onShuffle != null)
                const SizedBox(width: 12),
              if (onShuffle != null)
                OutlinedButton.icon(
                  onPressed: onShuffle,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Shuffle'),
                ),
              if (onSaveAsPlaylist != null) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onSaveAsPlaylist,
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Save playlist'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
