import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';

/// Download queue boundary behind the Downloads tab.
///
/// The app lane injects the real queue manager here so these
/// widgets never import Drift tables or provider internals directly
/// (see the `ui-vs-drift` graze in `tool/ci.sh`).
abstract class DownloadsService {
  /// All jobs, newest-first (re-emitted after every mutation).
  Stream<List<DownloadJob>> watchJobs();

  /// Resolves the human-readable track title for a download row.
  Future<String?> trackTitle(String trackId);

  /// Parks [jobId] in paused.
  Future<void> pause(String jobId);

  /// Re-queues a paused job.
  Future<void> resume(String jobId);

  /// Re-queues a failed/canceled/fileMissing job (attempts reset).
  Future<void> retry(String jobId);

  /// Cancels [jobId] (partial bytes are discarded).
  Future<void> cancel(String jobId);

  /// Mirrors UI settings into the queue manager (wifi-only, quality,
  /// concurrency). Only non-null fields are applied.
  void updateDownloadSettings({
    bool? wifiOnly,
    Quality? quality,
    int? concurrency,
  });

  /// Restores the persisted download folder, applies it to the queue
  /// manager, and returns the (location, resolved path) pair.
  Future<(DownloadLocation, String)> restoreDownloadLocation();

  /// Persists [location], applies its resolved folder to the queue
  /// manager, and returns the resolved path for the setting row.
  Future<String> setDownloadLocation(DownloadLocation location);
}
