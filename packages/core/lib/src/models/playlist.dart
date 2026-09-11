import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

/// A playlist (spec section 5).
///
/// System playlists (`liked`, `recently_played` virtual, `downloads`)
/// carry [isSystem] = true and cannot be renamed by the user.
@freezed
abstract class Playlist with _$Playlist {
  /// Creates a playlist.
  const factory Playlist({
    /// Playlist id (uuid v7; system ids are well-known strings).
    required String id,

    /// Display title.
    required String title,

    /// Creation time (UTC).
    required DateTime createdAt,

    /// Last modification time (UTC).
    required DateTime updatedAt,

    /// Optional user description.
    String? description,

    /// Cover artwork id, if any.
    String? artworkId,

    /// Whether this is a built-in system playlist.
    @Default(false) bool isSystem,
  }) = _Playlist;

  const Playlist._();

  /// Deserializes a playlist from JSON.
  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}
