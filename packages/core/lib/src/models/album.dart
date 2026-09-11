import 'package:freezed_annotation/freezed_annotation.dart';

part 'album.freezed.dart';
part 'album.g.dart';

/// An album entity (spec section 5).
@freezed
abstract class Album with _$Album {
  /// Creates an album.
  const factory Album({
    /// Composite `${providerId}:${sourceId}` id.
    required String id,

    /// Display title.
    required String title,

    /// Owning provider (`local`, `fake`, `ytdlp`).
    required String providerId,

    /// Provider-scoped id.
    required String sourceId,

    /// Artist ids in credit order.
    @Default(<String>[]) List<String> artistIds,

    /// Release year, if known.
    int? year,

    /// Cover artwork id, if cached.
    String? artworkId,

    /// Known track count (0 when unknown).
    @Default(0) int trackCount,
  }) = _Album;

  const Album._();

  /// Deserializes an album from JSON.
  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
