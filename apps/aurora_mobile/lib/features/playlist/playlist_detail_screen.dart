import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/downloads/download_providers.dart';
import 'package:aurora_mobile/features/library/detail_providers.dart';
import 'package:aurora_mobile/features/library/detail_widgets.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/library/library_service.dart';
import 'package:aurora_mobile/features/library/library_widgets.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_providers.dart';
import 'package:aurora_mobile/features/search/search_providers.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Playlist detail (`/playlist/:id`): header with title, rename/delete
/// menu, and play-all, plus the track list in position order.
///
/// Tapping a row plays the playlist from that position through the
/// library service. User lists reorder via the drag handles (persisted
/// through the service move API); the `liked` system list renders a
/// plain list. Unknown ids render a not-found state, never a throw.
class PlaylistDetailScreen extends ConsumerWidget {
  /// Creates the screen for [playlistId].
  const PlaylistDetailScreen({required this.playlistId, super.key});

  /// Playlist id from the route (may be unknown).
  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(libraryPlaylistsProvider);
    return playlists.when(
      data: (lists) {
        Playlist? found;
        for (final playlist in lists) {
          if (playlist.id == playlistId) {
            found = playlist;
          }
        }
        final playlist = found;
        if (playlist == null) {
          return AuroraScaffold(
            appBar: AppBar(title: const Text('Playlist')),
            body: SafeArea(
              child: EmptyState(
                title: 'Playlist not found',
                message: 'It may have been deleted.',
                icon: Icons.queue_music_outlined,
                actionLabel: 'Back',
                onAction: () => context.pop(),
              ),
            ),
          );
        }
        return _PlaylistDetailBody(playlist: playlist);
      },
      loading: () => AuroraScaffold(
        appBar: AppBar(title: const Text('Playlist')),
        body: const SafeArea(child: SkeletonTrackList()),
      ),
      error: (error, _) => AuroraScaffold(
        appBar: AppBar(title: const Text('Playlist')),
        body: SafeArea(
          child: ErrorState(
            message: 'Could not load playlists.',
            onRetry: () => ref.invalidate(libraryPlaylistsProvider),
          ),
        ),
      ),
    );
  }
}

/// Loaded playlist body: header + tracks.
class _PlaylistDetailBody extends ConsumerWidget {
  /// Creates the body for [playlist].
  const _PlaylistDetailBody({required this.playlist});

  /// Playlist to render (known to exist).
  final Playlist playlist;

  /// Enqueues every track without a download job at one picked
  /// quality, through the existing search download actions.
  Future<void> _downloadAll(
    BuildContext context,
    WidgetRef ref,
    List<Track> tracks,
  ) async {
    final actions = ref.read(searchActionsProvider);
    if (actions == null) {
      return;
    }
    final missing = <Track>[
      for (final track in tracks)
        if (actions.downloadStateFor(track.id) == null &&
            shouldShowDownloadAction(track))
          track,
    ];
    if (missing.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All tracks are already queued or downloaded.'),
          ),
        );
      }
      return;
    }
    final quality = await QualityPickerSheet.show(
      context,
      initial: ref.read(downloadQualityProvider),
    );
    if (quality == null || !context.mounted) {
      return;
    }
    for (final track in missing) {
      await actions.enqueueDownload(track, quality);
    }
    if (context.mounted) {
      final noun = missing.length == 1 ? 'track' : 'tracks';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Queued ${missing.length} $noun.')),
      );
    }
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final service = ref.read(libraryServiceProvider);
    if (service == null) {
      return;
    }
    if (action == 'rename') {
      final title = await showPlaylistTitleDialog(
        context,
        title: 'Rename playlist',
        initial: playlist.title,
      );
      if (title != null) {
        await service.renamePlaylist(playlist.id, title);
      }
    } else if (action == 'delete') {
      await service.deletePlaylist(playlist.id);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(libraryServiceProvider);
    final searchActions = ref.watch(searchActionsProvider);
    final tracksAsync = ref.watch(
      playlistDetailTracksProvider(playlist.id),
    );
    final playingId = ref.watch(nowPlayingProvider).valueOrNull?.track?.id;
    return AuroraScaffold(
      appBar: AppBar(
        title: Text(playlist.title),
        actions: [
          if (!playlist.isSystem && service != null)
            PopupMenuButton<String>(
              onSelected: (action) => _onMenu(context, ref, action),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'rename',
                  child: Text('Rename'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
        ],
      ),
      body: tracksAsync.when(
        skipLoadingOnReload: true,
        data: (tracks) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PlaylistHeader(
              playlist: playlist,
              tracks: tracks,
              onPlayAll: service == null || tracks.isEmpty
                  ? null
                  : () => service.playTracks(tracks),
              downloadAll: searchActions == null || tracks.isEmpty
                  ? null
                  : () => _downloadAll(context, ref, tracks),
            ),
            Expanded(
              child: tracks.isEmpty
                  ? EmptyState(
                      title: playlist.isSystem
                          ? 'Nothing liked yet'
                          : 'This playlist is empty',
                      message: playlist.isSystem
                          ? 'Tap the heart on anything playing '
                                'and it lands here.'
                          : 'Add tracks from any overflow menu.',
                      icon: playlist.isSystem
                          ? Icons.favorite_border
                          : Icons.queue_music_outlined,
                    )
                  : playlist.isSystem
                  ? ListView(
                      children: [
                        for (var i = 0; i < tracks.length; i++)
                          _row(
                            context,
                            ref,
                            service,
                            tracks,
                            i,
                            playingId,
                          ),
                      ],
                    )
                  : ReorderableListView.builder(
                      itemCount: tracks.length,
                      onReorderItem: (from, to) => service?.reorderEntry(
                        playlist.id,
                        from,
                        to,
                      ),
                      itemBuilder: (context, i) => _row(
                        context,
                        ref,
                        service,
                        tracks,
                        i,
                        playingId,
                      ),
                    ),
            ),
          ],
        ),
        loading: () => const SkeletonTrackList(),
        error: (error, _) => ErrorState(
          message: 'Could not load playlist tracks.',
          onRetry: () =>
              ref.invalidate(playlistDetailTracksProvider(playlist.id)),
        ),
      ),
    );
  }

  /// One row: tap plays from the position, overflow edits the queue or
  /// the membership. User lists expose the drag handle for reorder.
  DetailTrackRow _row(
    BuildContext context,
    WidgetRef ref,
    LibraryService? service,
    List<Track> tracks,
    int index,
    String? playingId,
  ) {
    final track = tracks[index];
    return DetailTrackRow(
      key: ValueKey(track.id),
      track: track,
      artistLine: service?.artistLine(track) ?? 'Unknown artist',
      isPlaying: track.id == playingId,
      dragIndex: playlist.isSystem ? null : index,
      onTap: () => service?.playTracks(tracks, startIndex: index),
      onOverflowTap: () => DetailTrackOverflow.show(
        context,
        ref: ref,
        track: track,
        playlistId: playlist.id,
      ),
    );
  }
}

/// Playlist header: cover monogram, title, count/length, play-all,
/// and batch download-all for missing tracks.
class _PlaylistHeader extends StatelessWidget {
  /// Creates the header.
  const _PlaylistHeader({
    required this.playlist,
    required this.tracks,
    this.onPlayAll,
    this.downloadAll,
  });

  /// Playlist to render.
  final Playlist playlist;

  /// Resolved tracks (for the count/length line).
  final List<Track> tracks;

  /// Play-all tap (null hides the button).
  final VoidCallback? onPlayAll;

  /// Download-all tap (null hides the button).
  final VoidCallback? downloadAll;

  @override
  Widget build(BuildContext context) {
    final play = onPlayAll;
    final download = downloadAll;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverImage(
            monogram: playlist.title,
            size: 96,
            borderRadius: 16,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playlist.title,
                  style: AuroraType.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  detailTracksSubtitle(tracks),
                  style: AuroraType.bodySmall,
                ),
                if (playlist.description != null &&
                    playlist.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    playlist.description!,
                    style: AuroraType.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (play != null || download != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (play != null)
                        FilledButton.icon(
                          onPressed: play,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                        ),
                      if (download != null)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download all'),
                          onPressed: download,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
