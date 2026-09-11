import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_entry.freezed.dart';
part 'playlist_entry.g.dart';

/// Membership of a track in a playlist (spec section 5).
@freezed
abstract class PlaylistEntry with _$PlaylistEntry {
  /// Creates a playlist entry.
  const factory PlaylistEntry({
    /// Owning playlist id.
    required String playlistId,

    /// Member track id.
    required String trackId,

    /// Zero-based order inside the playlist.
    required int position,

    /// Time the track was added (UTC).
    required DateTime addedAt,
  }) = _PlaylistEntry;

  const PlaylistEntry._();

  /// Deserializes an entry from JSON.
  factory PlaylistEntry.fromJson(Map<String, dynamic> json) =>
      _$PlaylistEntryFromJson(json);
}
