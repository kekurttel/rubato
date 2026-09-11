import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/library/detail_providers.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/library/library_widgets.dart';
import 'package:aurora_mobile/features/search/search_providers.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_mobile/features/ytmusic/ytmusic_import.dart';
import 'package:aurora_mobile/features/ytmusic/ytmusic_providers.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Library tab: Liked / Playlists / Albums / Artists / Downloads /
/// Recently played (spec 13.4).
///
/// The Liked list is the `liked` system playlist; Playlists hosts
/// CRUD (FAB create, rename/delete on user lists) plus the M3U
/// import hook; every track list honors the shared sort order.
class LibraryScreen extends ConsumerStatefulWidget {
  /// Creates the library screen.
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: LibraryTab.values.length, vsync: this);
    _tabs.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) {
      return;
    }
    ref.read(libraryTabProvider.notifier).state =
        LibraryTab.values[_tabs.index];
  }

  Future<void> _createPlaylist() async {
    final service = ref.read(libraryServiceProvider);
    if (service == null) {
      return;
    }
    final title = await showPlaylistTitleDialog(context);
    if (title == null || !mounted) {
      return;
    }
    final playlist = await service.createPlaylist(title);
    if (!mounted) {
      return;
    }
    await context.push('/playlist/${Uri.encodeComponent(playlist.id)}');
  }

  Future<void> _rescan() async {
    final wiring = ref.read(auroraWiringProvider);
    if (wiring == null || _scanning) {
      return;
    }
    setState(() => _scanning = true);
    try {
      final result = await scanDeviceLibrary(wiring);
      if (!mounted) {
        return;
      }
      ref.read(libraryScanStateProvider.notifier).state = result;
      switch (result.status) {
        case DeviceLibraryScanStatus.ok:
          invalidateLibraryAfterScan(ref);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Library: ${result.tracks} tracks, '
                '${result.covers} covers.',
              ),
            ),
          );
        case DeviceLibraryScanStatus.denied:
          // The denied card below appears via libraryScanStateProvider.
          break;
        case DeviceLibraryScanStatus.error:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scan failed — try again.')),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offline = ref.watch(isOfflineProvider);
    final scanState = ref.watch(libraryScanStateProvider);
    return AuroraScaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: _scanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_outlined),
            tooltip: 'Rescan device library',
            onPressed: _scanning ? null : _rescan,
          ),
          const LibrarySortMenu(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        tooltip: 'Create playlist',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (offline)
            const OfflineBanner(
              message: 'You are offline — showing your library.',
            ),
          if (scanState?.status == DeviceLibraryScanStatus.denied)
            const _DeniedPermissionCard(),
          if (scanState != null &&
              scanState.status == DeviceLibraryScanStatus.ok)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Library: ${scanState.tracks} tracks, '
                '${scanState.covers} covers',
                style: AuroraType.labelSmall,
              ),
            ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabs: [
              for (final tab in LibraryTab.values) Tab(text: tab.label),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _LikedTab(),
                _PlaylistsTab(),
                _AlbumsTab(),
                _ArtistsTab(),
                _DownloadsTab(),
                _RecentlyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Liked system playlist rows.
class _LikedTab extends ConsumerWidget {
  /// Creates the tab.
  const _LikedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(likedTracksProvider);
    return liked.when(
      data: (tracks) => ListView(
        children: [SortedTrackList(tracks: tracks)],
      ),
      loading: () => const SkeletonTrackList(count: 6),
      error: (error, _) => ErrorState(
        message: 'Could not load liked tracks.',
        onRetry: () => ref.invalidate(likedTracksProvider),
      ),
    );
  }
}

/// Playlist rows with rename/delete and the M3U import hook.
class _PlaylistsTab extends ConsumerWidget {
  /// Creates the tab.
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(libraryPlaylistsProvider);
    return playlists.when(
      data: (lists) => ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                M3uImportButton(),
                YouTubePlaylistImportButton(),
              ],
            ),
          ),
          const _YtMusicPlaylistsSection(),
          if (lists.isEmpty)
            const EmptyState(
              title: 'No playlists yet',
              message:
                  'Create one with the + button '
                  'or import an M3U file.',
              icon: Icons.queue_music_outlined,
            )
          else
            for (final playlist in lists) _PlaylistRow(playlist: playlist),
        ],
      ),
      loading: () => const SkeletonTrackList(count: 4),
      error: (error, _) => ErrorState(
        message: 'Could not load playlists.',
        onRetry: () => ref.invalidate(libraryPlaylistsProvider),
      ),
    );
  }
}

/// Account YouTube Music playlists (signed-in only).
///
/// Shows the playlists from the connected YouTube account at the top
/// of the Playlists tab; tapping one imports it as a streamable local
/// playlist (private lists resolve through the account session).
/// Hidden while signed out or when the library feed is empty.
class _YtMusicPlaylistsSection extends ConsumerWidget {
  /// Creates the section.
  const _YtMusicPlaylistsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(ytAccountPlaylistsProvider).valueOrNull;
    if (playlists == null || playlists.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'YouTube Music'),
        for (final playlist in playlists)
          ListTile(
            leading: playlist.thumbnailUrl.isEmpty
                ? const Icon(Icons.music_note_outlined)
                : CoverImage(
                    monogram: playlist.title,
                    imageUrl: playlist.thumbnailUrl,
                    size: 48,
                    borderRadius: 8,
                  ),
            title: Text(
              playlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: playlist.subtitle.isEmpty
                ? const Text('YouTube Music playlist')
                : Text(
                    playlist.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            trailing: const Icon(Icons.download_outlined),
            onTap: () =>
                importYtMusicPlaylist(context, ref, playlist),
          ),
      ],
    );
  }
}

/// One playlist row: open on tap, rename/delete on user lists.
class _PlaylistRow extends ConsumerWidget {
  /// Creates the row.
  const _PlaylistRow({required this.playlist});

  /// Playlist to render.
  final Playlist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(libraryServiceProvider);
    return ListTile(
      leading: Icon(
        playlist.isSystem ? Icons.favorite_border : Icons.queue_music_outlined,
      ),
      title: Text(playlist.title),
      onTap: () => context.push(
        '/playlist/${Uri.encodeComponent(playlist.id)}',
      ),
      trailing: playlist.isSystem || service == null
          ? null
          : PopupMenuButton<String>(
              onSelected: (action) async {
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
                }
              },
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
    );
  }
}

/// Album rows (tap opens the album page).
class _AlbumsTab extends ConsumerWidget {
  /// Creates the tab.
  const _AlbumsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(libraryAlbumsProvider);
    return albums.when(
      data: (lists) {
        if (lists.isEmpty) {
          return const EmptyState(
            title: 'No albums yet',
            message: 'Albums group automatically after a scan.',
            icon: Icons.album_outlined,
          );
        }
        return ListView(
          children: [
            for (final album in lists) _AlbumRow(album: album),
          ],
        );
      },
      loading: () => const SkeletonTrackList(count: 4),
      error: (error, _) => ErrorState(
        message: 'Could not load albums.',
        onRetry: () => ref.invalidate(libraryAlbumsProvider),
      ),
    );
  }
}

/// Album row with the scan-cached cover (monogram while none stored).
class _AlbumRow extends ConsumerWidget {
  /// Creates the row.
  const _AlbumRow({required this.album});

  /// Album to render.
  final Album album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final art = ref.watch(localAlbumArtProvider(album.id)).valueOrNull;
    final firstTrack = art == null
        ? ref
            .watch(albumDetailTracksProvider(album.id))
            .valueOrNull
            ?.firstOrNull
        : null;
    final fallbackUrl =
        firstTrack != null ? trackFallbackThumbnailUrl(firstTrack) : null;
    return ListTile(
      leading: CoverImage(
        monogram: album.title,
        localPath: art,
        imageUrl: fallbackUrl,
        size: 48,
        borderRadius: 8,
      ),
      title: Text(album.title),
      subtitle: album.year == null ? null : Text('${album.year}'),
      onTap: () => context.push(
        '/album/${Uri.encodeComponent(album.id)}',
      ),
    );
  }
}

/// Artist rows (tap opens the artist page).
class _ArtistsTab extends ConsumerWidget {
  /// Creates the tab.
  const _ArtistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(libraryArtistsProvider);
    return artists.when(
      data: (lists) {
        if (lists.isEmpty) {
          return const EmptyState(
            title: 'No artists yet',
            message: 'Artists appear after a scan.',
            icon: Icons.person_outline,
          );
        }
        return ListView(
          children: [
            for (final artist in lists)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(artist.name),
                onTap: () => context.push(
                  '/artist/${Uri.encodeComponent(artist.id)}',
                ),
              ),
          ],
        );
      },
      loading: () => const SkeletonTrackList(count: 6),
      error: (error, _) => ErrorState(
        message: 'Could not load artists.',
        onRetry: () => ref.invalidate(libraryArtistsProvider),
      ),
    );
  }
}

/// Verified-download rows: the one obvious "all my downloaded music"
/// place (spec 12). Newest-first in provider order, with the count in
/// the header; a tailored empty state replaces the generic one.
class _DownloadsTab extends ConsumerWidget {
  /// Creates the tab.
  const _DownloadsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(libraryDownloadsProvider);
    return downloads.when(
      data: (tracks) {
        if (tracks.isEmpty) {
          return const EmptyState(
            title: 'No downloads yet',
            message:
                'Music you download for offline listening lives here — '
                'it stays on this device.',
            icon: Icons.download_done_outlined,
          );
        }
        // Provider order is newest-first (jobs by updatedAt desc);
        // preserve it instead of the shared recently-played sort.
        final ordered = [...tracks]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final count = ordered.length;
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '$count downloaded ${count == 1 ? 'track' : 'tracks'}'
                ' · newest first',
                style: AuroraType.labelSmall,
              ),
            ),
            SortedTrackList(tracks: ordered, preserveOrder: true),
          ],
        );
      },
      loading: () => const SkeletonTrackList(count: 6),
      error: (error, _) => ErrorState(
        message: 'Could not load downloads.',
        onRetry: () => ref.invalidate(libraryDownloadsProvider),
      ),
    );
  }
}

/// Recently played rows.
class _RecentlyTab extends ConsumerWidget {
  /// Creates the tab.
  const _RecentlyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(libraryRecentlyProvider);
    return recent.when(
      data: (tracks) => ListView(
        children: [SortedTrackList(tracks: tracks)],
      ),
      loading: () => const SkeletonTrackList(count: 6),
      error: (error, _) => ErrorState(
        message: 'Could not load recent tracks.',
        onRetry: () => ref.invalidate(libraryRecentlyProvider),
      ),
    );
  }
}

/// Permission-denied empty state (spec section 7): rationale copy plus
/// an "Open Settings" button for the permanently-denied path.
class _DeniedPermissionCard extends ConsumerWidget {
  /// Creates the card.
  const _DeniedPermissionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wiring = ref.watch(auroraWiringProvider);
    final rationale =
        wiring?.local.permissions.rationale ??
        'Aurora needs access to your music files to build the library.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: EmptyState(
        title: 'No access to music files',
        message: rationale,
        icon: Icons.folder_off_outlined,
        actionLabel: 'Open Settings',
        onAction: wiring == null
            ? null
            : () => unawaited(wiring.local.permissions.openSettings()),
      ),
    );
  }
}
