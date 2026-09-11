import 'dart:io' show Platform;

import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

/// Audio-library permission state (platform-agnostic surface).
enum LocalPermissionStatus {
  /// OS granted audio/file access.
  granted,

  /// OS denied (rationale may be shown again).
  denied,

  /// OS permanently denied (user must open Settings).
  permanentlyDenied,
}

/// Permission UX hook for the local scan (spec section 7).
///
/// The UI explains *why* access is needed before calling
/// [requestAudioAccess]; when denied, it shows an empty state with a
/// Settings button (wired via [openSettings]).
abstract class LocalPermissionHandler {
  /// Creates the handler.
  const LocalPermissionHandler();

  /// Copy shown before the system prompt (UI hook).
  String get rationale =>
      'Aurora reads the music files already on this device to build '
      'your library. Nothing is uploaded.';

  /// Whether audio/file access is currently granted.
  Future<LocalPermissionStatus> checkAudioAccess();

  /// Requests audio/file access (shows the OS prompt once).
  Future<LocalPermissionStatus> requestAudioAccess();

  /// Best-effort `READ_MEDIA_IMAGES` grant for MediaStore thumbnails.
  ///
  /// Requests `Permission.photos` on Android 13+ without affecting the
  /// audio grant. Returns a short status string (`granted`, `limited`,
  /// `denied`, `permanentlyDenied`, `error`, `unknown`) for scan
  /// diagnostics. Never throws: denials and platform errors surface as
  /// a string so callers never gate scan success on it.
  Future<String> requestImagesGrant() async => 'unknown';

  /// Opens the OS app-settings page (permanently-denied path).
  Future<bool> openSettings();
}

/// `permission_handler`-backed implementation.
@immutable
final class PermissionHandlerAudioAccess extends LocalPermissionHandler {
  /// Creates the handler.
  const PermissionHandlerAudioAccess();

  @override
  Future<LocalPermissionStatus> checkAudioAccess() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return LocalPermissionStatus.granted;
    }
    final status = await Permission.audio.status;
    if (status.isGranted || status.isLimited) {
      return LocalPermissionStatus.granted;
    }
    // Pre-Android-13 grants land on `storage`; honor them too.
    if (await Permission.storage.status.then((s) => s.isGranted)) {
      return LocalPermissionStatus.granted;
    }
    return status.isPermanentlyDenied
        ? LocalPermissionStatus.permanentlyDenied
        : LocalPermissionStatus.denied;
  }

  @override
  Future<LocalPermissionStatus> requestAudioAccess() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return LocalPermissionStatus.granted;
    }
    var status = await Permission.audio.request();
    if (status.isGranted || status.isLimited) {
      // Audio covers the catalog; thumbnails additionally need the
      // images grant on API 33+ (READ_MEDIA_IMAGES rides on
      // `Permission.photos`). Best-effort: a denied images grant must
      // not demote an otherwise-granted library scan — thumbnail reads
      // then fail silently per-row while embedded art still lands.
      await _requestImagesGrant();
      return LocalPermissionStatus.granted;
    }
    status = await Permission.storage.request();
    if (status.isGranted || status.isLimited) {
      await _requestImagesGrant();
      return LocalPermissionStatus.granted;
    }
    return status.isPermanentlyDenied
        ? LocalPermissionStatus.permanentlyDenied
        : LocalPermissionStatus.denied;
  }

  /// Best-effort `READ_MEDIA_IMAGES` grant for MediaStore thumbnails.
  ///
  /// `permission_handler` surfaces it as [Permission.photos] on
  /// Android 13+. Never throws: pre-33 devices, non-Android platforms,
  /// or missing manifest entries yield `denied`, which callers ignore.
  static Future<void> _requestImagesGrant() async {
    try {
      await Permission.photos.request();
    } on Exception {
      // Thumbnail-only grant: failure leaves embedded-art extraction
      // (gated on the audio grant above) fully functional.
    }
    // Media notification (playback controls on lockscreen / quick
    // settings) needs POST_NOTIFICATIONS on Android 13+. Best-effort
    // and independent: never affects the library scan outcome.
    try {
      await Permission.notification.request();
    } on Exception {
      // In-app playback still works; the system notification just
      // stays hidden until the user grants it in Settings.
    }
  }

  @override
  Future<String> requestImagesGrant() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return 'unsupported';
    }
    // Piggy-back the notification grant here too: this runs on every
    // scan, so existing users (audio already granted long ago) still
    // get the one-time system prompt for media notifications.
    try {
      await Permission.notification.request();
    } on Object catch (_) {
      // Best-effort only.
    }
    try {
      final status = await Permission.photos.request();
      if (status.isGranted) {
        return 'granted';
      }
      if (status.isLimited) {
        return 'limited';
      }
      if (status.isPermanentlyDenied) {
        return 'permanentlyDenied';
      }
      return 'denied';
    } on Object catch (_) {
      return 'error';
    }
  }

  @override
  Future<bool> openSettings() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Future.value(true);
    }
    return openAppSettings();
  }
}
