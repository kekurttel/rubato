import 'package:aurora_core/src/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_job.freezed.dart';
part 'download_job.g.dart';

/// One unit of queued download work (spec section 5 + 12).
///
/// Lifecycle: queued -> fetchingMeta -> downloading -> verifying ->
/// completed, with sideways exits to paused / canceled and
/// downloading -> failed (retry `2^attempts` seconds, max 5 attempts).
/// completed -> fileMissing when the bytes vanish from disk.
@freezed
abstract class DownloadJob with _$DownloadJob {
  /// Creates a download job.
  const factory DownloadJob({
    /// Job id (uuid v7).
    required String id,

    /// Track being persisted.
    required String trackId,

    /// Creation time (UTC).
    required DateTime createdAt,

    /// Last update time (UTC).
    required DateTime updatedAt,

    /// Lifecycle state.
    @Default(DownloadState.queued) DownloadState state,

    /// 0..1 progress of the active phase.
    @Default(0) double progress,

    /// Bytes received so far.
    @Default(0) int bytesReceived,

    /// Expected total bytes, when the provider reported it.
    int? bytesTotal,

    /// Machine-readable failure code of the last attempt.
    String? errorCode,

    /// Human-readable failure message of the last attempt.
    String? errorMessage,

    /// Attempts made so far (drives backoff, caps at 5).
    @Default(0) int attempts,

    /// Quality label used for this job (low/medium/high/original).
    String? qualityLabel,

    /// Persisted file path once completed.
    String? filePath,
  }) = _DownloadJob;

  const DownloadJob._();

  /// Deserializes a job from JSON.
  factory DownloadJob.fromJson(Map<String, dynamic> json) =>
      _$DownloadJobFromJson(json);

  /// Whether the job is in a terminal state.
  bool get isTerminal =>
      state == DownloadState.completed ||
      state == DownloadState.failed ||
      state == DownloadState.canceled ||
      state == DownloadState.fileMissing;

  /// Whether the job is actively progressing.
  bool get isActive =>
      state == DownloadState.fetchingMeta ||
      state == DownloadState.downloading ||
      state == DownloadState.verifying;
}
