import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';

/// Probes the media duration of [file] in milliseconds.
///
/// Returns null when duration is unavailable (ffprobe missing,
/// unparsable output) so verification can fall back to size-only.
/// The app injects [FfprobeDurationProbe.probe] by default.
typedef DurationProbe = Future<int?> Function(File file);

/// Size + duration verification for finished transfers (spec 12).
///
/// A download is accepted only when the file exists, is non-empty, and
/// — when a [DurationProbe] is available and the track knows its
/// length — the probed duration matches within [defaultTolerance].
/// Failures report [AppErrorCode.codec] (wrong bytes) or
/// [AppErrorCode.io] (missing/empty file).
abstract final class DownloadVerification {
  /// Acceptable duration drift when a probe is available.
  static const Duration defaultTolerance = Duration(seconds: 8);

  /// Verifies [file], returning its size in bytes on success.
  static Future<Result<int, AppError>> verify({
    required File file,
    int? expectedDurationMs,
    DurationProbe? probeDurationMs,
    Duration tolerance = defaultTolerance,
  }) async {
    late final bool exists;
    try {
      // Single stat per verification, off the UI isolate.
      // ignore: avoid_slow_async_io
      exists = await file.exists();
    } on Exception catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not check the downloaded file',
          details: 'downloads:verify-stat',
          cause: error,
        ),
      );
    }
    if (!exists) {
      return const Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Downloaded file is missing after transfer',
          details: 'downloads:verify-missing',
        ),
      );
    }
    late final int bytes;
    try {
      bytes = await file.length();
    } on Exception catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not read the downloaded file',
          details: 'downloads:verify-stat',
          cause: error,
        ),
      );
    }
    if (bytes <= 0) {
      return const Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Downloaded file is empty',
          details: 'downloads:verify-empty',
        ),
      );
    }
    if (probeDurationMs != null &&
        expectedDurationMs != null &&
        expectedDurationMs > 0) {
      final actualMs = await probeDurationMs(file);
      if (actualMs != null && actualMs > 0) {
        final driftMs = (actualMs - expectedDurationMs).abs();
        if (driftMs > tolerance.inMilliseconds) {
          return const Failure(
            AppError(
              code: AppErrorCode.codec,
              message: 'Downloaded audio length does not match the track',
              details: 'downloads:verify-duration',
            ),
          );
        }
      }
    }
    return Success(bytes);
  }
}

/// ffprobe-backed [DurationProbe] (`ffprobe` ships with the ffmpeg lane).
///
/// Runs `ffprobe -v error -show_entries format=duration -of
/// csv=p=0 FILE` and parses seconds → milliseconds. Any failure
/// (binary missing, timeout, unparsable output) yields null so the
/// caller falls back to size-only verification instead of failing.
abstract final class FfprobeDurationProbe {
  /// Probes [file] for its duration in milliseconds, if possible.
  static Future<int?> probe(
    File file, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final result = await Process.run('ffprobe', <String>[
        '-v',
        'error',
        '-show_entries',
        'format=duration',
        '-of',
        'csv=p=0',
        file.path,
      ]).timeout(timeout);
      if (result.exitCode != 0) {
        return null;
      }
      final raw = result.stdout is String
          ? (result.stdout as String).trim()
          : utf8
                .decode(result.stdout as List<int>, allowMalformed: true)
                .trim();
      final seconds = double.tryParse(raw);
      if (seconds == null || seconds <= 0) {
        return null;
      }
      return (seconds * 1000).round();
    } on Exception {
      return null;
    }
  }
}
