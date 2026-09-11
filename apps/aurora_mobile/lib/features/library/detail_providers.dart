import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_database/aurora_database.dart';
import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many tracks the artist "Popular" section keeps.
const int artistPopularTrackCount = 10;

/// Tracks of one playlist in position order.
///
/// Watches the playlist stream so every playlist mutation (add, remove,
/// reorder, rename, delete — the wired service re-emits all playlist
/// streams after each one) refreshes the ids, then resolves them through
/// the wiring. Missing rows are skipped and duplicates collapse (row
/// keys must stay unique for the reorderable list). Empty when unwired.
final FutureProviderFamily<List<Track>, String> playlistDetailTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, playlistId) async {
      ref.watch(libraryPlaylistsProvider);
      final service = ref.watch(libraryServiceProvider);
      final wiring = ref.watch(auroraWiringProvider);
      if (service == null || wiring == null) {
        return const <Track>[];
      }
      final ids = await service.playlistTrackIds(playlistId);
      final seen = <String>{};
      final tracks = <Track>[];
      for (final id in ids) {
        if (!seen.add(id)) {
          continue;
        }
        final track = await wiring.resolveTrack(id);
        if (track != null) {
          tracks.add(track);
        }
      }
      return tracks;
    });

/// Tracks of one album in title order (the DAO's order).
///
/// The library service exposes no album-track listing, so this reads
/// the thin track DAO through the wiring and maps rows with
/// [DbMappers] — the same barrel the app lane already uses. Empty when
/// unwired or when the album id is unknown.
final FutureProviderFamily<List<Track>, String> albumDetailTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, albumId) async {
      ref.watch(libraryAlbumsProvider);
      final wiring = ref.watch(auroraWiringProvider);
      if (wiring == null) {
        return const <Track>[];
      }
      final rows = await wiring.db.tracksDao.listByAlbum(albumId);
      final tracks = <Track>[];
      for (final row in rows) {
        tracks.add(
          DbMappers.toTrack(
            row,
            artistIds: await wiring.db.tracksDao.artistIdsFor(row.id),
            genreIds: await wiring.db.tracksDao.genreIdsFor(row.id),
          ),
        );
      }
      return tracks;
    });

/// Every track credited to one artist, title order.
///
/// There is no artist-track DAO, so this reads the `track_artists`
/// join through a read-only select (the id is quote-escaped; ids are
/// system-generated composite keys) and resolves each hit through the
/// wiring. Missing rows are skipped. Empty when unwired.
final FutureProviderFamily<List<Track>, String> artistDetailTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, artistId) async {
      ref
        ..watch(libraryArtistsProvider)
        ..watch(libraryAlbumsProvider);
      final wiring = ref.watch(auroraWiringProvider);
      if (wiring == null) {
        return const <Track>[];
      }
      final ids = await _artistTrackIds(wiring, artistId);
      final tracks = <Track>[];
      for (final id in ids) {
        final track = await wiring.resolveTrack(id);
        if (track != null) {
          tracks.add(track);
        }
      }
      tracks.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      return tracks;
    });

/// Popular tracks for one artist: the artist's tracks ordered by the
/// existing decayed-score stats (the same store the Home replay mix
/// falls back to), title order breaking ties, capped at
/// [artistPopularTrackCount]. Tracks without stats sink but still show,
/// so unplayed artists list their catalog instead of an empty shelf.
final FutureProviderFamily<List<Track>, String> artistPopularTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, artistId) async {
      final tracks = await ref.watch(
        artistDetailTracksProvider(artistId).future,
      );
      if (tracks.isEmpty) {
        return const <Track>[];
      }
      final wiring = ref.watch(auroraWiringProvider);
      if (wiring == null) {
        return tracks.take(artistPopularTrackCount).toList();
      }
      final stats = await wiring.db.statsDao.topByDecayedScore();
      final rank = <String, int>{
        for (var i = 0; i < stats.length; i++) stats[i].trackId: i,
      };
      final ordered = [...tracks]
        ..sort((a, b) {
          final order = (rank[a.id] ?? 1 << 30).compareTo(
            rank[b.id] ?? 1 << 30,
          );
          if (order != 0) {
            return order;
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
      return ordered.take(artistPopularTrackCount).toList();
    });

/// Track ids credited to [artistId] (read-only join lookup).
Future<List<String>> _artistTrackIds(
  AuroraWiring wiring,
  String artistId,
) async {
  final safe = artistId.replaceAll("'", "''");
  final rows = await wiring.db
      .customSelect(
        'SELECT track_id AS track_id FROM track_artists '
        "WHERE artist_id = '$safe'",
      )
      .get();
  return <String>[for (final row in rows) row.read<String>('track_id')];
}
