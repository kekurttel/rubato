import 'package:aurora_core/aurora_core.dart';

/// Library sort orders (spec 13.4).
enum LibrarySort {
  /// Most recently played / added first.
  recent,

  /// Alphabetical by title.
  title,

  /// Alphabetical by artist line, then title.
  artist,
}

/// Display label for a [LibrarySort].
String librarySortLabel(LibrarySort sort) => switch (sort) {
  LibrarySort.recent => 'Recent',
  LibrarySort.title => 'Title',
  LibrarySort.artist => 'Artist',
};

/// Sorts [tracks] without mutating the input list.
///
/// `recent` orders by [recentIds] position (unknown ids sink);
/// `artist` uses [artistLine] to resolve names.
List<Track> sortLibraryTracks(
  List<Track> tracks,
  LibrarySort sort, {
  List<String> recentIds = const <String>[],
  String Function(Track track)? artistLine,
}) {
  final sorted = [...tracks];
  switch (sort) {
    case LibrarySort.recent:
      final rank = <String, int>{
        for (var i = 0; i < recentIds.length; i++) recentIds[i]: i,
      };
      sorted.sort(
        (a, b) => (rank[a.id] ?? 1 << 30).compareTo(rank[b.id] ?? 1 << 30),
      );
    case LibrarySort.title:
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    case LibrarySort.artist:
      final line = artistLine ?? (_) => '';
      sorted.sort((a, b) {
        final order = line(a).toLowerCase().compareTo(line(b).toLowerCase());
        if (order != 0) {
          return order;
        }
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
  }
  return sorted;
}

/// Result of the M3U import hook (spec: tolerate empty/missing
/// entries, never crash; empty m3u = empty playlist, not error).
final class M3uImportResult {
  /// Creates an import result.
  const M3uImportResult({
    required this.playlistId,
    required this.imported,
    required this.missing,
  });

  /// Created playlist id.
  final String playlistId;

  /// Tracks that resolved to library entries.
  final int imported;

  /// Lines that matched nothing (skipped, never fatal).
  final int missing;
}

/// Library boundary behind the Library tab (spec 13.4).
///
/// The app lane implements this over `PlaylistsDao`, `TracksDao`,
/// `ArtistsDao`, `AlbumsDao`, and the download + stats rows. Widgets
/// only see freezed models and never Drift tables.
abstract class LibraryService {
  /// Liked system playlist, most-recent first.
  Stream<List<Track>> watchLiked();

  /// User + system playlists ordered by title.
  Stream<List<Playlist>> watchPlaylists();

  /// Albums ordered by title.
  Stream<List<Album>> watchAlbums();

  /// Artists ordered by name.
  Stream<List<Artist>> watchArtists();

  /// Verified downloads, newest-first.
  Stream<List<Track>> watchDownloads();

  /// Recently played tracks, newest-first.
  Stream<List<Track>> watchRecentlyPlayed();

  /// Track ids of one playlist in position order.
  Future<List<String>> playlistTrackIds(String playlistId);

  /// Creates a playlist (FAB) and returns it.
  Future<Playlist> createPlaylist(String title);

  /// Renames a user playlist (system lists reject).
  Future<void> renamePlaylist(String playlistId, String title);

  /// Deletes a playlist and its memberships.
  Future<void> deletePlaylist(String playlistId);

  /// Adds a track (insert-or-ignore on the pair key).
  Future<void> addToPlaylist(String playlistId, String trackId);

  /// Removes one membership.
  Future<void> removeFromPlaylist(String playlistId, String trackId);

  /// Moves an entry (long-press reorder in the detail sheet).
  Future<void> reorderEntry(String playlistId, int from, int to);

  /// M3U import hook: the app lane picks the file, parses
  /// tolerantly, and creates the playlist (spec 13.4 + MYT compat).
  Future<M3uImportResult> importM3u();

  /// Imports a YouTube playlist from a link or ID.
  ///
  /// Returns the created [Playlist], or null on failure.
  Future<Playlist?> importYouTubePlaylist(String urlOrId);

  /// Display artist line for [track] (ids resolved to names).
  String artistLine(Track track);

  /// Plays [tracks] from [startIndex].
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0});

  /// Current like state (-1/0/1) for [trackId].
  int likeStateFor(String trackId);

  /// Writes the like state for [trackId].
  Future<void> setLike(String trackId, int likeState);
}
