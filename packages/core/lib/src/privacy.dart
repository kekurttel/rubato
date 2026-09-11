import 'package:aurora_core/src/models/play_event.dart';
import 'package:aurora_core/src/models/playlist.dart';
import 'package:aurora_core/src/models/preference_profile.dart';

/// Code enforcement for spec section 16: listening history, the
/// preference profile, and playlists must never leave the device.
///
/// Future HTTP providers must call [assertNoPersonalDataInHttpBody] on
/// every outbound body in debug builds. HTTP is allowed only for
/// search / metadata / artwork / authorized stream URLs — never event
/// or profile payloads.
bool containsPersonalPayload(Object? body) {
  if (body == null) {
    return false;
  }
  if (body is PlayEvent || body is PreferenceProfile || body is Playlist) {
    return true;
  }
  if (body is Map) {
    return body.values.any(containsPersonalPayload);
  }
  if (body is Iterable) {
    return body.any(containsPersonalPayload);
  }
  return false;
}

/// Debug-asserts that [body] carries no on-device personal data.
///
/// No-op in release builds (asserts are stripped); hard failure in
/// debug/profile so leaks are caught during development, not review.
void assertNoPersonalDataInHttpBody(Object? body) {
  assert(
    !containsPersonalPayload(body),
    'Personal data (PlayEvent/PreferenceProfile/Playlist) must never '
    'be encoded into an HTTP body. See spec section 16.',
  );
}
