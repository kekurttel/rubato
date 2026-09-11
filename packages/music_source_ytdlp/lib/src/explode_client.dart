import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/piped_search.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// One online video mapped to provider-agnostic fields.
///
/// The provider turns these into [Track]/[Artist] rows with
/// `providerId=ytdlp` and `sourceTrackId=<videoId>` (same keys as the
/// CLI path, so UI, DB, and artwork caches are untouched).
final class ExplodeVideoHit {
  /// Creates a hit.
  const ExplodeVideoHit({
    required this.videoId,
    required this.title,
    required this.uploader,
    required this.channelId,
    required this.durationMs,
    required this.thumbnailUrl,
  });

  /// YouTube video id (Track.sourceTrackId).
  final String videoId;

  /// Display title.
  final String title;

  /// Channel/uploader display name (may be empty).
  final String uploader;

  /// Channel id (may be empty; slug fallback applies).
  final String channelId;

  /// Duration in milliseconds (0 when unknown).
  final int durationMs;

  /// Highest-resolution thumbnail URL.
  final String thumbnailUrl;
}

/// One chosen audio-only stream.
final class ExplodeAudioStream {
  /// Creates a stream pick.
  const ExplodeAudioStream({
    required this.url,
    required this.bitrateKbps,
    required this.containerName,
  });

  /// Direct HTTPS URL (expiring; callers attach the TTL).
  final String url;

  /// Bitrate in kilobits per second (rounded).
  final int bitrateKbps;

  /// Container name (`mp4`, `webm`, ...).
  final String containerName;
}

/// Pure-Dart online client (no `yt-dlp` binary required).
///
/// Used on Android where no CLI binary exists; desktop keeps the CLI
/// path when a binary resolves. Audio-only, single-video lookups:
/// no playlists, no video streams, no DRM bypass, no bundled URLs —
/// the query is always user-typed text.
///
/// A fresh [YoutubeExplode] is opened per call and closed in `finally`
/// (no static singleton leaking HTTP clients).
final class ExplodeClient {
  /// Creates a client.
  ExplodeClient({
    this.clock = const SystemClock(),
    this.timeout = const Duration(seconds: 15),
    PipedSearchClient? pipedSearch,
  }) : _pipedSearch = pipedSearch ?? PipedSearchClient();

  /// Injectable clock (reserved for future TTL bookkeeping).
  final Clock clock;

  /// Per-request timeout for search/detail/manifest calls.
  final Duration timeout;

  final PipedSearchClient _pipedSearch;

  /// Piped-backed search client (exposed so the provider chain can
  /// report per-mirror causes and the app lane can persist the
  /// last-good mirror without new dependencies).
  PipedSearchClient get pipedSearch => _pipedSearch;

  /// Account session cookies pushed from the app layer after login
  /// (empty = signed out). Attached as a `Cookie` header to
  /// `*.googlevideo.com` download requests only — never to proxies —
  /// so fallback fetches go out authenticated like the native lane.
  Map<String, String> accountCookies = const <String, String>{};

  /// First HTTP 4xx/5xx status found in [text] (best-effort: the
  /// underlying client wraps transport errors in exception text, so
  /// the status is recovered by pattern instead of being dropped).
  static String? httpStatusOf(Object? text) {
    if (text == null) {
      return null;
    }
    return RegExp(r'\b([45]\d\d)\b').firstMatch(text.toString())?.group(1);
  }

  /// Short user-facing cause for [error], runtime-tagged with any
  /// recovered HTTP status (e.g. `Explode: lookup failed (HTTP 403)`).
  static String shortFailure(AppError error) {
    final status =
        httpStatusOf(error.cause) ??
        httpStatusOf(error.message) ??
        httpStatusOf(error.details);
    final base = error.message.trim();
    final withStatus = status != null && !base.contains(status)
        ? '$base (HTTP $status)'
        : base;
    final capped = withStatus.length > 90
        ? '${withStatus.substring(0, 90)}…'
        : withStatus;
    return 'Explode: $capped';
  }

  /// Searches videos for user-typed [text] (min 2 chars).
  ///
  /// Search runs over Piped mirrors: `youtube_explode_dart`'s
  /// search-page parser is broken against current YouTube markup
  /// while its stream path works, so only streams/details use it.
  Future<Result<List<ExplodeVideoHit>, AppError>> searchVideos(
    String text, {
    required int limit,
  }) => _pipedSearch.searchVideos(text, limit: limit);

  /// Fetches one video's detail (null when unavailable).
  Future<Result<ExplodeVideoHit?, AppError>> getVideo(String videoId) async {
    if (videoId.isEmpty) {
      return const Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Online track not found',
          details: 'ytdlp:empty-id',
        ),
      );
    }
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(videoId).timeout(timeout);
      return Success(_hitFromVideo(video));
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Track lookup timed out',
          details: 'ytdlp:detail-timeout',
          cause: error,
        ),
      );
    } on Object catch (error) {
      // `on Object`: the client throws ArgumentError (an Error) for
      // malformed ids; it must map to notFound, never escape the call.
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Online track not found',
          details: videoId,
          cause: error,
        ),
      );
    } finally {
      yt.close();
    }
  }

  /// Picks the best audio-only stream URL for [quality].
  ///
  /// Bitrate caps mirror the CLI selectors: low ≤128k, medium ≤160k,
  /// high ≤256k, original uncapped. Falls back to the lowest stream
  /// when nothing fits under the cap. With [preferMp4], mp4-container
  /// candidates win (saved as `.m4a`, which MediaStore files as audio —
  /// `.webm` lands in the gallery's video collection); falls back to
  /// any container when no mp4 candidate exists.
  Future<Result<ExplodeAudioStream, AppError>> bestAudio(
    String videoId,
    Quality quality, {
    bool preferMp4 = false,
  }) async {
    if (videoId.isEmpty) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'Provider returned no playable audio URL',
          details: 'ytdlp:no-direct-url',
        ),
      );
    }
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streams
          .getManifest(videoId)
          .timeout(timeout);
      final candidates = manifest.audioOnly.toList(growable: false);
      if (candidates.isEmpty) {
        return const Failure(
          AppError(
            code: AppErrorCode.provider,
            message: 'Provider returned no playable audio URL',
            details: 'ytdlp:no-direct-url',
          ),
        );
      }
      candidates.sort(
        (a, b) => a.bitrate.bitsPerSecond.compareTo(b.bitrate.bitsPerSecond),
      );
      final ranked = preferMp4
          ? candidates
                .where((c) => c.container.name == 'mp4')
                .toList(growable: false)
          : candidates;
      final pool = ranked.isEmpty ? candidates : ranked;
      final capKbps = _bitrateCapKbps(quality);
      AudioOnlyStreamInfo? pick;
      if (capKbps == null) {
        pick = pool.last;
      } else {
        for (final candidate in pool) {
          if (candidate.bitrate.bitsPerSecond <= capKbps * 1024) {
            pick = candidate;
          } else {
            break;
          }
        }
        pick ??= pool.first;
      }
      return Success(
        ExplodeAudioStream(
          url: pick.url.toString(),
          bitrateKbps: (pick.bitrate.bitsPerSecond / 1024).round(),
          containerName: pick.container.name,
        ),
      );
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Stream lookup timed out; retry once, then skip',
          details: 'ytdlp:resolve-timeout',
          cause: error,
        ),
      );
    } on Object catch (error) {
      // `on Object`: transport Errors must stay a typed Failure so the
      // provider chain (NewPipe → explode → CLI) survives them; the
      // status is recovered into the cause chain for `shortFailure`.
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Stream lookup failed',
          details: 'ytdlp:resolve-exit',
          cause: error,
        ),
      );
    } finally {
      yt.close();
    }
  }

  /// Browser User-Agent sent with googlevideo requests.
  ///
  /// Mirrors the player's `defaultStreamHeaders` in `aurora_playback`
  /// (kept as a local const: this package must not depend on playback,
  /// spec section 1). googlevideo 403s unknown UAs on some networks.
  static const String browserUserAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8 Build/AP2A.240905.003) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/126.0.0.0 Mobile Safari/537.36';

  /// Downloads the best audio for [quality] into [outputDir].
  ///
  /// File name is `<videoId>.<ext>` (`mp4` audio maps to `m4a`;
  /// the CLI `_findOutput` fallback also matches `<id>.*`).
  /// Progress reports `0..1` from the manifest-declared size.
  Future<Result<String, AppError>> downloadAudio({
    required String videoId,
    required Quality quality,
    required Directory outputDir,
    void Function(double progress)? onProgress,
  }) async {
    try {
      await outputDir.create(recursive: true);
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
    final yt = YoutubeExplode();
    late final String directUrl;
    late final String fileExt;
    late final int totalBytes;
    try {
      final manifest = await yt.videos.streams
          .getManifest(videoId)
          .timeout(timeout);
      final candidates = manifest.audioOnly.toList(growable: false);
      if (candidates.isEmpty) {
        return const Failure(
          AppError(
            code: AppErrorCode.provider,
            message: 'Provider returned no playable audio URL',
            details: 'ytdlp:no-direct-url',
          ),
        );
      }
      candidates.sort(
        (a, b) => a.bitrate.bitsPerSecond.compareTo(b.bitrate.bitsPerSecond),
      );
      final capKbps = _bitrateCapKbps(quality);
      AudioOnlyStreamInfo? pick;
      if (capKbps == null) {
        pick = candidates.last;
      } else {
        for (final candidate in candidates) {
          if (candidate.bitrate.bitsPerSecond <= capKbps * 1024) {
            pick = candidate;
          } else {
            break;
          }
        }
        // Nothing fits under the cap: take the lowest (same fallback
        // as [bestAudio]; the previous code kept the highest here).
        pick ??= candidates.first;
      }
      fileExt = pick.container.name == 'mp4' ? 'm4a' : pick.container.name;
      directUrl = pick.url.toString();
      totalBytes = pick.size.totalBytes;
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Download timed out',
          details: 'ytdlp:download-timeout',
          cause: error,
        ),
      );
    } on Object catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Download failed',
          details: 'ytdlp:download-exit',
          cause: error,
        ),
      );
    } finally {
      yt.close();
    }
    return downloadUrl(
      url: directUrl,
      videoId: videoId,
      outputDir: outputDir,
      fileExt: fileExt,
      totalBytes: totalBytes,
      onProgress: onProgress,
    );
  }

  /// Downloads [url] directly into [outputDir] as `<videoId>.<fileExt>`.
  ///
  /// Shared HTTP fetcher behind [downloadAudio] (manifest URL) and the
  /// NewPipe runtime (direct audio URL): plain GET with a browser
  /// User-Agent, `0..1` progress from [totalBytes] (or the response
  /// `Content-Length` when unknown), and the same `ytdlp:download-*`
  /// error codes either way.
  Future<Result<String, AppError>> downloadUrl({
    required String url,
    required String videoId,
    required Directory outputDir,
    String fileExt = 'm4a',
    int totalBytes = 0,
    void Function(double progress)? onProgress,
  }) async {
    if (url.isEmpty || videoId.isEmpty) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'Provider returned no playable audio URL',
          details: 'ytdlp:no-direct-url',
        ),
      );
    }
    try {
      await outputDir.create(recursive: true);
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
    final file = File(
      '${outputDir.path}${Platform.pathSeparator}$videoId.$fileExt',
    );
    // Plain GET (not the explode stream helper) so the request carries
    // a browser User-Agent; googlevideo 403s unknown UAs on some
    // networks. Progress still reports 0..1 from the manifest size.
    final client = HttpClient();
    final diagHost = Uri.tryParse(url)?.host ?? '?';
    developer.log(
      'dartHttp GET req vid=$videoId host=$diagHost '
      'expect=$totalBytes ext=$fileExt',
      name: 'AURORA_DIAG',
    );
    try {
      final request = await client.getUrl(Uri.parse(url)).timeout(timeout);
      request.headers.set(HttpHeaders.userAgentHeader, browserUserAgent);
      request.headers.set(HttpHeaders.acceptHeader, '*/*');
      final cookies = accountCookies;
      final host = (Uri.tryParse(url)?.host ?? '').toLowerCase();
      if (cookies.isNotEmpty &&
          (host == 'googlevideo.com' ||
              host.endsWith('.googlevideo.com'))) {
        request.headers.set(
          HttpHeaders.cookieHeader,
          cookies.entries
              .where((e) => e.key.isNotEmpty && e.value.isNotEmpty)
              .map((e) => '${e.key}=${e.value}')
              .join('; '),
        );
      }
      final response = await request.close().timeout(timeout);
      developer.log(
        'dartHttp GET status vid=$videoId host=$diagHost '
        'code=${response.statusCode} len=${response.contentLength}',
        name: 'AURORA_DIAG',
      );
      if (response.statusCode != HttpStatus.ok) {
        return Failure(
          AppError(
            code: AppErrorCode.network,
            message: 'Download failed (HTTP ${response.statusCode})',
            details: 'ytdlp:download-http',
          ),
        );
      }
      final effectiveTotal = totalBytes > 0
          ? totalBytes
          : response.contentLength;
      var received = 0;
      final sink = file.openWrite();
      try {
        await for (final chunk in response.timeout(timeout)) {
          sink.add(chunk);
          received += chunk.length;
          if (effectiveTotal > 0) {
            onProgress?.call(
              (received / effectiveTotal).clamp(0, 1).toDouble(),
            );
          }
        }
      } finally {
        await sink.flush();
        await sink.close();
      }
      onProgress?.call(1);
      developer.log(
        'dartHttp GET done vid=$videoId bytes=$received '
        'pathLen=${file.path.length}',
        name: 'AURORA_DIAG',
      );
      return Success(file.path);
    } on TimeoutException catch (error) {
      developer.log('dartHttp timeout vid=$videoId', name: 'AURORA_DIAG');
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Download timed out',
          details: 'ytdlp:download-timeout',
          cause: error,
        ),
      );
    } on Object catch (error) {
      final msg = error.toString();
      final shown = msg.length > 120 ? msg.substring(0, 120) : msg;
      developer.log(
        'dartHttp error vid=$videoId err=$shown',
        name: 'AURORA_DIAG',
      );
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Download failed',
          details: 'ytdlp:download-exit',
          cause: error,
        ),
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Bitrate ceiling per rung in kbps (null = uncapped).
  static int? _bitrateCapKbps(Quality quality) => switch (quality) {
    Quality.low => 128,
    Quality.medium => 160,
    Quality.high => 256,
    Quality.original => null,
  };

  /// Maps one video to a hit (null for live/unsuitable entries).
  static ExplodeVideoHit? _hitFromVideo(Video video) {
    if (video.isLive) {
      return null;
    }
    final videoId = video.id.value;
    if (videoId.isEmpty) {
      return null;
    }
    final title = video.title.trim().isEmpty ? 'Untitled' : video.title.trim();
    return ExplodeVideoHit(
      videoId: videoId,
      title: title,
      uploader: video.author.trim(),
      channelId: video.channelId.value,
      durationMs: video.duration == null
          ? 0
          : video.duration!.inMilliseconds,
      thumbnailUrl: video.thumbnails.maxResUrl,
    );
  }
}
