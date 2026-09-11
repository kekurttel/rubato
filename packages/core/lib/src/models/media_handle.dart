import 'package:aurora_core/src/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_handle.freezed.dart';
part 'media_handle.g.dart';

/// A resolved playable for one track + quality (spec section 5).
///
/// Returned by `MusicProvider.resolvePlayable`. Stream handles expire
/// (re-resolve once on 403/404/timeout, then surface the error);
/// local files never expire.
@freezed
abstract class MediaHandle with _$MediaHandle {
  /// Creates a media handle.
  const factory MediaHandle({
    /// How [uri] must be interpreted by the player.
    required MediaHandleKind kind,

    /// File path (localFile) or provider-authorized HTTPS URL
    /// (authorizedStream).
    required String uri,

    /// Stream URL expiry (null for local files).
    DateTime? expiresAt,

    /// MIME type hint, when the provider reported one.
    String? mimeType,

    /// Quality label this handle was resolved for.
    String? qualityLabel,

    /// Provider auth headers, only when the provider requires them.
    @Default(<String, String>{}) Map<String, String> headers,
  }) = _MediaHandle;

  const MediaHandle._();

  /// Deserializes a handle from JSON.
  factory MediaHandle.fromJson(Map<String, dynamic> json) =>
      _$MediaHandleFromJson(json);

  /// Whether this handle points at an on-disk file.
  bool get isLocalFile => kind == MediaHandleKind.localFile;

  /// Whether an expiring stream handle is past its TTL.
  bool isExpiredAt(DateTime now) =>
      kind == MediaHandleKind.authorizedStream &&
      expiresAt != null &&
      !now.isBefore(expiresAt!);
}
