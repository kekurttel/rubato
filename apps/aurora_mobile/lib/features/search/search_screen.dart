import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/downloads/download_providers.dart';
import 'package:aurora_mobile/features/library/library_widgets.dart';
import 'package:aurora_mobile/features/search/search_providers.dart';
import 'package:aurora_mobile/features/search/search_service.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Search tab: debounced field, 4 tabs, local + online results.
///
/// - Field debounces 220 ms and needs min 2 chars (spec section 11).
/// - Local FTS stays pinned on top; online rows carry the `[Online]`
///   badge with per-row Stream play + Download buttons.
/// - Airplane mode shows the offline badge + banner; local results and
///   downloads keep working.
class SearchScreen extends ConsumerStatefulWidget {
  /// Creates the search screen.
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final TabController _tabs;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _tabs = TabController(length: SearchTab.values.length, vsync: this);
    _tabs.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) {
      return;
    }
    ref.read(searchTabProvider.notifier).state = SearchTab.values[_tabs.index];
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      ref.read(searchTextProvider.notifier).state = value;
    });
  }

  void _onClear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(searchTextProvider.notifier).state = '';
  }

  void _setQuery(String query) {
    _debounce?.cancel();
    _controller.text = query;
    ref.read(searchTextProvider.notifier).state = query;
  }

  Future<void> _play(Track track) async {
    final error = await ref.read(searchActionsProvider)?.playStream(track);
    if (error != null && error.isNotEmpty && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _download(Track track) async {
    final actions = ref.read(searchActionsProvider);
    if (actions == null) {
      return;
    }
    if (actions.downloadStateFor(track.id) != null) {
      return;
    }
    if (!mounted) {
      return;
    }
    final quality = await QualityPickerSheet.show(
      context,
      initial: ref.read(downloadQualityProvider),
    );
    if (quality == null || !mounted) {
      return;
    }
    final error = await actions.enqueueDownload(track, quality);
    if (error != null && error.isNotEmpty && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offline = ref.watch(isOfflineProvider);
    return AuroraScaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [OfflineBadge(offline: offline)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => TextField(
                controller: _controller,
                onChanged: _onTextChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Songs, artists, albums…',
                  prefixIcon: const Icon(Icons.search_outlined),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _onClear,
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear search',
                        ),
                ),
              ),
            ),
          ),
          if (offline) const OfflineBanner(),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final chip in _suggestionChips)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(chip.label),
                      avatar: Icon(chip.icon, size: 16),
                      onPressed: () => _setQuery(chip.query),
                    ),
                  ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            tabs: [
              for (final tab in SearchTab.values) Tab(text: tab.label),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _SongsTab(onPlay: _play, onDownload: _download),
                const _ArtistsTab(),
                const _AlbumsTab(),
                const _PlaylistsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Curated one-tap searches (YouTube Music charts + moods).
const List<({String label, IconData icon, String query})>
_suggestionChips = [
  (
    label: 'YouTube Music',
    icon: Icons.music_note_outlined,
    query: 'Top Hits',
  ),
  (
    label: 'Top 100',
    icon: Icons.emoji_events_outlined,
    query: 'Top 100 global songs',
  ),
  (
    label: 'Trending',
    icon: Icons.trending_up_outlined,
    query: 'Trending music hits',
  ),
  (
    label: 'New releases',
    icon: Icons.new_releases_outlined,
    query: 'New music releases',
  ),
];

/// Songs tab: pinned local section + online section with row actions.
class _SongsTab extends ConsumerWidget {
  /// Creates the songs tab.
  const _SongsTab({required this.onPlay, required this.onDownload});

  /// Stream-play handler.
  final Future<void> Function(Track track) onPlay;

  /// Download (quality picker) handler.
  final Future<void> Function(Track track) onDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchTextProvider);
    if (!isRunnableQuery(query)) {
      return const EmptyState(
        title: 'Search your music',
        message: 'Type at least 2 characters to search.',
        icon: Icons.search_outlined,
      );
    }
    final local = ref.watch(localResultsProvider);
    final online = ref.watch(onlineResultsProvider);
    final offline = ref.watch(isOfflineProvider);
    return ListView(
      children: [
        local.when(
          data: (page) => _LocalSongs(
            page: page,
            onPlay: onPlay,
          ),
          loading: () => const SkeletonTrackList(count: 3),
          error: (error, _) => EmptyState(
            title: 'Local search failed',
            message: '$error',
            icon: Icons.error_outline,
          ),
        ),
        if (offline)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Online results are unavailable while offline.',
              style: AuroraType.bodySmall,
            ),
          )
        else
          online.when(
            data: (page) => _OnlineSongs(
              page: page,
              onPlay: onPlay,
              onDownload: onDownload,
            ),
            loading: () => const SkeletonTrackList(count: 3),
            error: (error, _) => EmptyState(
              title: 'Online search failed',
              message: friendlyOnlineSearchError(error),
              icon: Icons.cloud_off_outlined,
            ),
          ),
      ],
    );
  }
}

/// Pinned local FTS track section.
class _LocalSongs extends ConsumerWidget {
  /// Creates the local section.
  const _LocalSongs({required this.page, required this.onPlay});

  /// Local results page (null while the service is unwired).
  final SearchPage? page;

  /// Stream-play handler.
  final Future<void> Function(Track track) onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = page?.tracks ?? const <Track>[];
    if (page == null) {
      return const SizedBox.shrink();
    }
    if (tracks.isEmpty) {
      return const SizedBox.shrink();
    }
    final actions = ref.watch(searchActionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(title: 'On this device'),
        for (final track in tracks)
          LocalTrackTile(
            track: track,
            artistLine: actions?.artistLine(track) ?? 'Unknown artist',
            onTap: () => onPlay(track),
          ),
      ],
    );
  }
}

/// Online track section with per-row stream + download buttons.
class _OnlineSongs extends ConsumerWidget {
  /// Creates the online section.
  const _OnlineSongs({
    required this.page,
    required this.onPlay,
    required this.onDownload,
  });

  /// Online results page (null while the service is unwired).
  final SearchPage? page;

  /// Stream-play handler.
  final Future<void> Function(Track track) onPlay;

  /// Download (quality picker) handler.
  final Future<void> Function(Track track) onDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = page?.tracks ?? const <Track>[];
    if (page == null || tracks.isEmpty) {
      return const SizedBox.shrink();
    }
    final actions = ref.watch(searchActionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const OnlineSectionHeader(),
        for (final track in tracks)
          OnlineTrackRow(
            track: track,
            artistLine: actions?.artistLine(track) ?? 'Unknown artist',
            imageUrl: actions?.artworkUrlFor(track),
            downloadState: actions?.downloadStateFor(track.id),
            downloadProgress: actions?.downloadProgressFor(track.id) ?? 0,
            onStreamTap: () => onPlay(track),
            onDownloadTap: () => onDownload(track),
          ),
      ],
    );
  }
}

/// Artists tab: local names first, online uploaders with a badge.
class _ArtistsTab extends ConsumerWidget {
  /// Creates the artists tab.
  const _ArtistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchTextProvider);
    if (!isRunnableQuery(query)) {
      return const EmptyState(
        title: 'Search your music',
        message: 'Type at least 2 characters to search.',
        icon: Icons.search_outlined,
      );
    }
    final local = ref.watch(localResultsProvider).valueOrNull;
    final online = ref.watch(onlineResultsProvider).valueOrNull;
    final localArtists = local?.artists ?? const <Artist>[];
    final onlineArtists = online?.artists ?? const <Artist>[];
    if (localArtists.isEmpty && onlineArtists.isEmpty) {
      return const EmptyState(
        title: 'No artists found',
        message: 'Try a different spelling.',
      );
    }
    return ListView(
      children: [
        for (final artist in localArtists)
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(artist.name),
            onTap: () => context.push(
              '/artist/${Uri.encodeComponent(artist.id)}',
            ),
          ),
        for (final artist in onlineArtists)
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(artist.name),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AuroraColors.accentWash,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Online',
                style: TextStyle(
                  color: AuroraColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () => context.push(
              '/artist/${Uri.encodeComponent(artist.id)}',
            ),
          ),
      ],
    );
  }
}

/// Albums tab: local albums first, then online placeholders.
class _AlbumsTab extends ConsumerWidget {
  /// Creates the albums tab.
  const _AlbumsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchTextProvider);
    if (!isRunnableQuery(query)) {
      return const EmptyState(
        title: 'Search your music',
        message: 'Type at least 2 characters to search.',
        icon: Icons.search_outlined,
      );
    }
    final local = ref.watch(localResultsProvider).valueOrNull;
    final albums = local?.albums ?? const <Album>[];
    if (albums.isEmpty) {
      return const EmptyState(
        title: 'No albums found',
        message:
            'Album grouping is local-only in v1 — '
            'online search returns songs and artists.',
      );
    }
    return ListView(
      children: [
        for (final album in albums)
          ListTile(
            leading: const Icon(Icons.album_outlined),
            title: Text(album.title),
            onTap: () =>
                context.push('/album/${Uri.encodeComponent(album.id)}'),
          ),
      ],
    );
  }
}

/// Playlists tab: local-only in v1.
class _PlaylistsTab extends StatelessWidget {
  /// Creates the playlists tab.
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'Playlists are local-only in v1',
      message: 'Create and search playlists from your library.',
      icon: Icons.queue_music_outlined,
    );
  }
}
