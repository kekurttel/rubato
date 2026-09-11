import 'package:aurora_core/src/models/album.dart';
import 'package:aurora_core/src/models/artist.dart';
import 'package:aurora_core/src/models/enums.dart';
import 'package:aurora_core/src/models/track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search.freezed.dart';
part 'search.g.dart';

/// A catalog search request (spec section 5 + 11).
@freezed
abstract class SearchQuery with _$SearchQuery {
  /// Creates a search query.
  const factory SearchQuery({
    /// Raw user text (min 2 chars enforced by the UI).
    required String text,

    /// Entity kinds to include.
    @Default(SearchType.values) List<SearchType> types,

    /// Per-kind page size.
    @Default(20) int limit,

    /// Opaque provider cursor for pagination, if any.
    String? cursor,
  }) = _SearchQuery;

  const SearchQuery._();

  /// Deserializes a query from JSON.
  factory SearchQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchQueryFromJson(json);
}

/// One merged page of search results (spec section 5 + 11).
///
/// Results are split by kind so the Songs / Artists / Albums tabs render
/// without re-filtering (spec 11); playlists stay local-only in v1 and
/// are served from the library repository, not this page.
@freezed
abstract class SearchPage with _$SearchPage {
  /// Creates a search result page.
  const factory SearchPage({
    /// Provider that produced this page (`local`, `fake`, `ytdlp`).
    required String providerId,

    /// Fetch time (UTC) — drives the 12h search TTL.
    required DateTime fetchedAt,

    /// Matching tracks (Songs tab).
    @Default(<Track>[]) List<Track> tracks,

    /// Matching artists (Artists tab).
    @Default(<Artist>[]) List<Artist> artists,

    /// Matching albums (Albums tab).
    @Default(<Album>[]) List<Album> albums,

    /// Opaque cursor for the next page, if any.
    String? nextCursor,
  }) = _SearchPage;

  const SearchPage._();

  /// Deserializes a page from JSON.
  factory SearchPage.fromJson(Map<String, dynamic> json) =>
      _$SearchPageFromJson(json);

  /// Whether the page holds no results at all.
  bool get isEmpty => tracks.isEmpty && artists.isEmpty && albums.isEmpty;

  /// Total hit count across kinds.
  int get totalCount => tracks.length + artists.length + albums.length;
}
