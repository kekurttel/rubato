import 'dart:async';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_database/aurora_database.dart';
import 'package:aurora_downloads/src/download_notifications.dart';
import 'package:aurora_downloads/src/download_settings.dart';
import 'package:aurora_downloads/src/download_tree_channel.dart';
import 'package:aurora_downloads/src/download_verify.dart';
import 'package:aurora_downloads/src/download_visibility.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// Loads a [Track] for a job's `trackId` (null when the row is gone).
typedef TrackLoader = Future<Track?> Function(String trackId);

/// Performs one transfer and returns the final audio file path.
///
/// Contract (keeps playback safe while bytes flow):
/// - Write to a temp sibling (`*.part`) and atomically rename only on
///   success, so the final path never points at half-written bytes.
/// - Report `0..1` progress; the manager throttles DB writes.
/// - Never write the download target while a stream handle for the same
///   track is playing: stream-while-downloading always uses the
///   provider's `authorizedStream` handle, never this file.
typedef DownloadExecutor =
    Future<Result<String, AppError>> Function({
      required Track track,
      required Quality quality,
      required Directory outputDir,
      required void Function(double progress) onProgress,
    });

/// Returns true on unmetered networks (wifi-only gate).
typedef NetworkPolicy = Future<bool> Function();

/// Returns free bytes under [DownloadManager.outputDir], if known.
typedef FreeBytesProbe = Future<int?> Function();

/// Download queue (spec section 12).
///
/// Lifecycle: queued → fetchingMeta → downloading → verifying →
/// completed, with sideways exits to paused / canceled and
/// downloading → failed (retry `2^attempts` seconds, max 5 attempts).
/// completed → fileMissing when playback reports vanished bytes.
///
/// - Concurrency defaults to 1 (settings allow 1..3).
/// - Wifi-only defaults to true: on metered networks jobs park in
///   paused until [NetworkPolicy] says otherwise.
/// - Completion flips `is_downloaded` to 1 via [TracksDao.setLocalFile].
/// - Foreground-service UI attaches through [DownloadNotificationHook].
final class DownloadManager {
  /// Creates a manager over [downloads] + [tracks].
  DownloadManager({
    required this.downloads,
    required this.tracks,
    required this.outputDir,
    TrackLoader? loadTrack,
    DownloadExecutor? executor,
    NetworkPolicy? isUnmetered,
    FreeBytesProbe? freeBytes,
    DownloadNotificationHook? notifications,
    DurationProbe? probeDuration,
    Clock? clock,
    DownloadSettings? settings,
  }) : _settings = settings ?? const DownloadSettings(),
       _notifications = notifications ?? const SilentDownloadNotifications(),
       // Public camelCase names stay (an initializing formal would
       // expose a library-private name on the public constructor).
       // ignore: prefer_initializing_formals
       _probeDuration = probeDuration,
       clock = clock ?? const SystemClock(),
       // Same public-name rationale as above.
       // ignore: prefer_initializing_formals
       _freeBytes = freeBytes {
    _loadTrack =
        loadTrack ??
        (String trackId) async {
          final row = await tracks.getById(trackId);
          return row == null ? null : DbMappers.toTrack(row);
        };
    _executor =
        executor ??
        ({
          required track,
          required quality,
          required outputDir,
          required onProgress,
        }) async => const Failure(
          AppError(
            code: AppErrorCode.provider,
            message: 'No download executor wired (app must inject one)',
            details: 'downloads:no-executor',
          ),
        );
    _isUnmetered = isUnmetered ?? (() async => true);
  }

  /// Maximum transfer attempts per job (terminal `failed` after this).
  static const int maxAttempts = 5;

  /// Retry backoff for [attempts] made so far: `2^attempts` seconds.
  ///
  /// Attempt counts start at 1, so delays are 2s, 4s, 8s, 16s, 32s.
  static Duration retryDelay(int attempts) =>
      Duration(seconds: 1 << attempts.clamp(1, maxAttempts));

  /// Persisted job rows.
  final DownloadsDao downloads;

  /// Track rows (completion flips `is_downloaded` here).
  final TracksDao tracks;

  /// Destination directory for extracted audio.
  ///
  /// Assignable so the app lane can switch between the private and
  /// the visible external folder at runtime; only transfers STARTED
  /// after the switch use the new directory.
  Directory outputDir;

  /// Notification seam (foreground service in the app lane).
  final DownloadNotificationHook _notifications;

  /// Optional ffprobe duration probe for verification.
  final DurationProbe? _probeDuration;

  /// Injectable clock for timestamps and backoff math.
  final Clock clock;

  final FreeBytesProbe? _freeBytes;

  late final TrackLoader _loadTrack;
  late final DownloadExecutor _executor;
  late final NetworkPolicy _isUnmetered;

  DownloadSettings _settings;

  /// Current settings (concurrency 1..3, wifi-only, quality).
  DownloadSettings get settings => _settings;

  /// Replaces settings and re-pumps (a raised concurrency starts work).
  void updateSettings(DownloadSettings next) {
    _settings = next;
    _pumpQueue();
  }

  final Set<String> _activeIds = <String>{};
  final Set<String> _cancelRequested = <String>{};
  final Set<String> _pauseRequested = <String>{};
  final Map<String, int> _retryNotBeforeMs = <String, int>{};
  final StreamController<List<DownloadJob>> _changes =
      StreamController<List<DownloadJob>>.broadcast();
  bool _pumping = false;
  bool _disposed = false;

  /// Job snapshots after every mutation (drives the Downloads tab).
  Stream<List<DownloadJob>> get changes => _changes.stream;

  /// Closes the [changes] stream.
  Future<void> dispose() async {
    _disposed = true;
    await _changes.close();
  }

  /// All jobs, newest-first.
  Future<List<DownloadJob>> listAll() async {
    final rows = await downloads.listAll();
    return <DownloadJob>[for (final row in rows) DbMappers.toDownloadJob(row)];
  }

  /// Jobs still in flight (queued/fetchingMeta/downloading/verifying).
  Future<List<DownloadJob>> activeJobs() async {
    final all = await listAll();
    return <DownloadJob>[
      for (final job in all)
        if (!job.isTerminal) job,
    ];
  }

  /// Finished jobs (completed first, then failed/canceled/fileMissing).
  Future<List<DownloadJob>> completedJobs() async {
    final all = await listAll();
    return <DownloadJob>[
      for (final job in all)
        if (job.isTerminal) job,
    ];
  }

  /// Current free-space warning for [outputDir].
  Future<QuotaWarning> currentQuotaWarning() async {
    int? free;
    try {
      free = await _freeBytes?.call();
    } on Exception {
      free = null;
    }
    return DownloadQuota.warningForFreeBytes(free);
  }

  /// Enqueues a download for [trackId] and returns the job id.
  ///
  /// Refuses with `io` when free space is below 2 GB, with `notFound`
  /// when the track row is gone, and with `provider` when the track is
  /// already on-device (`providerId == local`, `isDownloaded`, or a
  /// usable `localPath` — see [shouldShowDownloadAction]). The guard
  /// keeps stray ⬇ taps on local rows honest instead of queueing
  /// nonsense work.
  Future<Result<String, AppError>> enqueue({
    required String trackId,
    Quality? quality,
  }) async {
    if (await currentQuotaWarning() == QuotaWarning.blocked) {
      return const Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Not enough free space (need 2 GB to start downloads)',
          details: 'downloads:quota-blocked',
        ),
      );
    }
    final track = await _loadTrack(trackId);
    if (track == null) {
      debugPrint('AURORA_DIAG enqueue track-gone trackId=$trackId');
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Track is gone; cannot download it',
          details: trackId,
        ),
      );
    }
    final hiddenReason = downloadHiddenReason(track);
    if (hiddenReason != null) {
      debugPrint('AURORA_DIAG enqueue already-local trackId=$trackId');
      return Failure(
        AppError(
          code: AppErrorCode.provider,
          message: hiddenReason,
          details: 'downloads:already-local',
        ),
      );
    }
    final now = clock.nowEpochMs();
    final rung = quality ?? _settings.quality;
    final job = DownloadJob(
      id: AuroraIds.newId(),
      trackId: trackId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
      qualityLabel: rung.name,
    );
    await downloads.upsertJob(
      DownloadJobsCompanion(
        id: Value(job.id),
        trackId: Value(job.trackId),
        state: Value(job.state.name),
        progress: const Value(0),
        bytesReceived: const Value(0),
        attempts: const Value(0),
        qualityLabel: Value(job.qualityLabel),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    _notifications.onEnqueued(job);
    await _emit();
    debugPrint('AURORA_DIAG enqueue ok job=${job.id} trackId=$trackId q=$rung');
    _pumpQueue();
    return Success(job.id);
  }

  /// Parks [jobId] in paused (queued jobs stop now; an in-flight
  /// transfer finishes its phase, discards partial bytes, and parks —
  /// resume restarts the transfer rather than resuming corrupt bytes).
  Future<void> pause(String jobId) async {
    final row = await downloads.getById(jobId);
    if (row == null) {
      return;
    }
    final state = DbMappers.toDownloadJob(row).state;
    if (state == DownloadState.completed ||
        state == DownloadState.canceled ||
        state == DownloadState.failed ||
        state == DownloadState.fileMissing) {
      return;
    }
    if (_activeIds.contains(jobId)) {
      _pauseRequested.add(jobId);
    }
    await downloads.setState(
      jobId,
      state: DownloadState.paused.name,
      updatedAt: clock.nowEpochMs(),
      errorMessage: 'Paused',
    );
    await _emitState(jobId);
  }

  /// Re-queues a paused job (attempts preserved).
  Future<void> resume(String jobId) async {
    final row = await downloads.getById(jobId);
    if (row == null) {
      return;
    }
    if (DbMappers.toDownloadJob(row).state != DownloadState.paused) {
      return;
    }
    await downloads.setState(
      jobId,
      state: DownloadState.queued.name,
      updatedAt: clock.nowEpochMs(),
    );
    await _emit();
    _pumpQueue();
  }

  /// Re-queues a failed/canceled/fileMissing job with attempts reset.
  Future<void> retry(String jobId) async {
    final row = await downloads.getById(jobId);
    if (row == null) {
      return;
    }
    final state = DbMappers.toDownloadJob(row).state;
    if (state != DownloadState.failed &&
        state != DownloadState.canceled &&
        state != DownloadState.fileMissing) {
      return;
    }
    _retryNotBeforeMs.remove(jobId);
    await downloads.upsertJob(
      DownloadJobsCompanion(
        id: Value(jobId),
        state: Value(DownloadState.queued.name),
        attempts: const Value(0),
        errorCode: const Value<String?>(null),
        errorMessage: const Value<String?>(null),
        updatedAt: Value(clock.nowEpochMs()),
      ),
    );
    await _emit();
    _pumpQueue();
  }

  /// Cancels [jobId]; partial bytes are discarded, never kept.
  Future<void> cancel(String jobId) async {
    final row = await downloads.getById(jobId);
    if (row == null) {
      return;
    }
    final state = DbMappers.toDownloadJob(row).state;
    if (state == DownloadState.completed ||
        state == DownloadState.canceled ||
        state == DownloadState.fileMissing) {
      return;
    }
    if (_activeIds.contains(jobId)) {
      _cancelRequested.add(jobId);
      _pauseRequested.remove(jobId);
    }
    await downloads.setState(
      jobId,
      state: DownloadState.canceled.name,
      updatedAt: clock.nowEpochMs(),
      errorMessage: 'Canceled',
    );
    await _emitState(jobId);
  }

  /// Marks a completed job's bytes as vanished (playback reports this).
  ///
  /// Transitions completed → fileMissing and clears the track's local
  /// path so playback skips instead of crashing.
  Future<void> reportFileMissing(String jobId, String trackId) async {
    final now = clock.nowEpochMs();
    await downloads.upsertJob(
      DownloadJobsCompanion(
        id: Value(jobId),
        state: Value(DownloadState.fileMissing.name),
        errorMessage: const Value('File missing from disk'),
        updatedAt: Value(now),
      ),
    );
    await tracks.markFileMissing(trackId, updatedAt: now);
    await _emitState(jobId);
  }

  /// Starts queued work while worker slots are free (re-entrant safe).
  void _pumpQueue() {
    if (_disposed || _pumping) {
      return;
    }
    unawaited(_pumpLoop());
  }

  Future<void> _pumpLoop() async {
    if (_pumping || _disposed) {
      return;
    }
    _pumping = true;
    try {
      while (_activeIds.length < _settings.concurrency && !_disposed) {
        final next = await _nextQueued();
        if (next == null) {
          break;
        }
        _activeIds.add(next);
        unawaited(
          _runJob(next).whenComplete(() {
            _activeIds.remove(next);
            _pumpQueue();
          }),
        );
      }
    } finally {
      _pumping = false;
    }
  }

  /// Oldest queued job with no active worker and no pending backoff.
  Future<String?> _nextQueued() async {
    late final List<DbDownloadJob> rows;
    try {
      rows = await downloads.byState(DownloadState.queued.name);
    } on Exception {
      return null;
    }
    final now = clock.nowEpochMs();
    for (var i = rows.length - 1; i >= 0; i--) {
      final row = rows[i];
      if (_activeIds.contains(row.id)) {
        continue;
      }
      final notBefore = _retryNotBeforeMs[row.id];
      if (notBefore != null && now < notBefore) {
        continue;
      }
      _retryNotBeforeMs.remove(row.id);
      return row.id;
    }
    return null;
  }

  Future<void> _runJob(String jobId) async {
    var row = await downloads.getById(jobId);
    if (row == null || _takeParked(jobId, row, cancelled: true)) {
      return;
    }
    final track = await _loadTrack(row.trackId ?? '');
    if (track == null) {
      await _finishFailed(
        jobId,
        (row.attempts ?? 0) + 1,
        const AppError(
          code: AppErrorCode.notFound,
          message: 'Track is gone; cannot download it',
          details: 'downloads:track-gone',
        ),
      );
      return;
    }
    if (_settings.wifiOnly && !await _isUnmeteredSafe()) {
      debugPrint('AURORA_DIAG job $jobId parked wifi-only');
      await downloads.setState(
        jobId,
        state: DownloadState.paused.name,
        updatedAt: clock.nowEpochMs(),
        errorMessage: 'Waiting for an unmetered network',
      );
      await _emitState(jobId);
      return;
    }
    row = await downloads.getById(jobId);
    if (row == null || _takeParked(jobId, row, cancelled: false)) {
      return;
    }
    await downloads.setState(
      jobId,
      state: DownloadState.fetchingMeta.name,
      updatedAt: clock.nowEpochMs(),
    );
    await _emitState(jobId);
    row = await downloads.getById(jobId);
    if (row == null || _takeParked(jobId, row, cancelled: false)) {
      return;
    }
    await downloads.setState(
      jobId,
      state: DownloadState.downloading.name,
      updatedAt: clock.nowEpochMs(),
    );
    await _emitState(jobId);
    final quality = _qualityFrom(row.qualityLabel);
    var lastSent = 0.0;
    final baseBytes = row.bytesReceived ?? 0;
    late final Result<String, AppError> transfer;
    try {
      transfer = await _executor(
        track: track,
        quality: quality,
        outputDir: outputDir,
        onProgress: (progress) {
          if ((progress - lastSent).abs() < 0.02 && progress < 1) {
            return;
          }
          lastSent = progress;
          unawaited(
            downloads
                .updateProgress(
                  jobId,
                  progress: progress.clamp(0, 1).toDouble(),
                  bytesReceived: baseBytes,
                  updatedAt: clock.nowEpochMs(),
                )
                .then((_) => _emitState(jobId)),
          );
        },
      );
    } on Object catch (error) {
      // A throwing executor (e.g. a local-file copy hitting EACCES)
      // must fail the job with a reason, never strand it in
      // `downloading` forever with an unhandled async error.
      transfer = Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Download failed',
          details: 'downloads:executor-throw',
          cause: error,
        ),
      );
    }
    if (_cancelRequested.remove(jobId)) {
      await _discardPath(transfer.valueOrNull);
      await downloads.setState(
        jobId,
        state: DownloadState.canceled.name,
        updatedAt: clock.nowEpochMs(),
        errorMessage: 'Canceled',
      );
      await _emitState(jobId);
      return;
    }
    if (_pauseRequested.remove(jobId)) {
      await _discardPath(transfer.valueOrNull);
      await downloads.setState(
        jobId,
        state: DownloadState.paused.name,
        updatedAt: clock.nowEpochMs(),
        errorMessage: 'Paused',
      );
      await _emitState(jobId);
      return;
    }
    switch (transfer) {
      case Failure(:final error):
        debugPrint(
          'AURORA_DIAG job $jobId executor fail '
          '${error.code.name}:${error.details} ${error.message}',
        );
        final attempts = ((await downloads.getById(jobId))?.attempts ?? 0) + 1;
        await _finishFailed(jobId, attempts, error);
      case Success(:final value):
        debugPrint('AURORA_DIAG job $jobId executor ok len=${value.length}');
        await _finishVerifying(jobId, track, value);
    }
  }

  /// Honors a pause/cancel recorded while the job was between phases.
  ///
  /// Returns true when the job was parked (caller must stop). The DB
  /// row already carries the parked state; this only re-emits it.
  bool _takeParked(String jobId, DbDownloadJob row, {required bool cancelled}) {
    final parked = cancelled
        ? _cancelRequested.remove(jobId)
        : (_cancelRequested.remove(jobId) || _pauseRequested.remove(jobId));
    if (!parked) {
      final state = DbMappers.toDownloadJob(row).state;
      return state == DownloadState.paused || state == DownloadState.canceled;
    }
    return true;
  }

  Future<void> _finishVerifying(
    String jobId,
    Track track,
    String filePath,
  ) async {
    final now = clock.nowEpochMs();
    await downloads.setState(
      jobId,
      state: DownloadState.verifying.name,
      updatedAt: now,
    );
    await _emitState(jobId);
    final outcome = await DownloadVerification.verify(
      file: File(filePath),
      expectedDurationMs: track.durationMs,
      probeDurationMs: _probeDuration,
    );
    switch (outcome) {
      case Failure(:final error):
        await _discardPath(filePath);
        final attempts = ((await downloads.getById(jobId))?.attempts ?? 0) + 1;
        await _finishFailed(jobId, attempts, error);
      case Success(:final value):
        // Custom SAF folder: the executor staged to a temp file;
        // export its bytes into the tree via ContentResolver. The
        // staging path stays canonical for playback (a `content://`
        // tree URI is not a `File` path), so the tree copy is the
        // user-visible export. Failures surface as typed job errors
        // in the Downloads UI (permission ⇒ revoked grant).
        final treeUri = DownloadTreeDestination.treeUri;
        if (treeUri != null && treeUri.isNotEmpty) {
          final exported = await DownloadTreeChannel.writer(
            treeUri: treeUri,
            sourceFile: File(filePath),
            filename: _basenameOf(filePath),
          );
          switch (exported) {
            case Failure(:final error):
              await _discardPath(filePath);
              final attempts =
                  ((await downloads.getById(jobId))?.attempts ?? 0) + 1;
              await _finishFailed(jobId, attempts, error);
              return;
            case Success():
              break;
          }
        }
        final doneAt = clock.nowEpochMs();
        await tracks.setLocalFile(
          track.id,
          localPath: filePath,
          isDownloaded: true,
          updatedAt: doneAt,
        );
        await downloads.upsertJob(
          DownloadJobsCompanion(
            id: Value(jobId),
            state: Value(DownloadState.completed.name),
            progress: const Value(1),
            bytesReceived: Value(value),
            filePath: Value(filePath),
            errorCode: const Value<String?>(null),
            errorMessage: const Value<String?>(null),
            updatedAt: Value(doneAt),
          ),
        );
        await _emitState(jobId);
    }
  }

  Future<void> _finishFailed(String jobId, int attempts, AppError error) async {
    final now = clock.nowEpochMs();
    // Permission failures (e.g. a revoked SAF tree grant) never heal by
    // retrying: fail terminally at once so the Downloads UI can show the
    // reason and the app lane can fall back to app-private storage.
    if (attempts >= maxAttempts || error.code == AppErrorCode.permission) {
      await downloads.upsertJob(
        DownloadJobsCompanion(
          id: Value(jobId),
          state: Value(DownloadState.failed.name),
          attempts: Value(attempts),
          errorCode: Value(error.code.name),
          errorMessage: Value(error.message),
          updatedAt: Value(now),
        ),
      );
      await _emitState(jobId);
      return;
    }
    final delay = retryDelay(attempts);
    _retryNotBeforeMs[jobId] = now + delay.inMilliseconds;
    await downloads.upsertJob(
      DownloadJobsCompanion(
        id: Value(jobId),
        state: Value(DownloadState.queued.name),
        attempts: Value(attempts),
        errorCode: Value(error.code.name),
        errorMessage: Value(error.message),
        updatedAt: Value(now),
      ),
    );
    await _emit();
    await Future<void>.delayed(delay);
    if (!_disposed) {
      _pumpQueue();
    }
  }

  Future<void> _discardPath(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    try {
      final file = File(path);
      // Best-effort cleanup of one just-produced file, off the UI.
      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        await file.delete();
      }
    } on Exception {
      // Best effort: orphaned bytes are reclaimed on the next run.
    }
  }

  Quality _qualityFrom(String? label) {
    if (label != null) {
      for (final rung in Quality.values) {
        if (rung.name == label) {
          return rung;
        }
      }
    }
    return _settings.quality;
  }

  /// Basename of `path` without pulling in `package:path`.
  String _basenameOf(String path) {
    final normalized = path.replaceAll(r'\', '/');
    final slash = normalized.lastIndexOf('/');
    final base = slash < 0 ? normalized : normalized.substring(slash + 1);
    return base.isEmpty ? 'audio.m4a' : base;
  }

  Future<bool> _isUnmeteredSafe() async {
    try {
      return await _isUnmetered();
    } on Exception {
      return false;
    }
  }

  Future<void> _emit() async {
    if (_disposed || _changes.isClosed) {
      return;
    }
    try {
      _changes.add(await listAll());
    } on Exception {
      // Snapshot failures must never break queue progress.
    }
  }

  Future<void> _emitState(String jobId) async {
    if (_disposed || _changes.isClosed) {
      return;
    }
    try {
      final row = await downloads.getById(jobId);
      if (row != null) {
        _notifications.onStateChanged(DbMappers.toDownloadJob(row));
      }
      _changes.add(await listAll());
    } on Exception {
      // Snapshot failures must never break queue progress.
    }
  }
}
