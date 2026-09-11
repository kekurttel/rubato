import 'package:uuid/uuid.dart';

/// Stable identifier helpers (spec section 5).
///
/// Remote/local source entities use `${providerId}:${sourceId}` as their
/// `Track`/`Artist`/`Album` id. Internal DB rows use random uuid v7.
abstract final class AuroraIds {
  static const Uuid _uuid = Uuid();

  /// Generates a random uuid v7 (time-ordered, DB-friendly).
  static String newId() => _uuid.v7();

  /// Generates a playback session id (uuid v7).
  static String newSessionId() => _uuid.v7();

  /// Builds the composite `${providerId}:${sourceId}` entity id.
  static String trackId(String providerId, String sourceId) =>
      '$providerId:$sourceId';

  /// Splits a composite id back into provider/source parts.
  ///
  /// Splits on the *first* colon so source ids containing colons survive.
  /// Returns `null` when [id] has no usable separator.
  static ({String providerId, String sourceId})? splitTrackId(String id) {
    final separator = id.indexOf(':');
    if (separator <= 0 || separator == id.length - 1) {
      return null;
    }
    return (
      providerId: id.substring(0, separator),
      sourceId: id.substring(separator + 1),
    );
  }
}
