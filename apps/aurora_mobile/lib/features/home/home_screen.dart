import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/home/home_providers.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:aurora_mobile/features/home/home_widgets.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Albums shown on the recommended-albums shelf (title-ordered slice).
const int _recommendedAlbumCount = 20;

/// Home tab: YouTube-Music-like shelves from on-device snapshots.
///
/// Vertical `CustomScrollView`: greeting + avatar, mood chips, mood
/// shelf, Continue Listening, Made For You, Daily Mixes,
/// Yeniden dinleyin, recommended albums, Discover, Based On Your
/// Listening. Every section is empty-hidden (no "null" placeholders);
/// pull-to-refresh forces a background recompute with the spinner on
/// the header only.
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    // Library-derived ensure (forced): refresh the healed shelves
    // first so pull-to-refresh also repairs a missing/empty snapshot;
    // fresh engine rows are still never clobbered (see home_service).
    final wiring = ref.read(auroraWiringProvider);
    if (wiring != null) {
      await computeColdStartHome(
        db: wiring.db,
        clock: wiring.clock,
        force: true,
      );
      await enrichHomeWithOnlineRecommendations(wiring, force: true);
      await enrichYtMusicCharts(wiring, force: true);
    }
    await ref.read(homeRecoServiceProvider)?.recompute();
    ref
      ..invalidate(homeEntriesProvider)
      ..invalidate(continueListeningProvider)
      ..invalidate(libraryAlbumsProvider)
      ..invalidate(homeHealthProvider);
    // listenAgainProvider + homeMoodShelfProvider are plain derived
    // providers: invalidating the families above re-seeds them in
    // memory, while homeMoodProvider keeps the selected chip.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = homeGreeting(ref.watch(homeClockProvider));
    final health = ref.watch(homeHealthProvider).valueOrNull;
    final offline = health == null || health == ProviderHealth.offline;
    return AuroraScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          greeting,
                          style: AuroraType.titleLarge,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AuroraColors.bg2,
                        child: Icon(
                          Icons.person_outline,
                          color: AuroraColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (offline)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: OfflineBanner(
                      message:
                          'Library mode — '
                          'recommendations still work.',
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: HomeMoodBar(),
                ),
              ),
              const _MoodShelfSection(),
              const _ContinueSection(),
              const _MadeForYouSection(),
              const _DailyMixSection(),
              const _YtMusicSection(),
              const _ListenAgainSection(),
              const _RecommendedAlbumsSection(),
              const _RailSection(
                surface: HomeSurfaces.discover,
                title: 'Discover',
              ),
              const _RailSection(
                surface: HomeSurfaces.basedOnListening,
                title: 'Based on your listening',
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Continue-listening rail (hidden when nothing is resumable).
class _ContinueSection extends ConsumerWidget {
  /// Creates the section.
  const _ContinueSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(continueListeningProvider).valueOrNull;
    if (items == null || items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: HorizontalCoverRail(
        title: 'Continue listening',
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ContinueCard(
            item: item,
            onTap: () => context.push(
              item.isPlaylist
                  ? '/playlist/${Uri.encodeComponent(item.id)}'
                  : '/album/${Uri.encodeComponent(item.id)}',
            ),
          );
        },
      ),
    );
  }
}

/// Made For You: the first two picks as large featured cards.
class _MadeForYouSection extends ConsumerWidget {
  /// Creates the section.
  const _MadeForYouSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref
        .watch(homeEntriesProvider(HomeSurfaces.madeForYou))
        .valueOrNull;
    if (entries == null || entries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final featured = entries.take(2).toList();
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SectionHeader(title: 'Made for you'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < featured.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: HomeTrackCard(entry: featured[i]),
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

/// Daily-mix rail: one card per mix (hidden until mixes exist).
class _DailyMixSection extends ConsumerWidget {
  /// Creates the section.
  const _DailyMixSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mixes = <({String title, String seed, List<HomeRecoEntry> tracks})>[
      (
        title: 'Daily Mix 1',
        seed: 'Your top artist',
        tracks:
            ref
                .watch(homeEntriesProvider(HomeSurfaces.dailyMix1))
                .valueOrNull ??
            const <HomeRecoEntry>[],
      ),
      (
        title: 'Daily Mix 2',
        seed: 'Your top genre',
        tracks:
            ref
                .watch(homeEntriesProvider(HomeSurfaces.dailyMix2))
                .valueOrNull ??
            const <HomeRecoEntry>[],
      ),
      (
        title: 'Daily Mix 3',
        seed: 'This time of day',
        tracks:
            ref
                .watch(homeEntriesProvider(HomeSurfaces.dailyMix3))
                .valueOrNull ??
            const <HomeRecoEntry>[],
      ),
    ].where((mix) => mix.tracks.isNotEmpty).toList();
    if (mixes.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: HorizontalCoverRail(
        title: 'Daily mix',
        itemCount: mixes.length,
        itemBuilder: (context, index) => HomeMixCard(
          title: mixes[index].title,
          subtitle: mixes[index].seed,
          entries: mixes[index].tracks,
        ),
      ),
    );
  }
}

/// Mood shelf for the selected chip (hidden until a chip is picked
/// and its shelf resolves).
class _MoodShelfSection extends ConsumerWidget {
  /// Creates the section.
  const _MoodShelfSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(homeMoodProvider);
    if (mood == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final entries = ref.watch(homeMoodShelfProvider);
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: HorizontalCoverRail(
        title: mood.label,
        itemCount: entries.length,
        itemBuilder: (context, index) =>
            HomeTrackCard(entry: entries[index], size: 120),
      ),
    );
  }
}

/// "Yeniden dinleyin" rail: recent plays + replay-heavy cards
/// (empty-hidden).
class _ListenAgainSection extends ConsumerWidget {
  /// Creates the section.
  const _ListenAgainSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(listenAgainProvider);
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: HorizontalCoverRail(
        title: 'Yeniden dinleyin',
        itemCount: entries.length,
        itemBuilder: (context, index) =>
            HomeTrackCard(entry: entries[index], size: 120),
      ),
    );
  }
}

/// Recommended-albums rail from library albums (empty-hidden).
///
/// Taps route to the existing album detail page (`/album/:id`).
class _RecommendedAlbumsSection extends ConsumerWidget {
  /// Creates the section.
  const _RecommendedAlbumsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(libraryAlbumsProvider).valueOrNull;
    if (albums == null || albums.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final shelf = albums.take(_recommendedAlbumCount).toList();
    return SliverToBoxAdapter(
      child: HorizontalCoverRail(
        title: 'Sizin için önerilen albümler',
        itemCount: shelf.length,
        itemBuilder: (context, index) {
          final album = shelf[index];
          return HomeAlbumCard(
            album: album,
            onTap: () => context.push(
              '/album/${Uri.encodeComponent(album.id)}',
            ),
          );
        },
      ),
    );
  }
}

/// YouTube Music charts preview (empty-hidden).
///
/// Shows the Top-charts rail inline with a "See all" action pushing the
/// full YouTube Music screen (all three chart rails).
class _YtMusicSection extends ConsumerWidget {
  /// Creates the section.
  const _YtMusicSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries =
        ref.watch(homeEntriesProvider(HomeSurfaces.ytmTop)).valueOrNull;
    if (entries == null || entries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: HorizontalCoverRail(
        title: 'YouTube Music',
        actionLabel: 'See all',
        onAction: () => context.push('/music'),
        itemCount: entries.length,
        itemBuilder: (context, index) =>
            HomeTrackCard(entry: entries[index], size: 120),
      ),
    );
  }
}

/// Horizontal card rail for one surface (empty-hidden).
class _RailSection extends ConsumerWidget {
  /// Creates the section.
  const _RailSection({required this.surface, required this.title});

  /// Snapshot surface id.
  final String surface;

  /// Section header title.
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(homeEntriesProvider(surface)).valueOrNull;
    if (entries == null || entries.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: HorizontalCoverRail(
        title: title,
        itemCount: entries.length,
        itemBuilder: (context, index) =>
            HomeTrackCard(entry: entries[index], size: 120),
      ),
    );
  }
}
