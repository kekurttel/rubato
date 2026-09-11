import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/downloads/download_providers.dart';
import 'package:aurora_mobile/features/library/detail_providers.dart';
import 'package:aurora_mobile/features/library/detail_widgets.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_providers.dart';
import 'package:aurora_mobile/features/search/search_providers.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Album detail (`/album/:id`): cover header with title, artist, year,
/// numbered track list with the playing indicator, play-all, and a
/// "Download all" action for missing tracks.
///
/// Tapping a row plays the album from that position through the
/// library service. Unknown ids render a not-found state, never a
/// throw. There is no similar-albums section: no service exposes
/// similarity, and the section renders only when one does.
class AlbumDetailScreen extends ConsumerWidget {
  /// Creates the screen for [albumId].
  const AlbumDetailScreen({required this.albumId, super.key});

  /// Album id from the route (may be unknown).
  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(libraryAlbumsProvider);
    return albums.when(
      data: (lists) {
        Album? found;
        for (final album in lists) {
          if (album.id == albumId) {
            found = album;
          }
        }
        final album = found;
        if (album == null) {
          return AuroraScaffold(
            appBar: AppBar(title: const Text('Album')),
            body: SafeArea(
              child: EmptyState(
                title: 'Album not found',
                message: 'It may have been removed by a rescan.',
                icon: Icons.album_outlined,
                actionLabel: 'Back',
                onAction: () => context.pop(),
              ),
            ),
          );
        }
        return _AlbumDetailBody(album: album);
      },
      loading: () => AuroraScaffold(
        appBar: AppBar(title: const Text('Album')),
        body: const SafeArea(child: SkeletonTrackList()),
      ),
      error: (error, _) => AuroraScaffold(
        appBar: AppBar(title: const Text('Album')),
        body: SafeArea(
          child: ErrorState(
            message: 'Could not load albums.',
            onRetry: () => ref.invalidate(libraryAlbumsProvider),
          ),
        ),
      ),
    );
  }
}

/// Loaded album body: header + numbered tracks.
class _AlbumDetailBody extends ConsumerWidget {
  /// Creates the body for [album].
  const _AlbumDetailBody({required this.album});

  /// Album to render (known to exist).
  final Album album;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(libraryServiceProvider);
    final searchActions = ref.watch(searchActionsProvider);
    final tracksAsync = ref.watch(albumDetailTracksProvider(album.id));
    final playingId = ref.watch(nowPlayingProvider).valueOrNull?.track?.id;
    final wiring = ref.watch(auroraWiringProvider);
    final artistNames = <String>[
      for (final id in album.artistIds)
        if (wiring?.artistNames[id] != null) wiring!.artistNames[id]!,
    ];
    final artistLine = artistNames.isEmpty
        ? 'Unknown artist'
        : artistNames.join(', ');
    return AuroraScaffold(
      appBar: AppBar(title: Text(album.title)),
      body: tracksAsync.when(
        skipLoadingOnReload: true,
        data: (tracks) => ListView(
          children: [
            _AlbumHeader(
              album: album,
              tracks: tracks,
              artistLine: artistLine,
              onArtistTap: album.artistIds.isEmpty
                  ? null
                  : () => context.push(
                      '/artist/${Uri.encodeComponent(album.artistIds.first)}',
                    ),
              onPlayAll: service == null || tracks.isEmpty
                  ? null
                  : () => service.playTracks(tracks),
              onDownloadAll:
                  service == null || searchActions == null || tracks.isEmpty ||
                      tracks.every((t) => !shouldShowDownloadAction(t))
                  ? null
                  : () => _downloadAll(context, ref, tracks),
            ),
            if (tracks.isEmpty)
              const EmptyState(
                title: 'No tracks grouped here yet',
                message: 'Rescan the library to regroup albums.',
                icon: Icons.album_outlined,
              )
            else
              for (var i = 0; i < tracks.length; i++)
                DetailTrackRow(
                  key: ValueKey(tracks[i].id),
                  track: tracks[i],
                  artistLine:
                      service?.artistLine(tracks[i]) ?? 'Unknown artist',
                  isPlaying: tracks[i].id == playingId,
                  trackNumber: i + 1,
                  onTap: () => service?.playTracks(tracks, startIndex: i),
                  onOverflowTap: () => DetailTrackOverflow.show(
                    context,
                    ref: ref,
                    track: tracks[i],
                    origin: PlaySource.album,
                  ),
                ),
          ],
        ),
        loading: () => const SkeletonTrackList(),
        error: (error, _) => ErrorState(
          message: 'Could not load album tracks.',
          onRetry: () => ref.invalidate(albumDetailTracksProvider(album.id)),
        ),
      ),
    );
  }
}

/// Album header: large cover, title, artist, year/count, actions.
class _AlbumHeader extends ConsumerWidget {
  /// Creates the header.
  const _AlbumHeader({
    required this.album,
    required this.tracks,
    required this.artistLine,
    this.onArtistTap,
    this.onPlayAll,
    this.onDownloadAll,
  });

  /// Album to render.
  final Album album;

  /// Resolved tracks (for the year/count line).
  final List<Track> tracks;

  /// Pre-joined artist names.
  final String artistLine;

  /// Artist-line tap (null disables).
  final VoidCallback? onArtistTap;

  /// Play-all tap (null hides the button).
  final VoidCallback? onPlayAll;

  /// Download-all tap (null hides the button).
  final VoidCallback? onDownloadAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final play = onPlayAll;
    final downloadAll = onDownloadAll;
    final year = album.year?.toString();
    final subtitle = detailTracksSubtitle(tracks);
    final meta = year == null ? subtitle : '$year · $subtitle';
    final art = ref.watch(localAlbumArtProvider(album.id)).valueOrNull;
    final fallbackUrl = art == null && tracks.isNotEmpty
        ? trackFallbackThumbnailUrl(tracks.first)
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverImage(
                monogram: album.title,
                localPath: art,
                imageUrl: fallbackUrl,
                size: 120,
                borderRadius: 16,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      album.title,
                      style: AuroraType.titleLarge,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onArtistTap,
                      child: Text(
                        artistLine,
                        style: AuroraType.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(meta, style: AuroraType.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (play != null)
                FilledButton.icon(
                  onPressed: play,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
              if (play != null && downloadAll != null)
                const SizedBox(width: 12),
              if (downloadAll != null)
                OutlinedButton.icon(
                  onPressed: downloadAll,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Download all'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
