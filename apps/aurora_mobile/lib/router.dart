import 'package:aurora_mobile/features/album/album_detail_screen.dart';
import 'package:aurora_mobile/features/artist/artist_detail_screen.dart';
import 'package:aurora_mobile/features/downloads/downloads_screen.dart';
import 'package:aurora_mobile/features/home/home_screen.dart';
import 'package:aurora_mobile/features/library/library_screen.dart';
import 'package:aurora_mobile/features/now_playing/desktop_player_bar.dart';
import 'package:aurora_mobile/features/now_playing/mini_player_view.dart';
import 'package:aurora_mobile/features/now_playing/now_playing_screen.dart';
import 'package:aurora_mobile/features/playlist/playlist_detail_screen.dart';
import 'package:aurora_mobile/features/search/search_screen.dart';
import 'package:aurora_mobile/features/you/you_screen.dart';
import 'package:aurora_mobile/features/you/yt_login_screen.dart';
import 'package:aurora_mobile/features/ytmusic/ytmusic_screen.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Root navigator (dialogs, Now Playing, detail pages).
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Application router (spec sections 3 + 13).
///
/// Tabs: Home | Search | Library | Downloads | You | Music. Now Playing
/// opens as a fullscreen dialog; artist / album / playlist detail pages
/// plus the privacy, onboarding, and login flows push on the root
/// navigator.
/// Feature screens are wired to the integration services in
/// `wiring.dart` (overridden in `main.dart`); the privacy and
/// onboarding flows are still phase stubs.
final GoRouter auroraRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _AuroraShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/downloads',
              builder: (context, state) => const DownloadsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/you',
              builder: (context, state) => const YouScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/music',
              builder: (context, state) => const YtMusicScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/now-playing',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: NowPlayingScreen(),
      ),
    ),
    GoRoute(
      path: '/artist/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ArtistDetailScreen(
        artistId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/album/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => AlbumDetailScreen(
        albumId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/playlist/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaylistDetailScreen(
        playlistId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/yt-login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const YtLoginScreen(),
    ),
    GoRoute(
      path: '/privacy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const _StubBody(
        title: 'Your data',
        message: 'Export / reset / wipe controls land in Phase 5.',
        icon: Icons.privacy_tip_outlined,
      ),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const _StubBody(
        title: 'Welcome',
        message:
            'Permission + seed picks + privacy recap land '
            'in Phase 5.',
        icon: Icons.waving_hand_outlined,
      ),
    ),
  ],
);

/// Shell: tab content + player surface.
///
/// Narrow screens (< 900 px) keep the mobile layout: tab content with
/// the wired mini-player above the bottom [NavigationBar]. Wide
/// screens (desktop/tablet) render a sidebar + the Spotify-style
/// [DesktopPlayerBar] instead, with content constrained to a readable
/// max width.
class _AuroraShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  const _AuroraShell({required this.navigationShell});

  /// Active tab stack.
  final StatefulNavigationShell navigationShell;

  /// Width at/above which the desktop sidebar layout kicks in.
  static const double desktopBreakpoint = 900;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= desktopBreakpoint;
    if (!wide) {
      return AuroraScaffold(
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WiredMiniPlayer(),
            NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.download_outlined),
                  selectedIcon: Icon(Icons.download),
                  label: 'Downloads',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'You',
                ),
                NavigationDestination(
                  icon: Icon(Icons.music_note_outlined),
                  selectedIcon: Icon(Icons.music_note),
                  label: 'Music',
                ),
              ],
            ),
          ],
        ),
      );
    }
    return AuroraScaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DesktopSidebar(
              currentIndex: navigationShell.currentIndex,
              onSelect: _goBranch,
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: navigationShell,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DesktopPlayerBar(),
    );
  }
}

/// Desktop sidebar: brand header, the six tab destinations, and a
/// version footer.
class _DesktopSidebar extends StatelessWidget {
  /// Creates the sidebar.
  const _DesktopSidebar({
    required this.currentIndex,
    required this.onSelect,
  });

  /// Currently selected tab branch.
  final int currentIndex;

  /// Tab selection callback.
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const items = <({IconData icon, IconData activeIcon, String label})>[
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      (
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: 'Search'
      ),
      (
        icon: Icons.library_music_outlined,
        activeIcon: Icons.library_music,
        label: 'Library'
      ),
      (
        icon: Icons.download_outlined,
        activeIcon: Icons.download,
        label: 'Downloads'
      ),
      (icon: Icons.person_outline, activeIcon: Icons.person, label: 'You'),
      (
        icon: Icons.music_note_outlined,
        activeIcon: Icons.music_note,
        label: 'Music'
      ),
    ];
    return Container(
      width: 248,
      color: AuroraColors.bg1,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Rubato', style: AuroraType.titleLarge),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('MUSIC', style: AuroraType.labelSmall),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < items.length; i++)
            _SidebarTile(
              icon: items[i].icon,
              activeIcon: items[i].activeIcon,
              label: items[i].label,
              selected: currentIndex == i,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Rubato · on-device reco',
              style: AuroraType.bodySmall.copyWith(
                color: AuroraColors.textLow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One sidebar destination row.
class _SidebarTile extends StatelessWidget {
  /// Creates the tile.
  const _SidebarTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  /// Idle icon.
  final IconData icon;

  /// Selected icon.
  final IconData activeIcon;

  /// Destination label.
  final String label;

  /// Whether this destination is active.
  final bool selected;

  /// Tap callback.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: selected ? accent : AuroraColors.textMid,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AuroraType.titleSmall.copyWith(
                    color: selected ? accent : AuroraColors.textMid,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Phase placeholder body rendered inside the shell.
class _StubBody extends StatelessWidget {
  /// Creates a placeholder body.
  const _StubBody({
    required this.title,
    required this.message,
    required this.icon,
  });

  /// Headline.
  final String title;

  /// Which phase delivers the real screen.
  final String message;

  /// Illustration.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: EmptyState(title: title, message: message),
    );
  }
}
