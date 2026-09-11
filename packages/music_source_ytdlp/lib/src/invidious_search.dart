import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/explode_client.dart';
import 'package:aurora_music_source_ytdlp/src/piped_search.dart';

/// Community Invidious instances tried in order (first 2xx with hits wins).
///
/// Last-resort search runtime after the Piped mirrors and the NewPipe
/// bridge (verified 2026-09-05 from dev machine: only materialio.us and
/// ducks.party answered 200 with JSON video results; nerdvpn 401,
/// nadeko `Endpoint disabled`, duti/tiekoetter blocked 403, 0011/melmac/
/// tux/puffyan and ~25 others timed out or DNS-failed, reallyaweso 502, yewtu.be
/// served bot-check HTML, protokolla CAPTCHA HTML, projectsegfau shut
/// down). Only verified-200 hosts are listed. No auth, no new
/// dependencies. Search text goes to the instance, never to Google.
const List<String> invidiousApiInstances = <String>[
  'https://invidious.materialio.us',
  'https://invidious.ducks.party',
];

/// Video search over the Invidious JSON API (last resort, no auth).
///
/// `GET <base>/api/v1/search?q=<q>&type=video` with the same
/// mirror-loop / timeout / retry / cause-chain pattern as
/// [PipedSearchClient]: last-good mirror first, HTTP 5xx retried once
/// after [PipedSearchClient.retryDelay], [PipedSearchClient.maxAttempts]
/// total attempts across mirrors, live/upcoming skipped. Hits map onto
/// [ExplodeVideoHit] (`videoId`/`title`/`author`/`lengthSeconds`) with
/// synthesized `i.ytimg.com` thumbnails, so provider keys, DB, and
/// artwork caches are untouched.
final class InvidiousSearchClient {
  /// Creates a client.
  InvidiousSearchClient({
    HttpClient? http,
    this.perInstanceTimeout = const Duration(seconds: 8),
    String? initialWorkingBaseUrl,
  }) : _http = http,
       _ownsClient = http == null,
       _workingBaseUrl =
           (initialWorkingBaseUrl == null ||
               initialWorkingBaseUrl.trim().isEmpty)
           ? null
           : initialWorkingBaseUrl.trim();

  /// Per-instance timeout before trying the next mirror.
  final Duration perInstanceTimeout;

  /// Last working base URL (process-local fast path, tried first).
  ///
  /// Deliberately NOT persisted next to the Piped mirror: an Invidious
  /// base saved under the Piped key would poison the Piped fast path.
  String? get workingBaseUrl => _workingBaseUrl;

  /// Short per-mirror causes of the last failed search
  /// (`materialio.us: HTTP 500×2, ducks.party: timeout`; null on success
  /// or genuine empty); read immediately after a Failure for the
  /// provider chain (a later call overwrites it).
  String? lastFailure;

  final HttpClient? _http;

  /// Whether [_http] was created here (and must be closed by us).
  final bool _ownsClient;

  String? _workingBaseUrl;

  /// Searches [text] (min 2 chars), last-good mirror first.
  ///
  /// A 200 with hits wins immediately; a 200 with zero hits tries the
  /// next mirror. An HTTP 5xx is retried once on the same mirror after
  /// [PipedSearchClient.retryDelay]; every attempt is recorded per host,
  /// up to [PipedSearchClient.maxAttempts] total attempts. When every
  /// reachable mirror returns zero hits, that is a genuine empty result
  /// (Success with empty list, not a Failure). Only when no mirror is
  /// reachable is a `ytdlp:invidious-search-exit` Failure returned.
  /// Never throws: every per-mirror failure is caught as `Object`.
  Future<Result<List<ExplodeVideoHit>, AppError>> searchVideos(
    String text, {
    required int limit,
  }) async {
    final query = text.trim();
    if (query.length < 2) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'Online search needs at least 2 characters',
          details: 'ytdlp:query-too-short',
        ),
      );
    }
    final client = _http ?? HttpClient();
    try {
      final bases = <String>[
        if (_workingBaseUrl case final String working) working,
        ...invidiousApiInstances.where((b) => b != _workingBaseUrl),
      ];
      final byHost = <String, List<String>>{};
      void record(String base, String cause) {
        final host = PipedSearchClient.shortHost(base);
        (byHost[host] ??= <String>[]).add(cause);
      }

      var sawReachable = false;
      var attempts = 0;
      outer:
      for (final base in bases) {
        var retried = false;
        while (true) {
          if (attempts >= PipedSearchClient.maxAttempts) {
            break outer;
          }
          attempts++;
          try {
            final uri = Uri.parse(
              '$base/api/v1/search?q=${Uri.encodeQueryComponent(query)}'
              '&type=video',
            );
            final request = await client
                .getUrl(uri)
                .timeout(
                  perInstanceTimeout,
                );
            final response = await request.close().timeout(
              perInstanceTimeout,
            );
            final body = await response
                .transform(utf8.decoder)
                .join()
                .timeout(perInstanceTimeout);
            if (response.statusCode != 200) {
              final cause = 'HTTP ${response.statusCode}';
              if (!retried &&
                  PipedSearchClient.isRetryableStatus(
                    response.statusCode,
                  ) &&
                  attempts < PipedSearchClient.maxAttempts) {
                retried = true;
                record(base, cause);
                await Future<void>.delayed(PipedSearchClient.retryDelay);
                continue;
              }
              record(base, cause);
              break;
            }
            sawReachable = true;
            final hits = _parseHits(body, limit);
            if (hits.isEmpty) {
              record(base, 'empty');
              break;
            }
            _workingBaseUrl = base;
            lastFailure = null;
            return Success(hits);
          } on Object catch (error) {
            record(base, PipedSearchClient.shortCause(error));
            break;
          }
        }
      }
      if (sawReachable) {
        // Every reachable mirror returned zero usable hits: genuine
        // no-results, not a network failure.
        lastFailure = null;
        return const Success(<ExplodeVideoHit>[]);
      }
      final joined = byHost.isEmpty
          ? 'unreachable'
          : PipedSearchClient.joinAttemptCauses(byHost);
      lastFailure = joined;
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Online search failed (no reachable Invidious mirror)',
          details: 'ytdlp:invidious-search-exit',
          cause: lastFailure,
        ),
      );
    } finally {
      if (_ownsClient) {
        client.close(force: true);
      }
    }
  }

  /// Parses one Invidious `/api/v1/search` body (defensive: the endpoint
  /// returns a bare JSON list; bot-check/CAPTCHA HTML pages fail closed
  /// to zero hits so the next mirror is tried).
  static List<ExplodeVideoHit> _parseHits(String body, int limit) {
    final hits = <ExplodeVideoHit>[];
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      return hits;
    }
    if (decoded is! List<Object?>) {
      return hits;
    }
    for (final item in decoded) {
      if (hits.length >= limit) {
        break;
      }
      if (item is! Map<String, Object?>) {
        continue;
      }
      if (item['type'] != 'video') {
        continue;
      }
      final videoId = item['videoId'];
      if (videoId is! String || videoId.trim().isEmpty) {
        continue;
      }
      if (item['liveNow'] == true || item['isUpcoming'] == true) {
        continue;
      }
      final id = videoId.trim();
      final title = item['title'];
      final author = item['author'];
      final authorId = item['authorId'];
      final authorUrl = item['authorUrl'];
      final length = item['lengthSeconds'];
      final durationMs = length is num && length > 0
          ? (length.toDouble() * 1000).round()
          : 0;
      hits.add(
        ExplodeVideoHit(
          videoId: id,
          title: title is String && title.trim().isNotEmpty
              ? title.trim()
              : 'Untitled',
          uploader: author is String ? author.trim() : '',
          channelId: authorId is String && authorId.trim().isNotEmpty
              ? authorId.trim()
              : _channelIdFromUrl(authorUrl),
          durationMs: durationMs,
          thumbnailUrl: 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
        ),
      );
    }
    return hits;
  }

  /// Extracts the channel id from `/channel/<id>` (empty when absent).
  static String _channelIdFromUrl(Object? url) {
    if (url is! String) {
      return '';
    }
    final match = RegExp('/channel/([A-Za-z0-9_-]+)').firstMatch(url);
    return match?.group(1) ?? '';
  }
}
