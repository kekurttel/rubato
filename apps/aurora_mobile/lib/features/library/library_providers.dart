import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/library/library_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Library subtabs (spec 13.4).
enum LibraryTab {
  /// Liked system playlist.
  liked,

  /// User + system playlists.
  playlists,

  /// Albums.
  albums,

  /// Artists.
  artists,

  /// Verified downloads.
  downloads,

  /// Recently played.
  recently,
}

/// Display label for a [LibraryTab].
extension LibraryTabLabel on LibraryTab {
  /// Tab label shown in the tab bar.
  String get label => switch (this) {
    LibraryTab.liked => 'Liked',
    LibraryTab.playlists => 'Playlists',
    LibraryTab.albums => 'Albums',
    LibraryTab.artists => 'Artists',
    LibraryTab.downloads => 'Downloads',
    LibraryTab.recently => 'Recently',
  };
}

/// Library boundary (null until the app lane injects repositories).
final Provider<LibraryService?> libraryServiceProvider =
    Provider<LibraryService?>((ref) => null);

/// Active library subtab.
final StateProvider<LibraryTab> libraryTabProvider = StateProvider<LibraryTab>(
  (ref) => LibraryTab.playlists,
);

/// Track sort order (recent / title / artist).
final StateProvider<LibrarySort> librarySortProvider =
    StateProvider<LibrarySort>((ref) => LibrarySort.recent);

/// Liked tracks (empty until the service is wired).
final StreamProvider<List<Track>> likedTracksProvider =
    StreamProvider<List<Track>>((ref) {
      final service = ref.watch(libraryServiceProvider);
      if (service == null) {
        return Stream<List<Track>>.value(const <Track>[]);
      }
      return service.watchLiked();
    });

/// Playlists (empty until wired).
final StreamProvider<List<Playlist>> libraryPlaylistsProvider =
    StreamProvider<List<Playlist>>((ref) {
      final service = ref.watch(libraryServiceProvider);
      if (service == null) {
        return Stream<List<Playlist>>.value(const <Playlist>[]);
      }
      return service.watchPlaylists();
    });

/// Albums (empty until wired).
final StreamProvider<List<Album>> libraryAlbumsProvider =
    StreamProvider<List<Album>>((ref) {
      final service = ref.watch(libraryServiceProvider);
      if (service == null) {
        return Stream<List<Album>>.value(const <Album>[]);
      }
      return service.watchAlbums();
    });

/// Artists (empty until wired).
final StreamProvider<List<Artist>> libraryArtistsProvider =
    StreamProvider<List<Artist>>((ref) {
      final service = ref.watch(libraryServiceProvider);
      if (service == null) {
        return Stream<List<Artist>>.value(const <Artist>[]);
      }
      return service.watchArtists();
    });

/// Downloaded tracks (empty until wired).
final StreamProvider<List<Track>> libraryDownloadsProvider =
    StreamProvider<List<Track>>((ref) {
      final service = ref.watch(libraryServiceProvider);
      if (service == null) {
        return Stream<List<Track>>.value(const <Track>[]);
      }
      return service.watchDownloads();
    });

/// Recently played tracks (empty until wired).
final StreamProvider<List<Track>> libraryRecentlyProvider =
    StreamProvider<List<Track>>((ref) {
      final service = ref.watch(libraryServiceProvider);
      if (service == null) {
        return Stream<List<Track>>.value(const <Track>[]);
      }
      return service.watchRecentlyPlayed();
    });
