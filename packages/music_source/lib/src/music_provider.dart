import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/src/models.dart';

/// Plugin interface for every music/content source (spec section 7).
///
/// Implementations live in `music_source_local`, `music_source_fake`,
/// and `music_source_ytdlp`. Implementations must never import widgets;
/// `reco` must never import the yt-dlp implementation.
abstract class MusicProvider {
  /// Stable provider id (`local`, `fake`, `ytdlp`, `remote`).
  String get id;

  /// Human-readable name shown in settings / badges.
  String get displayName;

  /// Whether [search] returns meaningful results.
  bool get supportsSearch;

  /// Whether tracks can be persisted via the download queue.
  bool get supportsDownload;

  /// Whether [resolvePlayable] can produce a playable handle
  /// (local file or authorized stream URL).
  bool get supportsStream;

  /// Reachability stream driving offline banners and badges.
  ///
  /// Emits the current health first, then updates. Streams never throw;
  /// providers emit [ProviderHealth.offline] instead of closing on error.
  Stream<ProviderHealth> health();

  /// Searches the provider catalog (debounced + cancellable by callers).
  Future<Result<SearchPage, AppError>> search(SearchQuery query);

  /// Fetches one track by provider-scoped [sourceId].
  Future<Result<Track, AppError>> getTrack(String sourceId);

  /// Fetches one artist by provider-scoped [sourceId].
  Future<Result<ArtistDetails, AppError>> getArtist(String sourceId);

  /// Fetches one album by provider-scoped [sourceId].
  Future<Result<AlbumDetails, AppError>> getAlbum(String sourceId);

  /// Resolves a playable handle for [track] at [quality].
  ///
  /// Local files resolve to [MediaHandleKind.localFile] (never expiring).
  /// Remote tracks resolve to [MediaHandleKind.authorizedStream] with
  /// `expiresAt` set; callers re-resolve once on 403/404/timeout.
  Future<Result<MediaHandle, AppError>> resolvePlayable(
    Track track,
    Quality quality,
  );

  /// Resolves cached artwork for [track], if the provider has any.
  Future<Result<Artwork, AppError>> artwork(Track track);
}
