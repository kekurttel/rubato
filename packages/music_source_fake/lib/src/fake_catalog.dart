import 'package:aurora_core/aurora_core.dart';
import 'package:meta/meta.dart';

/// Deterministic in-memory catalog: 200 tracks, 12 artists, 8 genres.
///
/// Everything derives from index arithmetic over fixed name lists — no
/// `Random`, so two builds on any platform produce identical catalogs.
/// Ids follow the composite convention (`fake:track-042`, ...).
@immutable
final class FakeCatalog {
  /// Creates the catalog (all lists are precomputed once).
  FakeCatalog()
    : artists = _buildArtists(),
      albums = _buildAlbums(),
      tracks = _buildTracks() {
    _tracksByArtist = <String, List<Track>>{};
    for (final track in tracks) {
      for (final artistId in track.artistIds) {
        (_tracksByArtist[artistId] ??= <Track>[]).add(track);
      }
    }
  }

  /// The 8 catalog genres (spec section 7).
  static const List<String> genreNames = <String>[
    'metal',
    'ambient',
    'electronic',
    'jazz',
    'hiphop',
    'folk',
    'indie',
    'classical',
  ];

  /// Genre row ids (`fake:genre-<name>`).
  static List<String> get genreIds => <String>[
    for (final name in genreNames) 'fake:genre-$name',
  ];

  /// All 12 artists.
  final List<Artist> artists;

  /// Two albums per artist (24 total).
  final List<Album> albums;

  /// All 200 tracks.
  final List<Track> tracks;

  late final Map<String, List<Track>> _tracksByArtist;

  /// Tracks credited to [artistId] (empty when unknown).
  List<Track> tracksForArtist(String artistId) =>
      List<Track>.unmodifiable(_tracksByArtist[artistId] ?? const <Track>[]);

  /// Total track count (always 200).
  int get trackCount => tracks.length;

  static List<Artist> _buildArtists() {
    const names = <String>[
      'Iron Aurora',
      'Silent Fjord',
      'Neon Caravan',
      'Blue Meridian',
      'Copper Verse',
      'Hollow Timber',
      'Velvet Circuit',
      'Stone Choir',
      'Paper Comet',
      'Golden Static',
      'Midnight Orchard',
      'Glass Harbor',
    ];
    return <Artist>[
      for (var i = 0; i < names.length; i++)
        Artist(
          id: 'fake:artist-$i',
          name: names[i],
          sourceId: 'artist-$i',
          providerId: 'fake',
          genres: <String>['fake:genre-${genreNames[i % genreNames.length]}'],
        ),
    ];
  }

  static List<Album> _buildAlbums() {
    const titles = <String>[
      'Northern Static',
      'Winter Circuit',
      'Salt And Signal',
      'Low Orbit Hymns',
      'Copper Skies',
      'Verse In Rust',
      'Hollow Rooms',
      'Timberline',
      'Velvet Frequencies',
      'Circuit Garden',
      'Choir Of Stones',
      'Granite Lullabies',
      'Paper Moons',
      'Comet Tail',
      'Golden Noise',
      'StaticBloom',
      'Orchard After Dark',
      'Midnight Harvest',
      'Glass Tides',
      'Harbor Lights',
      'Aurora Requiem',
      'Iron Lullaby',
      'Fjord Echoes',
      'Silent Currents',
    ];
    return <Album>[
      for (var i = 0; i < titles.length; i++)
        Album(
          id: 'fake:album-$i',
          title: titles[i],
          providerId: 'fake',
          sourceId: 'album-$i',
          artistIds: <String>['fake:artist-${i ~/ 2}'],
          year: 1990 + ((i * 7) % 36),
          trackCount: 8 + (i % 4),
        ),
    ];
  }

  static List<Track> _buildTracks() {
    const adjectives = <String>[
      'Silent',
      'Golden',
      'Hollow',
      'Neon',
      'Velvet',
      'Iron',
      'Paper',
      'Midnight',
      'Glass',
      'Copper',
      'Amber',
      'Frozen',
      'Electric',
      'Lonely',
      'Radiant',
      'Broken',
      'Endless',
      'Quiet',
      'Burning',
      'Distant',
    ];
    const nouns = <String>[
      'Horizon',
      'Signal',
      'Garden',
      'Harbor',
      'Static',
      'Meridian',
      'Comet',
      'Choir',
      'Orchard',
      'Circuit',
    ];
    return <Track>[
      for (var i = 0; i < 200; i++)
        Track(
          id: 'fake:track-$i',
          providerId: 'fake',
          sourceTrackId: 'track-$i',
          title:
              '${adjectives[i % adjectives.length]} '
              '${nouns[i ~/ adjectives.length % nouns.length]} $i',
          createdAt: DateTime.utc(2024).add(Duration(hours: i)),
          updatedAt: DateTime.utc(2024).add(Duration(hours: i)),
          durationMs: 150000 + ((i * 47311) % 240000),
          explicit: i % 17 == 0,
          artistIds: <String>['fake:artist-${i % 12}'],
          albumId: 'fake:album-${i % 24}',
          genreIds: <String>[
            'fake:genre-${genreNames[(i % 12) % genreNames.length]}',
          ],
          year: 1970 + ((i * 13) % 56),
        ),
    ];
  }
}
