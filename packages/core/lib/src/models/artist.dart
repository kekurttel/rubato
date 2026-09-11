import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist.freezed.dart';
part 'artist.g.dart';

/// An artist entity (spec section 5).
@freezed
abstract class Artist with _$Artist {
  /// Creates an artist.
  const factory Artist({
    /// Composite `${providerId}:${sourceId}` id.
    required String id,

    /// Display name.
    required String name,

    /// Provider-scoped id.
    required String sourceId,

    /// Owning provider (`local`, `fake`, `ytdlp`).
    required String providerId,

    /// Genre ids.
    @Default(<String>[]) List<String> genres,

    /// Artwork URL, if the provider supplied one.
    String? imageUrl,
  }) = _Artist;

  const Artist._();

  /// Deserializes an artist from JSON.
  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
}
