import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/explode_client.dart';

/// Community Piped instances tried in order (first 2xx with hits wins).
///
/// Instances come and go (verified 2026-09-05 from dev machine: only
/// `api.piped.private.coffee` and `pipedapi.wireway.ch` answered 200
/// with video results; adminforge 301-redirects to a homepage,
/// ducks/kavin/leptons/moomoo/syncpundit 502, everything else
/// timed out or DNS-failed). Only verified-200 hosts are listed, the
/// healthiest first. The working host is remembered for the process
/// lifetime AND in SharedPreferences (wired in the app lane), so a
/// plain phone network skips dead mirrors on the next launch.
/// Search text goes to the instance, never to Google directly.
const List<String> pipedApiInstances = <String>[
  'https://api.piped.private.coffee',
  'https://pipedapi.wireway.ch',
];

/// Video search over the Piped JSON API (no client binary needed).
///
/// `youtube_explode_dart`'s search-page parser is broken against the
/// current YouTube markup, while its player-response path (streams,
/// details) still works — so search goes through Piped and streams
/// stay on explode. Only `filter=videos` results (`type=stream`,
/// `duration>0`; live/upcoming skipped).
final class PipedSearchClient {
  /// Creates a client.
  PipedSearchClient({
    HttpClient? http,
    this.perInstanceTimeout = const Duration(seconds: 8),
    String? initialWorkingBaseUrl,
    this.onWorkingBaseUrl,
  }) : _http = http,
       _ownsClient = http == null,
       _workingBaseUrl =
           (initialWorkingBaseUrl == null ||
               initialWorkingBaseUrl.trim().isEmpty)
           ? null
           : initialWorkingBaseUrl.trim();

  /// Per-instance timeout before trying the next mirror.
  final Duration perInstanceTimeout;

  /// Delay before retrying a mirror that answered HTTP 5xx (private.coffee
  /// 5xx is often transient overload, worth one immediate retry).
  static const Duration retryDelay = Duration(seconds: 2);

  /// Total HTTP-attempt budget across mirrors (retries included), so a
  /// search stays within ~30s (8s per attempt worst case).
  static const int maxAttempts = 4;

  /// Called (never throws) when a new working base URL is found, so
  /// the app lane can persist it in SharedPreferences without this
  /// package depending on it.
  final void Function(String baseUrl)? onWorkingBaseUrl;

  /// Last working base URL (process-local fast path, tried first).
  String? get workingBaseUrl => _workingBaseUrl;

  /// Records [base] as the working mirror (shared fast path for the
  /// `/streams` client too). Never throws.
  void noteWorkingBaseUrl(String base) => _rememberWorking(base);

  /// Short one-line cause of the last failed search (null on success
  /// or genuine empty); read immediately after a Failure for the
  /// provider chain (a later call overwrites it).
  String? lastFailure;

  final HttpClient? _http;

  /// Whether [_http] was created here (and must be closed by us).
  final bool _ownsClient;

  String? _workingBaseUrl;

  /// Shortens [error] to one line (≤80 chars, no newlines).
  static String shortCause(Object? error) {
    final oneLine = '${error ?? 'failed'}'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (oneLine.isEmpty) {
      return 'failed';
    }
    return oneLine.length > 80 ? '${oneLine.substring(0, 80)}…' : oneLine;
  }

  /// Whether [status] is worth one immediate retry (transient overload).
  static bool isRetryableStatus(int status) => status >= 500 && status <= 599;

  /// Short mirror name for causes (`private.coffee`, `wireway.ch`).
  static String shortHost(String base) {
    final host = Uri.tryParse(base)?.host ?? base;
    for (final prefix in <String>[
      'pipedapi.',
      'api.piped.',
      'invidious.',
      'inv.',
    ]) {
      if (host.startsWith(prefix)) {
        return host.substring(prefix.length);
      }
    }
    return host;
  }

  /// Joins per-host attempt causes (`private.coffee: HTTP 500×2,
  /// wireway.ch: HTTP 502`); repeated identical attempts collapse to `×N`.
  static String joinAttemptCauses(Map<String, List<String>> byHost) {
    final parts = <String>[];
    for (final entry in byHost.entries) {
      final counts = <String, int>{};
      final order = <String>[];
      for (final cause in entry.value) {
        if (!counts.containsKey(cause)) {
          order.add(cause);
        }
        counts[cause] = (counts[cause] ?? 0) + 1;
      }
      final causes = order.map(
        (cause) => counts[cause]! > 1 ? '$cause×${counts[cause]}' : cause,
      );
      parts.add('${entry.key}: ${causes.join(', ')}');
    }
    return parts.take(3).join(', ');
  }

  /// Searches [text] (min 2 chars), last-good mirror first.
  ///
  /// A 200 with hits wins immediately; a 200 with zero hits tries the
  /// next mirror (one broken mirror must not mask working ones). An HTTP
  /// 5xx is retried once on the same mirror after [retryDelay] (transient
  /// overload); every attempt is recorded per host, up to [maxAttempts]
  /// total attempts across mirrors. When every reachable mirror returns
  /// zero hits, that is a genuine empty result (Success with empty list,
  /// not a Failure). Only when no mirror is reachable is a
  /// `ytdlp:search-exit` Failure returned. Never throws: every per-mirror
  /// failure is caught as `Object` (an `Error` such as ArgumentError must
  /// not escape and kill the provider chain above).
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
        ...pipedApiInstances.where((b) => b != _workingBaseUrl),
      ];
      final byHost = <String, List<String>>{};
      void record(String base, String cause) {
        final host = shortHost(base);
        (byHost[host] ??= <String>[]).add(cause);
      }

      var sawReachable = false;
      var attempts = 0;
      outer:
      for (final base in bases) {
        var retried = false;
        while (true) {
          if (attempts >= maxAttempts) {
            break outer;
          }
          attempts++;
          try {
            final uri = Uri.parse(
              '$base/search?q=${Uri.encodeQueryComponent(query)}'
              '&filter=videos',
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
                  isRetryableStatus(response.statusCode) &&
                  attempts < maxAttempts) {
                retried = true;
                record(base, cause);
                await Future<void>.delayed(retryDelay);
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
            _rememberWorking(base);
            lastFailure = null;
            return Success(hits);
          } on Object catch (error) {
            record(base, shortCause(error));
            break;
          }
        }
      }
      if (sawReachable) {
        // Every reachable mirror returned zero usable hits: genuine
        // no-results (a nonsense query), not a network failure, so
        // the UI shows empty instead of an error banner.
        lastFailure = null;
        return const Success(<ExplodeVideoHit>[]);
      }
      final joined = byHost.isEmpty ? 'unreachable' : joinAttemptCauses(byHost);
      lastFailure = joined;
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Online search failed (no reachable mirror)',
          details: 'ytdlp:search-exit',
          cause: lastFailure,
        ),
      );
    } finally {
      if (_ownsClient) {
        client.close(force: true);
      }
    }
  }

  /// Fetches playlist metadata and items for [playlistId],
  /// last-good mirror first.
  ///
  /// Returns a map with `title` and `items` (List of `Map<String, dynamic>`),
  /// or null if no mirror succeeded. Never throws.
  Future<Map<String, dynamic>?> getPlaylist(String playlistId) async {
    final cleanId = playlistId.trim();
    if (cleanId.isEmpty) {
      return null;
    }
    final client = _http ?? HttpClient();
    try {
      final bases = <String>[
        if (_workingBaseUrl case final String working) working,
        ...pipedApiInstances.where((b) => b != _workingBaseUrl),
      ];
      for (final base in bases) {
        try {
          final uri = Uri.parse(
            '$base/playlists/${Uri.encodeComponent(cleanId)}',
          );
          final request = await client.getUrl(uri).timeout(perInstanceTimeout);
          final response = await request.close().timeout(perInstanceTimeout);
          final body = await response
              .transform(utf8.decoder)
              .join()
              .timeout(perInstanceTimeout);
          if (response.statusCode != 200) {
            continue;
          }
          final decoded = jsonDecode(body);
          if (decoded is! Map<String, Object?>) {
            continue;
          }
          final title = (decoded['name'] ?? decoded['title']) as String? ??
              'YouTube Playlist';
          final rawItems =
              (decoded['relatedStreams'] ?? decoded['items'])
                  as List<Object?>? ??
              const [];
          final items = <Map<String, dynamic>>[];
          for (final item in rawItems) {
            if (item is! Map<String, Object?>) {
              continue;
            }
            final videoId = _videoIdFromUrl(item['url']);
            if (videoId == null) {
              continue;
            }
            final itemTitle = item['title'];
            final uploader = item['uploaderName'] ?? item['uploader'];
            final uploaderUrl = item['uploaderUrl'];
            final duration = item['duration'];
            final durationSec = duration is num ? duration.toInt() : 0;
            final thumbnail = item['thumbnail'];
            items.add(<String, dynamic>{
              'videoId': videoId,
              'title': itemTitle is String && itemTitle.trim().isNotEmpty
                  ? itemTitle.trim()
                  : 'Untitled',
              'uploader': uploader is String ? uploader.trim() : '',
              'channelId': _channelIdFromUrl(uploaderUrl),
              'durationSec': durationSec,
              'thumbnailUrl': thumbnail is String && thumbnail.isNotEmpty
                  ? thumbnail
                  : 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
            });
          }
          _rememberWorking(base);
          lastFailure = null;
          return <String, dynamic>{
            'title': title,
            'items': items,
          };
        } on Object catch (_) {
          continue;
        }
      }
      return null;
    } finally {
      if (_ownsClient) {
        client.close(force: true);
      }
    }
  }

  /// Remembers [base] as the fast-path mirror (process-local + the
  /// app-lane SharedPreferences hook). Never throws.
  void _rememberWorking(String base) {
    final changed = _workingBaseUrl != base;
    _workingBaseUrl = base;
    if (!changed) {
      return;
    }
    try {
      onWorkingBaseUrl?.call(base);
    } on Object {
      // Persistence is best-effort; a failing hook must not break search.
    }
  }

  /// Parses one Piped `/search` body (defensive: skips malformed rows).
  static List<ExplodeVideoHit> _parseHits(String body, int limit) {
    final hits = <ExplodeVideoHit>[];
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      return hits;
    }
    if (decoded is! Map<String, Object?>) {
      return hits;
    }
    final items = decoded['items'];
    if (items is! List<Object?>) {
      return hits;
    }
    for (final item in items) {
      if (hits.length >= limit) {
        break;
      }
      if (item is! Map<String, Object?>) {
        continue;
      }
      if (item['type'] != 'stream') {
        continue;
      }
      final duration = item['duration'];
      if (duration is! num || duration <= 0) {
        continue;
      }
      final videoId = _videoIdFromUrl(item['url']);
      if (videoId == null) {
        continue;
      }
      final title = item['title'];
      final uploader = item['uploaderName'];
      final uploaderUrl = item['uploaderUrl'];
      // The proxy `thumbnail` host is dead; every video id has a
      // direct `hqdefault.jpg` (maxres often 404s), so synthesize it.
      hits.add(
        ExplodeVideoHit(
          videoId: videoId,
          title: title is String && title.trim().isNotEmpty
              ? title.trim()
              : 'Untitled',
          uploader: uploader is String ? uploader.trim() : '',
          channelId: _channelIdFromUrl(uploaderUrl),
          durationMs: (duration.toDouble() * 1000).round(),
          thumbnailUrl: 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg',
        ),
      );
    }
    return hits;
  }

  /// Extracts the video id from `/watch?v=<id>`.
  static String? _videoIdFromUrl(Object? url) {
    if (url is! String) {
      return null;
    }
    final match = RegExp('[?&]v=([A-Za-z0-9_-]{6,})').firstMatch(url);
    final id = match?.group(1);
    return id == null || id.isEmpty ? null : id;
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
