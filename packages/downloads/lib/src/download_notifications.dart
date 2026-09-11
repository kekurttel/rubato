import 'package:aurora_core/aurora_core.dart';

/// Foreground-service + notification seam for the download queue.
///
/// The manager calls these hooks on every transition; the app wires
/// them to the platform lane (Android foreground service with an
/// ongoing progress notification + completion/failure toasts). This
/// package never imports plugins itself, so the queue stays testable
/// without a device.
abstract class DownloadNotificationHook {
  /// A job entered the queue.
  void onEnqueued(DownloadJob job);

  /// Throttled progress for an active job (matches DB writes).
  void onProgress(DownloadJob job);

  /// A job verified and flipped `is_downloaded` to 1.
  void onCompleted(DownloadJob job);

  /// A job reached a terminal or parked state (failed/paused/canceled).
  void onStateChanged(DownloadJob job);
}

/// No-op hook for tests and headless use.
final class SilentDownloadNotifications implements DownloadNotificationHook {
  /// Creates the silent hook.
  const SilentDownloadNotifications();

  @override
  void onCompleted(DownloadJob job) {}

  @override
  void onEnqueued(DownloadJob job) {}

  @override
  void onProgress(DownloadJob job) {}

  @override
  void onStateChanged(DownloadJob job) {}
}
