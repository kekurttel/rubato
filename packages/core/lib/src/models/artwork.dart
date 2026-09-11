import 'package:freezed_annotation/freezed_annotation.dart';

part 'artwork.freezed.dart';
part 'artwork.g.dart';

/// Cached artwork reference (spec section 5).
///
/// Either [url] (remote thumb, cached via the artwork pipeline) or
/// [localPath] (extracted embedded art) is expected to be set.
@freezed
abstract class Artwork with _$Artwork {
  /// Creates an artwork reference.
  const factory Artwork({
    /// Artwork id (content-addressed where possible).
    required String id,

    /// Last fetch/update time (UTC).
    required DateTime updatedAt,

    /// Remote URL the bytes were fetched from, if any.
    String? url,

    /// App-cache path of the persisted bytes, if any.
    String? localPath,

    /// Dominant color as ARGB int (for Now Playing scrims).
    int? dominantColorArgb,

    /// Pixel width, if known.
    int? width,

    /// Pixel height, if known.
    int? height,
  }) = _Artwork;

  const Artwork._();

  /// Deserializes artwork from JSON.
  factory Artwork.fromJson(Map<String, dynamic> json) =>
      _$ArtworkFromJson(json);
}
