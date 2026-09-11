import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

/// A playable audio entity (spec section 5).
///
/// [id] is the composite `${providerId}:${sourceTrackId}` key. Times are
/// UTC; the database stores them as epoch milliseconds.
@freezed
abstract class Track with _$Track {
  /// Creates a track.
  const factory Track({
    /// Composite `${providerId}:${sourceTrackId}` id.
    required String id,

    /// Owning provider (`local`, `fake`, `ytdlp`).
    required String providerId,

    /// Provider-scoped id (MYT `(_ID_)` suffix, video id, ...).
    required String sourceTrackId,

    /// Clean display title (never the raw `(_ID_)` filename).
    required String title,

    /// Row creation time (UTC).
    required DateTime createdAt,

    /// Row update time (UTC).
    required DateTime updatedAt,

    /// Duration in milliseconds (0 when unknown).
    @Default(0) int durationMs,

    /// Explicit-content flag.
    @Default(false) bool explicit,

    /// Artist ids in credit order.
    @Default(<String>[]) List<String> artistIds,

    /// Parent album id, if known.
    String? albumId,

    /// Genre ids.
    @Default(<String>[]) List<String> genreIds,

    /// Release year, if known.
    int? year,

    /// Content hash (first+last 64KB + length) for dedupe.
    String? audioHash,

    /// On-disk path when a usable local file exists.
    String? localPath,

    /// Whether a verified download is persisted.
    @Default(false) bool isDownloaded,

    /// Stream URL expiry for [providerId] != local tracks.
    DateTime? streamExpiresAt,
  }) = _Track;

  const Track._();

  /// Deserializes a track from JSON.
  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  /// Whether a usable local file path is attached.
  bool get hasLocalFile => localPath != null && localPath!.isNotEmpty;

  /// [durationMs] as a [Duration].
  Duration get duration => Duration(milliseconds: durationMs);

  /// Fallback YouTube thumbnail URL when [sourceTrackId] is an 11-char ID.
  String? get fallbackThumbnailUrl => trackFallbackThumbnailUrl(this);
}

final _youtubeIdRegex = RegExp(r'^[A-Za-z0-9_-]{11}$');

/// Fallback YouTube thumbnail URL when [track] has an 11-char ID.
///
/// MYT-downloaded tracks lack embedded artwork; when sourceTrackId matches
/// the 11-character YouTube video id format, their cover is retrieved from
/// YouTube's `hqdefault.jpg` thumbnail endpoint.
String? trackFallbackThumbnailUrl(Track track) {
  final id = track.sourceTrackId;
  if (id.length == 11 && _youtubeIdRegex.hasMatch(id)) {
    return 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
  }
  return null;
}
