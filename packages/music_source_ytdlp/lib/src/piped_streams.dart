import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/piped_search.dart';
import 'package:flutter/foundation.dart';

/// One chosen Piped audio stream, carrying both URLs.
///
/// [proxyUrl] is the proxied media URL (preferred on-device: bypasses
/// the per-request googlevideo 403/bot-gate that direct URLs hit).
/// [directUrl] is the raw `audioStreams[]` URL for fallback/diagnosis.
/// [ext] is `mp4` or `webm` (compatible with the explode container
/// names, so the downloader's `mp4 → m4a` mapping keeps working).
final class PipedAudioStream {
  /// Creates a stream pick.
  const PipedAudioStream({
    required this.proxyUrl,
    required this.directUrl,
    required this.bitrateKbps,
    required this.ext,
    this.sourceTag = 'piped',
  });

  /// Proxied media URL (use first).
  final String proxyUrl;

  /// Raw `audioStreams[]` URL (fallback/diagnosis only).
  final String directUrl;

  /// Bitrate in kilobits per second (rounded, 0 when unknown).
  final int bitrateKbps;

  /// Container name (`mp4`, `webm`).
  final String ext;

  /// Runtime tag for diagnostics (always `piped`).
  final String sourceTag;
}

/// Audio streams over the Piped JSON API (no client binary needed).
///
/// Shares the [PipedSearchClient] transport: same mirror bases
/// ([pipedApiInstances]), same 8s per-instance timeout, same retry-once-
/// on-5xx with [PipedSearchClient.retryDelay] and
/// [PipedSearchClient.maxAttempts] total attempts, last-good-first
/// ordering with [PipedSearchClient.onWorkingBaseUrl] persistence,
/// `on Object` catches, and defensive JSON. Calls
/// `GET <base>/streams/<videoId>`, parses `audioStreams[]`
/// (url, bitrate, codec/mimeType), picks best audio at or under the
/// same bitrate-cap rungs as the explode picks (low128/med160/high256,
/// original uncapped), and rewrites the picked URL's host to the
/// winning base's proxy host (Piped convention: the response
/// `proxyUrl` when present, else derived from the base — never a
/// hardcoded single proxy).
final class PipedStreamsClient {
  /// Creates a client sharing [searchClient]'s last-good mirror.
  PipedStreamsClient({
    PipedSearchClient? searchClient,
    HttpClient? http,
    Duration? perInstanceTimeout,
  }) : _search = searchClient,
       _http = http,
       _ownsClient = http == null,
       perInstanceTimeout =
           perInstanceTimeout ??
           searchClient?.perInstanceTimeout ??
           const Duration(seconds: 8),
       _workingBaseUrl = searchClient?.workingBaseUrl;

  /// Shared search client (last-good mirror + persist hook).
  final PipedSearchClient? _search;

  /// Per-instance timeout before trying the next mirror.
  final Duration perInstanceTimeout;

  /// Short one-line cause of the last failed streams lookup (null on
  /// success); read immediately after a Failure (a later call
  /// overwrites it).
  String? lastFailure;

  final HttpClient? _http;

  /// Whether [_http] was created here (and must be closed by us).
  final bool _ownsClient;

  String? _workingBaseUrl;

  /// Last-good base (own win, else the shared search client's).
  String? get workingBaseUrl => _workingBaseUrl ?? _search?.workingBaseUrl;

  /// Short `Piped: ...` cause for [error] (≤90 chars, no newlines).
  static String shortFailure(AppError error) {
    final base = error.message.trim().replaceAll(RegExp(r'\s+'), ' ');
    final short = base.length > 82 ? '${base.substring(0, 82)}…' : base;
    if (short.startsWith('Piped')) {
      return short;
    }
    return 'Piped: $short';
  }

  /// Fetches the best proxied audio for [videoId] at [quality].
  ///
  /// Never throws: every per-mirror failure is caught as `Object`.
  /// Returns the proxy-first pick ([PipedAudioStream.proxyUrl]) with
  /// the raw URL kept as [PipedAudioStream.directUrl]. With
  /// [preferMp4], mp4 entries win (saved as `.m4a`, which MediaStore
  /// files as audio — `.webm` lands in the gallery's videos).
  Future<Result<PipedAudioStream, AppError>> streamsFor(
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
    final client = _http ?? HttpClient();
    try {
      final fastPath = workingBaseUrl;
      final bases = <String>[
        if (fastPath case final String working) working,
        ...pipedApiInstances.where((b) => b != fastPath),
      ];
      final byHost = <String, List<String>>{};
      void record(String base, String cause) {
        final name = PipedSearchClient.shortHost(base);
        (byHost[name] ??= <String>[]).add(cause);
      }

      var attempts = 0;
      outer:
      for (final base in bases) {
        final host = PipedSearchClient.shortHost(base);
        var retried = false;
        while (true) {
          if (attempts >= PipedSearchClient.maxAttempts) {
            break outer;
          }
          attempts++;
          try {
            final uri = Uri.parse('$base/streams/$videoId');
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
                debugPrint(
                  'AURORA_DIAG piped streams retry host=$host '
                  'code=${response.statusCode}',
                );
                await Future<void>.delayed(PipedSearchClient.retryDelay);
                continue;
              }
              record(base, cause);
              debugPrint(
                'AURORA_DIAG piped streams fail host=$host '
                'code=${response.statusCode}',
              );
              break;
            }
            final pick = _parsePick(body, quality, base, preferMp4);
            if (pick == null) {
              record(base, 'no audio');
              debugPrint(
                'AURORA_DIAG piped streams fail host=$host cause=no audio',
              );
              break;
            }
            _rememberWorking(base);
            lastFailure = null;
            final pickHost = Uri.tryParse(pick.proxyUrl)?.host ?? host;
            debugPrint(
              'AURORA_DIAG piped streams win host=$host pick=$pickHost '
              'kbps=${pick.bitrateKbps} ext=${pick.ext}',
            );
            return Success(pick);
          } on Object catch (error) {
            final cause = PipedSearchClient.shortCause(error);
            record(base, cause);
            debugPrint(
              'AURORA_DIAG piped streams fail host=$host cause=$cause',
            );
            break;
          }
        }
      }
      final joined = byHost.isEmpty
          ? 'unreachable'
          : PipedSearchClient.joinAttemptCauses(byHost);
      lastFailure = 'all mirrors unreachable ($joined)';
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Streams failed (no reachable mirror)',
          details: 'ytdlp:piped-streams-exit',
          cause: lastFailure,
        ),
      );
    } finally {
      if (_ownsClient) {
        client.close(force: true);
      }
    }
  }

  /// Remembers [base] as the fast-path mirror (own + shared search
  /// client persistence). Never throws.
  void _rememberWorking(String base) {
    _workingBaseUrl = base;
    final search = _search;
    if (search == null) {
      return;
    }
    try {
      search.noteWorkingBaseUrl(base);
    } on Object {
      // Persistence is best-effort; a failing hook must not break us.
      try {
        search.onWorkingBaseUrl?.call(base);
      } on Object {
        // Ignore: in-memory fast path already set.
      }
    }
  }

  /// Parses one Piped `/streams` body into the best pick (null when no
  /// usable `audioStreams[]` entry). Defensive: skips malformed rows.
  static PipedAudioStream? _parsePick(
    String body,
    Quality quality,
    String apiBase,
    bool preferMp4,
  ) {
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    final proxyUrlRaw = decoded['proxyUrl'];
    final responseProxy = proxyUrlRaw is String ? proxyUrlRaw.trim() : '';
    final items = decoded['audioStreams'];
    if (items is! List<Object?>) {
      return null;
    }
    final candidates = <_PipedCandidate>[];
    for (final item in items) {
      if (item is! Map<String, Object?>) {
        continue;
      }
      if (item['videoOnly'] == true) {
        continue;
      }
      final urlRaw = item['url'];
      if (urlRaw is! String || urlRaw.trim().isEmpty) {
        continue;
      }
      final directUrl = urlRaw.trim();
      if (!directUrl.startsWith('https://')) {
        continue;
      }
      final kbps = _kbpsFor(item);
      final ext = _extFor(item);
      final proxyUrl = _toProxyUrl(directUrl, apiBase, responseProxy);
      candidates.add(
        _PipedCandidate(
          proxyUrl: proxyUrl,
          directUrl: directUrl,
          bitrateKbps: kbps,
          ext: ext,
        ),
      );
    }
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((a, b) => a.bitrateKbps.compareTo(b.bitrateKbps));
    final ranked = preferMp4
        ? candidates.where((c) => c.ext == 'mp4').toList(growable: false)
        : candidates;
    final pool = ranked.isEmpty ? candidates : ranked;
    final capKbps = _bitrateCapKbps(quality);
    _PipedCandidate? pick;
    if (capKbps == null) {
      pick = pool.last;
    } else {
      for (final candidate in pool) {
        if (candidate.bitrateKbps <= 0 || candidate.bitrateKbps <= capKbps) {
          // Unknown-bitrate (0) entries sort first and stay eligible
          // so a cap never discards the only usable stream; the loop
          // still ends on the highest fitting bitrate.
          pick = candidate;
        } else {
          break;
        }
      }
      pick ??= pool.first;
    }
    return PipedAudioStream(
      proxyUrl: pick.proxyUrl,
      directUrl: pick.directUrl,
      bitrateKbps: pick.bitrateKbps,
      ext: pick.ext,
    );
  }

  /// Bitrate ceiling per rung in kbps (null = uncapped).
  ///
  /// Mirrors the explode picks (low ≤128k, medium ≤160k, high ≤256k).
  static int? _bitrateCapKbps(Quality quality) => switch (quality) {
    Quality.low => 128,
    Quality.medium => 160,
    Quality.high => 256,
    Quality.original => null,
  };

  /// Bitrate for one `audioStreams[]` entry in kbps (0 when unknown).
  ///
  /// Prefers the `quality` label (`128 kbps`) — the numeric `bitrate`
  /// unit varies by instance — falling back to `bitrate >= 1000`
  /// as bps (`/1000`) else as kbps directly.
  static int _kbpsFor(Map<String, Object?> entry) {
    final quality = entry['quality'];
    if (quality is String) {
      final match = RegExp(r'(\d+)\s*k').firstMatch(quality.toLowerCase());
      final parsed = match == null ? null : int.tryParse(match.group(1) ?? '');
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    final bitrate = entry['bitrate'];
    if (bitrate is num) {
      final value = bitrate.toDouble();
      if (value <= 0) {
        return 0;
      }
      if (value >= 1000) {
        return (value / 1000).round();
      }
      return value.round();
    }
    return 0;
  }

  /// Container for one entry (`mp4` or `webm`, explode-compatible).
  static String _extFor(Map<String, Object?> entry) {
    final mime = entry['mimeType'] is String
        ? (entry['mimeType']! as String).toLowerCase()
        : '';
    final format = entry['format'] is String
        ? (entry['format']! as String).toLowerCase()
        : '';
    final codec = entry['codec'] is String
        ? (entry['codec']! as String).toLowerCase()
        : '';
    if (mime.contains('webm') ||
        mime.contains('opus') ||
        format.contains('webm') ||
        format.contains('opus') ||
        codec.contains('opus')) {
      return 'webm';
    }
    return 'mp4';
  }

  /// Rewrites [directUrl]'s host to the proxy host (Piped convention).
  ///
  /// Prefers the `/streams` response `proxyUrl` (authoritative
  /// per-instance regional host); falls back to deriving from
  /// [apiBase] (`pipedapi.*` → `pipedproxy.*`,
  /// `api.piped.*` → `pipedproxy.*`). Never hardcodes one proxy.
  /// Returns [directUrl] unchanged when no proxy host is known.
  static String _toProxyUrl(
    String directUrl,
    String apiBase,
    String responseProxy,
  ) {
    final directUri = Uri.tryParse(directUrl);
    if (directUri == null || !directUri.hasAuthority) {
      return directUrl;
    }
    var proxyBase = responseProxy.trim();
    if (proxyBase.isEmpty) {
      final derived = _deriveProxyBase(apiBase);
      if (derived == null) {
        return directUrl;
      }
      proxyBase = derived;
    }
    if (proxyBase.endsWith('/')) {
      proxyBase = proxyBase.substring(0, proxyBase.length - 1);
    }
    final proxyUri = Uri.tryParse(proxyBase);
    if (proxyUri == null || !proxyUri.hasAuthority) {
      return directUrl;
    }
    if (directUri.host == proxyUri.host) {
      return directUrl;
    }
    try {
      final rewritten = Uri(
        scheme: proxyUri.scheme,
        host: proxyUri.host,
        port: proxyUri.hasPort ? proxyUri.port : null,
        path: directUri.path,
        query: directUri.query.isEmpty ? null : directUri.query,
        fragment: directUri.fragment.isEmpty ? null : directUri.fragment,
      );
      return rewritten.toString();
    } on Object {
      return directUrl;
    }
  }

  /// Derives the proxy base from an API [apiBase] (null when unknown).
  static String? _deriveProxyBase(String apiBase) {
    final uri = Uri.tryParse(apiBase);
    if (uri == null || !uri.hasAuthority) {
      return null;
    }
    final host = uri.host;
    final String proxyHost;
    if (host.startsWith('pipedapi.')) {
      proxyHost = host.replaceFirst('pipedapi.', 'pipedproxy.');
    } else if (host.startsWith('api.piped.')) {
      proxyHost = host.replaceFirst('api.piped.', 'pipedproxy.');
    } else if (host.startsWith('api.')) {
      proxyHost = host.replaceFirst('api.', 'proxy.');
    } else {
      return null;
    }
    return '${uri.scheme}://$proxyHost';
  }
}

/// One parsed `audioStreams[]` row before the cap pick.
final class _PipedCandidate {
  /// Creates a candidate.
  const _PipedCandidate({
    required this.proxyUrl,
    required this.directUrl,
    required this.bitrateKbps,
    required this.ext,
  });

  /// Rewritten proxy URL.
  final String proxyUrl;

  /// Raw entry URL.
  final String directUrl;

  /// Bitrate in kbps (0 when unknown).
  final int bitrateKbps;

  /// Container (`mp4`, `webm`).
  final String ext;
}
