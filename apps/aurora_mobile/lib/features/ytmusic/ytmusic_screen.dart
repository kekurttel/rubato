import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/home/home_providers.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:aurora_mobile/features/home/home_widgets.dart';
import 'package:aurora_mobile/features/you/youtube_account.dart';
import 'package:aurora_mobile/features/ytmusic/ytmusic_import.dart';
import 'package:aurora_mobile/features/ytmusic/ytmusic_providers.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// YouTube Music charts screen: Top charts, Trending now, New releases.
///
/// Rails stream the YouTube catalog through the existing online engine
/// (same backend as search), so every card plays instantly without a
/// download. Sections hide while their snapshot is empty; pull to
/// refresh forces a fresh chart fetch.
class YtMusicScreen extends ConsumerWidget {
  /// Creates the YouTube Music screen.
  const YtMusicScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    final wiring = ref.read(auroraWiringProvider);
    if (wiring != null) {
      await enrichYtMusicCharts(wiring, force: true);
    }
    ref
      ..invalidate(homeEntriesProvider)
      ..invalidate(ytAccountShelvesProvider)
      ..invalidate(ytAccountPlaylistsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuroraScaffold(
      appBar: AppBar(title: const Text('YouTube Music')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            children: const [
              _YtSignInGate(),
              _YtLibrarySection(),
              _YtForYouSection(),
              _YtRail(
                surface: HomeSurfaces.ytmTop,
                title: 'Top charts',
              ),
              _YtRail(
                surface: HomeSurfaces.ytmTrending,
                title: 'Trending now',
              ),
              _YtRail(
                surface: HomeSurfaces.ytmNew,
                title: 'New releases',
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sign-in gate: asks for the YouTube account while signed out.
///
/// Tapping the button opens the login flow; the account sections
/// below stay hidden until the session lands.
class _YtSignInGate extends ConsumerWidget {
  /// Creates the gate.
  const _YtSignInGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(ytAccountStatusProvider).valueOrNull;
    if (signedIn == null || signedIn) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Connect your YouTube account',
                style: AuroraType.titleSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to see your playlists, liked videos, and '
                'recommendations from your own listening. The session '
                'stays on this device.',
                style: AuroraType.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.push('/yt-login'),
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text('Sign in with YouTube'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The signed-in account's own playlists (hidden while signed out).
///
/// Tapping a playlist imports it as a streamable local playlist
/// (private lists resolve through the account session).
class _YtLibrarySection extends ConsumerWidget {
  /// Creates the section.
  const _YtLibrarySection();

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
        const SectionHeader(title: 'Your library'),
        for (final playlist in playlists)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => importYtMusicPlaylist(context, ref, playlist),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CoverImage(
                        monogram: playlist.title,
                        imageUrl: playlist.thumbnailUrl.isEmpty
                            ? null
                            : playlist.thumbnailUrl,
                        size: 72,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              playlist.title,
                              style: AuroraType.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              playlist.subtitle.isEmpty
                                  ? 'YouTube Music playlist'
                                  : playlist.subtitle,
                              style: AuroraType.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Personalized shelves from the account's home feed (hidden while
/// signed out or when the feed is empty).
class _YtForYouSection extends ConsumerWidget {
  /// Creates the section.
  const _YtForYouSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelves = ref.watch(ytAccountShelvesProvider).valueOrNull;
    if (shelves == null || shelves.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final shelf in shelves.take(4))
          HorizontalCoverRail(
            title: shelf.title,
            itemCount: shelf.tracks.length,
            itemBuilder: (context, index) {
              final item = shelf.tracks[index];
              return _YtShelfCard(item: item);
            },
          ),
      ],
    );
  }
}

/// One account-feed card: plays the track as a stream on tap.
class _YtShelfCard extends ConsumerWidget {
  /// Creates the card.
  const _YtShelfCard({required this.item});

  /// Feed item to render.
  final YtMusicTrack item;

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    final wiring = ref.read(auroraWiringProvider);
    final actions = ref.read(homeActionsProvider);
    if (wiring == null || actions == null) {
      return;
    }
    final now = DateTime.now().toUtc();
    final uploader = item.artist.trim();
    final slug = uploader
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-');
    final artistId = uploader.isEmpty
        ? null
        : AuroraIds.trackId('ytdlp', 'channel-$slug');
    if (artistId != null) {
      wiring.artistNames[artistId] = uploader;
    }
    final track = Track(
      id: AuroraIds.trackId('ytdlp', item.videoId),
      providerId: 'ytdlp',
      sourceTrackId: item.videoId,
      title: item.title.trim().isEmpty ? 'Untitled' : item.title.trim(),
      createdAt: now,
      updatedAt: now,
      artistIds: artistId != null ? <String>[artistId] : const <String>[],
    );
    await wiring.ensureTrackStored(track);
    await actions.playTracks([track]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _play(context, ref),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverImage(
              monogram: item.title,
              imageUrl: item.thumbnailUrl.isEmpty
                  ? 'https://i.ytimg.com/vi/${item.videoId}/hqdefault.jpg'
                  : item.thumbnailUrl,
              size: 140,
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: AuroraType.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.artist.isEmpty ? 'YouTube Music' : item.artist,
              style: AuroraType.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// One chart rail (empty-hidden).
class _YtRail extends ConsumerWidget {
  /// Creates the rail for [surface] with [title].
  const _YtRail({required this.surface, required this.title});

  /// Snapshot surface id.
  final String surface;

  /// Section header title.
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(homeEntriesProvider(surface)).valueOrNull;
    if (entries == null || entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return HorizontalCoverRail(
      title: title,
      itemCount: entries.length,
      itemBuilder: (context, index) =>
          HomeTrackCard(entry: entries[index], size: 140),
    );
  }
}
