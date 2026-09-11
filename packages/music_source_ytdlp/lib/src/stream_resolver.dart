import 'dart:async';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/process_runner.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_binary.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_quality.dart';

/// Resolves playable handles for ytdlp tracks (stream or local file).
///
/// - Tracks with a verified on-disk file resolve to
///   [MediaHandleKind.localFile] (never expiring).
/// - Everything else resolves to [MediaHandleKind.authorizedStream]: the
///   direct best-audio URL from `yt-dlp -g`, expiring [streamTtl] after
///   resolution. Callers re-resolve once on 403/404/timeout via
///   [resolveFresh] and then surface the error (no silent retry loops).
final class YtdlpStreamResolver {
  /// Creates a resolver over [binary] + [runner].
  YtdlpStreamResolver({
    YtdlpBinary? binary,
    YtdlpProcessRunner? runner,
    this.clock = const SystemClock(),
  }) : binary = binary ?? YtdlpBinary(),
       _runner = runner ?? const SystemProcessRunner();

  /// Binary locator.
  final YtdlpBinary binary;

  /// Injectable clock for `expiresAt`.
  final Clock clock;

  final YtdlpProcessRunner _runner;

  /// Stream URL freshness window (spec: re-resolve once past expiry).
  static const Duration streamTtl = Duration(hours: 6);

  /// Watch URL for [videoId] (generic pattern, never stored content).
  static String videoUrl(String videoId) =>
      'https://www.youtube.com/watch?v=$videoId';

  /// Whether [handle] must be re-resolved at [now].
  static bool needsRefresh(MediaHandle? handle, DateTime now) {
    if (handle == null) {
      return true;
    }
    if (handle.isLocalFile) {
      return false;
    }
    return handle.isExpiredAt(now);
  }

  /// Returns [cached] unless it is missing, expired, or for another
  /// quality — then resolves once more and returns the fresh handle.
  Future<Result<MediaHandle, AppError>> resolveFresh(
    Track track,
    Quality quality, {
    MediaHandle? cached,
  }) async {
    final now = clock.nowUtc();
    if (cached != null &&
        !cached.isExpiredAt(now) &&
        cached.qualityLabel == quality.name) {
      return Success(cached);
    }
    return resolve(track, quality);
  }

  /// Resolves a playable handle for [track] at [quality].
  Future<Result<MediaHandle, AppError>> resolve(
    Track track,
    Quality quality,
  ) async {
    final localPath = track.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      // Single existence probe per resolve, off the UI isolate.
      // ignore: avoid_slow_async_io
      if (await File(localPath).exists()) {
        return Success(
          MediaHandle(
            kind: MediaHandleKind.localFile,
            uri: localPath,
            qualityLabel: quality.name,
          ),
        );
      }
    }
    final resolved = await binary.resolve();
    if (resolved == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'yt-dlp binary not found (install it or set a path)',
          details: 'ytdlp:missing-binary',
        ),
      );
    }
    late final YtdlpProcessResult probe;
    try {
      probe = await _runner.run(resolved, <String>[
        '-g',
        '-f',
        YtdlpQualityFormats.formatFor(quality),
        '--no-playlist',
        '--no-warnings',
        videoUrl(track.sourceTrackId),
      ]);
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Stream lookup timed out; retry once, then skip',
          details: 'ytdlp:resolve-timeout',
          cause: error,
        ),
      );
    } on Exception catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not launch the yt-dlp binary',
          details: 'ytdlp:launch',
          cause: error,
        ),
      );
    }
    if (!probe.isSuccess) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Stream lookup failed (exit ${probe.exitCode})',
          details: 'ytdlp:resolve-exit',
        ),
      );
    }
    final directUrl = probe.stdout
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('https://'))
        .firstOrNull;
    if (directUrl == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'Provider returned no playable audio URL',
          details: 'ytdlp:no-direct-url',
        ),
      );
    }
    return Success(
      MediaHandle(
        kind: MediaHandleKind.authorizedStream,
        uri: directUrl,
        expiresAt: clock.nowUtc().add(streamTtl),
        mimeType: YtdlpQualityFormats.mimeTypeFor(quality),
        qualityLabel: quality.name,
      ),
    );
  }
}
