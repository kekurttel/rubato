import 'package:aurora_core/aurora_core.dart';

/// Search tab (spec section 11: Songs / Artists / Albums / Playlists).
enum SearchTab {
  /// Tracks (Songs tab).
  songs,

  /// Artists tab.
  artists,

  /// Albums tab.
  albums,

  /// Playlists tab (local only in v1).
  playlists,
}

/// Display labels for [SearchTab].
extension SearchTabLabel on SearchTab {
  /// Tab label shown in the tab bar.
  String get label => switch (this) {
    SearchTab.songs => 'Songs',
    SearchTab.artists => 'Artists',
    SearchTab.albums => 'Albums',
    SearchTab.playlists => 'Playlists',
  };
}

/// Search boundary behind the Search tab (wired in the app lane).
///
/// Local search reads the on-device FTS index (pinned section);
/// online search delegates to the yt-dlp provider (`[Online]` badge).
/// Implementations live outside this feature so these widgets never
/// import Drift tables or provider internals directly.
abstract class CatalogSearchService {
  /// Searches the local FTS index (title/artist/album).
  Future<SearchPage> searchLocal(SearchQuery query);

  /// Searches the online provider (empty page when offline).
  Future<SearchPage> searchOnline(SearchQuery query);

  /// Online reachability for the `[Online]` badge and offline banner.
  Stream<ProviderHealth> onlineHealth();
}

/// Playback + download actions behind search rows.
abstract class SearchActions {
  /// Display artist line for [track] (ids resolved to names).
  String artistLine(Track track);

  /// Cover art URL for [track], if the provider cached one.
  String? artworkUrlFor(Track track);

  /// Streams [track] now (local file or authorized stream handle).
  ///
  /// Returns null when playback started; otherwise the short, concrete
  /// failure reason (which runtime failed + why) for a snackbar.
  Future<String?> playStream(Track track);

  /// Enqueues [track] at [quality] (opens the download queue).
  ///
  /// Returns null when the job was queued; otherwise the short reason
  /// (quota, missing track, ...) for a snackbar.
  Future<String?> enqueueDownload(Track track, Quality quality);

  /// Active download state for [trackId], if a job exists.
  DownloadState? downloadStateFor(String trackId);

  /// Active download progress (0..1) for [trackId].
  double downloadProgressFor(String trackId);
}

/// Formats an `onlineResultsProvider` failure for the error state.
///
/// Provider failures arrive as [AppException] (thrown by the search
/// boundary so the real cause survives); the message + machine code
/// are shown instead of a generic banner. Anything else falls back to
/// a trimmed one-line string. Never throws.
String friendlyOnlineSearchError(Object error) {
  if (error is AppException) {
    final details = error.error.details;
    final base = error.error.message.trim();
    final text =
        details == null ||
            details.isEmpty ||
            base.contains(details.trim())
        ? base
        : '$base [${details.trim()}]';
    return text.length > 180 ? '${text.substring(0, 180)}…' : text;
  }
  final raw = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  return raw.length > 180 ? '${raw.substring(0, 180)}…' : raw;
}
