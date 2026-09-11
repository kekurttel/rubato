import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/library/detail_providers.dart';
import 'package:aurora_mobile/features/library/detail_widgets.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_providers.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Artist detail (`/artist/:id`): header with the name and catalog
/// size, popular tracks (existing decayed-score stats), and the
/// artist's albums linking to the album route.
///
/// Tapping a popular row plays that shelf from the position through
/// the library service. Unknown ids render a not-found state, never a
/// throw. There is no similar-artists section: no cached similarity
/// exists, and the section renders only when one does.
class ArtistDetailScreen extends ConsumerWidget {
  /// Creates the screen for [artistId].
  const ArtistDetailScreen({required this.artistId, super.key});

  /// Artist id from the route (may be unknown).
  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(libraryArtistsProvider);
    return artists.when(
      data: (lists) {
        Artist? found;
        for (final artist in lists) {
          if (artist.id == artistId) {
            found = artist;
          }
        }
        final artist = found;
        if (artist == null) {
          return AuroraScaffold(
            appBar: AppBar(title: const Text('Artist')),
            body: SafeArea(
              child: EmptyState(
                title: 'Artist not found',
                message: 'They may have been removed by a rescan.',
                icon: Icons.person_outline,
                actionLabel: 'Back',
                onAction: () => context.pop(),
              ),
            ),
          );
        }
        return _ArtistDetailBody(artist: artist);
      },
      loading: () => AuroraScaffold(
        appBar: AppBar(title: const Text('Artist')),
        body: const SafeArea(child: SkeletonTrackList()),
      ),
      error: (error, _) => AuroraScaffold(
        appBar: AppBar(title: const Text('Artist')),
        body: SafeArea(
          child: ErrorState(
            message: 'Could not load artists.',
            onRetry: () => ref.invalidate(libraryArtistsProvider),
          ),
        ),
      ),
    );
  }
}

/// Loaded artist body: header, popular tracks, albums.
class _ArtistDetailBody extends ConsumerWidget {
  /// Creates the body for [artist].
  const _ArtistDetailBody({required this.artist});

  /// Artist to render (known to exist).
  final Artist artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(libraryServiceProvider);
    final popularAsync = ref.watch(
      artistPopularTracksProvider(artist.id),
    );
    final allTracksAsync = ref.watch(
      artistDetailTracksProvider(artist.id),
    );
    final albumsAsync = ref.watch(libraryAlbumsProvider);
    final playingId = ref.watch(nowPlayingProvider).valueOrNull?.track?.id;
    final trackCount = allTracksAsync.valueOrNull?.length ?? 0;
    final albums = <Album>[
      for (final album in albumsAsync.valueOrNull ?? const <Album>[])
        if (album.artistIds.contains(artist.id)) album,
    ];
    final noun = trackCount == 1 ? 'track' : 'tracks';
    final albumNoun = albums.length == 1 ? 'album' : 'albums';
    return AuroraScaffold(
      appBar: AppBar(title: Text(artist.name)),
      body: ListView(
        children: [
          _ArtistHeader(
            artist: artist,
            subtitle:
                '$trackCount $noun · '
                '${albums.length} $albumNoun',
          ),
          const SectionHeader(title: 'Popular'),
          popularAsync.when(
            skipLoadingOnReload: true,
            data: (popular) => popular.isEmpty
                ? const EmptyState(
                    title: 'No tracks for this artist yet',
                    message: 'Tracks appear here after a scan.',
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < popular.length; i++)
                        DetailTrackRow(
                          key: ValueKey(popular[i].id),
                          track: popular[i],
                          artistLine:
                              service?.artistLine(popular[i]) ?? artist.name,
                          isPlaying: popular[i].id == playingId,
                          trackNumber: i + 1,
                          onTap: () => service?.playTracks(
                            popular,
                            startIndex: i,
                          ),
                          onOverflowTap: () => DetailTrackOverflow.show(
                            context,
                            ref: ref,
                            track: popular[i],
                            origin: PlaySource.artist,
                          ),
                        ),
                    ],
                  ),
            loading: () => const SkeletonTrackList(count: 5),
            error: (error, _) => ErrorState(
              message: 'Could not load popular tracks.',
              onRetry: () => ref.invalidate(
                artistPopularTracksProvider(artist.id),
              ),
            ),
          ),
          if (albums.isNotEmpty) ...[
            const SectionHeader(title: 'Albums'),
            for (final album in albums) _ArtistAlbumRow(album: album),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// One album row of the artist page, with the scan-cached cover.
class _ArtistAlbumRow extends ConsumerWidget {
  /// Creates the row.
  const _ArtistAlbumRow({required this.album});

  /// Album to render.
  final Album album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final art = ref.watch(localAlbumArtProvider(album.id)).valueOrNull;
    return ListTile(
      leading: CoverImage(
        monogram: album.title,
        localPath: art,
        size: 48,
        borderRadius: 8,
      ),
      title: Text(
        album.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: album.year == null ? null : Text('${album.year}'),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () => context.push(
        '/album/${Uri.encodeComponent(album.id)}',
      ),
    );
  }
}

/// Artist header: large monogram, name, catalog size.
class _ArtistHeader extends StatelessWidget {
  /// Creates the header.
  const _ArtistHeader({required this.artist, required this.subtitle});

  /// Artist to render.
  final Artist artist;

  /// `N tracks · M albums` line.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          CoverImage(
            monogram: artist.name,
            imageUrl: artist.imageUrl,
            size: 96,
            borderRadius: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  artist.name,
                  style: AuroraType.displayLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AuroraType.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
