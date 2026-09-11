import 'dart:async';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/explode_client.dart';
import 'package:aurora_music_source_ytdlp/src/newpipe_bridge.dart';
import 'package:aurora_music_source_ytdlp/src/piped_streams.dart';
import 'package:aurora_music_source_ytdlp/src/process_runner.dart';
import 'package:aurora_music_source_ytdlp/src/stream_resolver.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_binary.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_quality.dart';
import 'package:flutter/foundation.dart';

/// Matches yt-dlp `[download]  12.3%` progress lines.
final RegExp ytdlpProgressPattern = RegExp(r'\[download\]\s+(\d+(?:\.\d+)?)%');

/// One audio-only download request.
@immutable
final class YtdlpDownloadRequest {
  /// Creates a request for [videoId] into [outputDir].
  const YtdlpDownloadRequest({
    required this.videoId,
    required this.outputDir,
    this.quality = Quality.high,
  });

  /// Video id (Track.sourceTrackId).
  final String videoId;

  /// Destination directory (app-private files, never shared storage).
  final Directory outputDir;

  /// Quality rung (maps to the `-f` selector + m4a extraction).
  final Quality quality;
}

/// Verified outcome of one yt-dlp download.
@immutable
final class YtdlpDownloadResult {
  /// Creates a result.
  const YtdlpDownloadResult({
    required this.videoId,
    required this.filePath,
    required this.bytes,
  });

  /// Downloaded video id.
  final String videoId;

  /// Final extracted audio path (`<id>.m4a` under the output dir).
  final String filePath;

  /// File size in bytes (for quota + verification bookkeeping).
  final int bytes;
}

/// Audio-only downloader over the yt-dlp CLI.
///
/// Command shape (exact contract):
/// `yt-dlp -f FORMAT --extract-audio --audio-format m4a
/// --embed-thumbnail --add-metadata --no-playlist --no-warnings
/// -o APPDIR/%(id)s.%(ext)s WATCHURL`
///
/// Lawful-use: audio extraction only (`--extract-audio`, never video),
/// `--no-playlist` by default, no DRM bypass, no private clients. The
/// caller (DownloadManager) owns queueing, retries, verification, and
/// the `is_downloaded` flip; this class only runs one CLI call and
/// reports `[download] %` progress.
final class YtdlpDownloader {
  /// Creates a downloader over [binary] + [runner].
  YtdlpDownloader({
    YtdlpBinary? binary,
    YtdlpProcessRunner? runner,
    ExplodeClient? explode,
    NewPipeBridge? newpipe,
    this.pipedStreams,
    this.clock = const SystemClock(),
  }) : binary = binary ?? YtdlpBinary(),
       explode = explode ?? ExplodeClient(),
       newpipe = newpipe ?? NewPipeBridge(),
       _runner = runner ?? const SystemProcessRunner();

  /// Binary locator.
  final YtdlpBinary binary;

  /// Pure-Dart fallback used when no CLI binary resolves.
  final ExplodeClient explode;

  /// Native NewPipe runtime, preferred on Android; falls back to
  /// [explode] for the manifest pick.
  final NewPipeBridge newpipe;

  /// Piped proxy streams (first pick; shares `explode.pipedSearch`'s
  /// last-good mirror when null and constructed per call).
  final PipedStreamsClient? pipedStreams;

  /// Injectable clock (reserved for duration bookkeeping).
  final Clock clock;

  final YtdlpProcessRunner _runner;

  /// Output template for [dir] (`APPDIR/%(id)s.%(ext)s`).
  static String outputTemplate(Directory dir) =>
      '${dir.path}${Platform.pathSeparator}%(id)s.%(ext)s';

  /// Parses `0..1` progress from one yt-dlp output line, if any.
  static double? parseProgressPercent(String line) {
    final match = ytdlpProgressPattern.firstMatch(line);
    if (match == null) {
      return null;
    }
    final percent = double.tryParse(match.group(1) ?? '');
    if (percent == null) {
      return null;
    }
    return percent.clamp(0, 100).toDouble() / 100;
  }

  /// Builds the exact CLI args for [request] (test seam + audit log).
  static List<String> argsFor(YtdlpDownloadRequest request) => <String>[
    '-f',
    YtdlpQualityFormats.formatFor(request.quality),
    '--extract-audio',
    '--audio-format',
    YtdlpQualityFormats.audioFormatFor(request.quality),
    '--embed-thumbnail',
    '--add-metadata',
    '--no-playlist',
    '--no-warnings',
    '-o',
    outputTemplate(request.outputDir),
    YtdlpStreamResolver.videoUrl(request.videoId),
  ];

  /// Downloads [request], reporting `0..1` progress to [onProgress].
  ///
  /// CLI binary present → exact yt-dlp command (desktop). Otherwise the
  /// best audio URL is resolved via the NewPipe bridge first (Android)
  /// with the pure-Dart explode manifest as fallback, then fetched with
  /// [ExplodeClient.downloadUrl]; same result shape and progress
  /// contract either way.
  Future<Result<YtdlpDownloadResult, AppError>> download(
    YtdlpDownloadRequest request, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      await request.outputDir.create(recursive: true);
    } on Exception catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not create the download directory',
          details: 'ytdlp:output-dir',
          cause: error,
        ),
      );
    }
    if (await binary.resolve() != null) {
      return _downloadViaCli(request, onProgress: onProgress);
    }
    final audio = await _bestAudio(request.videoId, request.quality);
    switch (audio) {
      case Failure(:final error):
        return Failure(error);
      case Success(value: final stream):
        final ext = stream.containerName == 'mp4'
            ? 'm4a'
            : stream.containerName;
        final downloaded = await explode.downloadUrl(
          url: stream.url,
          videoId: request.videoId,
          outputDir: request.outputDir,
          fileExt: ext,
          onProgress: onProgress,
        );
        switch (downloaded) {
          case Success(value: final filePath):
            final file = File(filePath);
            final bytes = await file.length();
            return Success(
              YtdlpDownloadResult(
                videoId: request.videoId,
                filePath: filePath,
                bytes: bytes,
              ),
            );
          case Failure(:final error):
            return Failure(error);
        }
    }
  }

  /// Best audio via NewPipe first, then Piped proxy, then explode.
  ///
  /// All-runtime failures are combined into one runtime-tagged error
  /// (`NewPipe: … · Explode: … · Piped: …`) so the queue can surface
  /// the actual reason on the job row. The audio URL + ext go into the
  /// existing `explode.downloadUrl` unchanged (plain HttpClient GET +
  /// UA + Accept, follows redirects; no YouTube cookies).
  ///
  /// Downloads always prefer mp4/m4a streams (saved as `.m4a`, which
  /// MediaStore files as audio — `.webm` lands in the gallery's video
  /// collection); streaming keeps the best codec via the provider path.
  Future<Result<ExplodeAudioStream, AppError>> _bestAudio(
    String videoId,
    Quality quality,
  ) async {
    String? newpipeCause;
    var bridgeOk = false;
    try {
      bridgeOk = await newpipe.isAvailable;
    } on Object {
      bridgeOk = false;
    }
    if (bridgeOk) {
      final viaNewPipe = await newpipe.bestAudio(
        videoId,
        quality,
        preferMp4: true,
      );
      if (viaNewPipe != null) {
        return Success(viaNewPipe);
      }
      newpipeCause = newpipe.lastError ?? 'NewPipe failed';
    } else {
      newpipeCause = 'Bridge unavailable';
    }
    var pipedCause = 'Piped: failed';
    try {
      final streamsClient =
          pipedStreams ?? PipedStreamsClient(searchClient: explode.pipedSearch);
      final viaPiped = await streamsClient.streamsFor(
        videoId,
        quality,
        preferMp4: true,
      );
      switch (viaPiped) {
        case Success(value: final piped):
          final host = Uri.tryParse(piped.proxyUrl)?.host ?? '?';
          debugPrint(
            'AURORA_DIAG downloader pick=piped vid=$videoId host=$host '
            'kbps=${piped.bitrateKbps} ext=${piped.ext}',
          );
          return Success(
            ExplodeAudioStream(
              url: piped.proxyUrl,
              bitrateKbps: piped.bitrateKbps,
              containerName: piped.ext,
            ),
          );
        case Failure(:final error):
          pipedCause = PipedStreamsClient.shortFailure(error);
          debugPrint(
            'AURORA_DIAG downloader piped null vid=$videoId '
            'cause=$pipedCause fallback=explode',
          );
      }
    } on Object catch (error) {
      pipedCause = 'Piped: ${NewPipeBridge.shortCause(error)}';
      debugPrint(
        'AURORA_DIAG downloader piped error vid=$videoId cause=$pipedCause '
        'fallback=explode',
      );
    }
    final fb = await explode.bestAudio(
      videoId,
      quality,
      preferMp4: true,
    );
    switch (fb) {
      case Success():
        return fb;
      case Failure(:final error):
        return Failure(
          AppError(
            code: error.code,
            message:
                '${NewPipeBridge.describeFailure(
                  newpipeCause: newpipeCause,
                  explodeError: error,
                )} · $pipedCause',
            details: error.details,
            cause: error.cause,
          ),
        );
    }
  }

  /// CLI download (binary present).
  Future<Result<YtdlpDownloadResult, AppError>> _downloadViaCli(
    YtdlpDownloadRequest request, {
    void Function(double progress)? onProgress,
  }) async {
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
    late final YtdlpProcessResult run;
    try {
      run = await _runner.runStreaming(
        resolved,
        argsFor(request),
        onStdoutLine: (line) {
          final progress = parseProgressPercent(line);
          if (progress != null) {
            onProgress?.call(progress);
          }
        },
      );
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Download timed out',
          details: 'ytdlp:download-timeout',
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
    if (!run.isSuccess) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Download failed (exit ${run.exitCode})',
          details: 'ytdlp:download-exit',
        ),
      );
    }
    final file = await _findOutput(request);
    if (file == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'yt-dlp finished but the audio file is missing',
          details: 'ytdlp:output-missing',
        ),
      );
    }
    onProgress?.call(1);
    final bytes = await file.length();
    return Success(
      YtdlpDownloadResult(
        videoId: request.videoId,
        filePath: file.path,
        bytes: bytes,
      ),
    );
  }

  /// Locates `ID.m4a` (or any `ID.*` fallback) in the dir.
  Future<File?> _findOutput(YtdlpDownloadRequest request) async {
    final direct = File(
      '${request.outputDir.path}${Platform.pathSeparator}'
      '${request.videoId}.m4a',
    );
    // Post-download existence check runs once per job, off the UI.
    // ignore: avoid_slow_async_io
    if (await direct.exists()) {
      return direct;
    }
    try {
      await for (final entity in request.outputDir.list()) {
        if (entity is! File) {
          continue;
        }
        final name = entity.path.split(Platform.pathSeparator).last;
        if (name.startsWith('${request.videoId}.')) {
          return entity;
        }
      }
    } on Exception {
      return null;
    }
    return null;
  }
}
