import 'package:aurora_core/aurora_core.dart';
import 'package:meta/meta.dart';

/// Detailed artist view returned by a provider `getArtist` call.
///
/// Keeps the provider interface stable while letting each provider
/// attach its top tracks and albums without extra round-trips.
@immutable
final class ArtistDetails {
  /// Creates artist details.
  const ArtistDetails({
    required this.artist,
    this.albums = const <Album>[],
    this.topTracks = const <Track>[],
  });

  /// The requested artist.
  final Artist artist;

  /// Known albums (may be empty when the provider has none cached).
  final List<Album> albums;

  /// Popular tracks (local stats or cached provider popularity).
  final List<Track> topTracks;
}

/// Detailed album view returned by a provider `getAlbum` call.
@immutable
final class AlbumDetails {
  /// Creates album details.
  const AlbumDetails({
    required this.album,
    this.tracks = const <Track>[],
    this.artists = const <Artist>[],
  });

  /// The requested album.
  final Album album;

  /// Album tracks in disc order (may be empty when unknown).
  final List<Track> tracks;

  /// Credited artists.
  final List<Artist> artists;
}
