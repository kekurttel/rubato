import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/explode_client.dart';
import 'package:flutter/services.dart';

/// Native YouTube runtime over NewPipe Extractor (Android only).
///
/// Device-proven need: `youtube_explode_dart` manifests resolve
/// googlevideo URLs that return HTTP 403 on the phone (bot-gated
/// player responses), while search metadata works. The maintained fix
/// on Android is NewPipe Extractor (Java, no binary), exposed here
/// through the `aurora.player/youtube` channel served by
/// `YoutubeBridge` (see `MainActivity`). Pure Dart: no binary, no
/// bundled URLs — the query is always user-typed text, audio only.
///
/// All methods never throw: they return empty/null when the bridge is
/// unavailable or the platform call fails, recording a one-line cause
/// in [lastError] so the provider chain can report WHICH runtime
/// failed (instead of failing silently into a generic error).
final class NewPipeBridge {
  /// Creates a bridge over [channel] (inject a channel with a fake
  /// binary messenger in tests).
  NewPipeBridge({MethodChannel? channel, bool? isAvailable})
    : _channel = channel ?? const MethodChannel(channelName),
      _available = isAvailable ?? (channel != null ? true : null);

  /// Platform channel served by `YoutubeBridge` (`MainActivity`).
  static const String channelName = 'aurora.player/youtube';

  final MethodChannel _channel;

  /// Platform channel call budget (native extractor + Rhino JS can
  /// take 10s+ on first run; without this a stuck call hangs forever).
  static const Duration bridgeTimeout = Duration(seconds: 25);

  /// Tighter budget for stream-URL lookups: the player chain waits on
  /// these per tap, and a blocked network fails fast (exception)
  /// rather than hanging, so 15s only bites true hangs.
  static const Duration audioUrlTimeout = Duration(seconds: 15);

  bool? _available;

  /// One-line cause of the last `searchVideos`/`bestAudio` failure
  /// (`Bridge unavailable`, `NewPipe: timed out`, ...); null when the
  /// last call succeeded or none ran yet. Best-effort diagnostic only:
  /// read it immediately after a null/empty return (a later call may
  /// overwrite it).
  String? lastError;

  /// Combines a NewPipe cause with an explode failure into one short,
  /// user-facing line (e.g. `NewPipe: timed out · Explode: HTTP 403`).
  static String describeFailure({
    required String? newpipeCause,
    required AppError explodeError,
  }) {
    final left = newpipeCause == null || newpipeCause.trim().isEmpty
        ? 'NewPipe failed'
        : newpipeCause.trim();
    return '$left · ${ExplodeClient.shortFailure(explodeError)}';
  }

  /// Shortens [error] to one line (≤80 chars, no newlines).
  static String shortCause(Object error) {
    final oneLine = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return oneLine.length > 80 ? '${oneLine.substring(0, 80)}…' : oneLine;
  }

  /// Whether the native bridge can be reached.
  ///
  /// Probed once and cached: off-Android is always unavailable; on
  /// Android the channel is registered unconditionally by
  /// `MainActivity`, and any later [MissingPluginException] flips the
  /// cache to false. Never throws.
  Future<bool> get isAvailable async {
    final cached = _available;
    if (cached != null) {
      return cached;
    }
    if (Platform.isAndroid) {
      return _available = true;
    }
    return _available = false;
  }

  /// Searches videos for user-typed [text] (min 2 chars).
  ///
  /// Maps the native hit maps 1:1 onto [ExplodeVideoHit] (uploader,
  /// channel id, `durationSec * 1000`, thumbnail); entries with an
  /// empty video id are skipped. Returns empty when unavailable (see
  /// [lastError] for why).
  Future<List<ExplodeVideoHit>> searchVideos(
    String text, {
    required int limit,
  }) async {
    try {
      if (!await isAvailable) {
        lastError = 'Bridge unavailable';
        return const <ExplodeVideoHit>[];
      }
      if (text.trim().length < 2) {
        return const <ExplodeVideoHit>[];
      }
      final take = limit.clamp(1, 50);
      final raw = await _channel
          .invokeMethod<List<Object?>>(
            'search',
            <String, Object>{'query': text, 'limit': take},
          )
          .timeout(bridgeTimeout);
      if (raw == null) {
        lastError = 'NewPipe: empty response';
        return const <ExplodeVideoHit>[];
      }
      final hits = <ExplodeVideoHit>[];
      for (final item in raw) {
        if (item is! Map<Object?, Object?>) {
          continue;
        }
        final videoIdValue = item['videoId'];
        if (videoIdValue is! String || videoIdValue.trim().isEmpty) {
          continue;
        }
        final titleValue = item['title'];
        final title = titleValue is String ? titleValue.trim() : '';
        final uploaderValue = item['uploader'];
        final channelIdValue = item['channelId'];
        final durationValue = item['durationSec'];
        final thumbnailValue = item['thumbnailUrl'];
        final durationSec = durationValue is num ? durationValue.toInt() : 0;
        hits.add(
          ExplodeVideoHit(
            videoId: videoIdValue.trim(),
            title: title.isEmpty ? 'Untitled' : title,
            uploader: uploaderValue is String ? uploaderValue.trim() : '',
            channelId: channelIdValue is String ? channelIdValue.trim() : '',
            durationMs: durationSec <= 0 ? 0 : durationSec * 1000,
            thumbnailUrl: thumbnailValue is String ? thumbnailValue.trim() : '',
          ),
        );
        if (hits.length >= take) {
          break;
        }
      }
      lastError = null;
      return hits;
    } on MissingPluginException {
      _available = false;
      lastError = 'Bridge unavailable';
      return const <ExplodeVideoHit>[];
    } on TimeoutException {
      auroraLogger.warning('NewPipe bridge search timed out, falling back');
      lastError = 'NewPipe: timed out';
      return const <ExplodeVideoHit>[];
    } on Object catch (error) {
      // `on Object` (not `on Exception`): a mistyped native payload
      // throws TypeError (an Error), which must not escape and kill
      // the provider chain above.
      lastError = 'NewPipe: ${shortCause(error)}';
      return const <ExplodeVideoHit>[];
    }
  }

  /// Picks the best audio-only stream URL for [videoId] at [quality].
  ///
  /// Bitrate caps mirror [ExplodeClient] (low ≤128k, medium ≤160k,
  /// high ≤256k, original uncapped, sent as `0`). With [preferMp4]
  /// the native side prefers m4a/mp4 streams (downloads land as
  /// `.m4a`, keeping them out of the gallery's video collection).
  /// Returns null when unavailable or when no audio stream exists
  /// (see [lastError]).
  Future<ExplodeAudioStream?> bestAudio(
    String videoId,
    Quality quality, {
    bool preferMp4 = false,
  }) async {
    try {
      if (!await isAvailable) {
        lastError = 'Bridge unavailable';
        developer.log(
          'newpipe unavailable vid=$videoId',
          name: 'AURORA_DIAG',
        );
        return null;
      }
      if (videoId.isEmpty) {
        lastError = 'NewPipe: empty video id';
        return null;
      }
      developer.log(
        'newpipe audioUrl req vid=$videoId q=${quality.name}',
        name: 'AURORA_DIAG',
      );
      final raw = await _channel
          .invokeMethod<Map<Object?, Object?>>(
            'audioUrl',
            <String, Object>{
              'videoId': videoId,
              'maxBitrateKbps': _bitrateCapKbps(quality) ?? 0,
              'preferMp4': preferMp4,
            },
          )
          .timeout(audioUrlTimeout);
      if (raw == null) {
        lastError = 'NewPipe: empty response';
        developer.log(
          'newpipe audioUrl null vid=$videoId',
          name: 'AURORA_DIAG',
        );
        return null;
      }
      final urlValue = raw['url'];
      if (urlValue is! String || urlValue.isEmpty) {
        lastError = 'NewPipe: no audio stream';
        developer.log(
          'newpipe audioUrl empty vid=$videoId',
          name: 'AURORA_DIAG',
        );
        return null;
      }
      final host = Uri.tryParse(urlValue)?.host ?? '?';
      final bitrateValue = raw['bitrateKbps'];
      final extValue = raw['ext'];
      developer.log(
        'newpipe audioUrl ok vid=$videoId host=$host '
        'kbps=${bitrateValue is num ? bitrateValue.toInt() : 0} '
        'ext=$extValue len=${urlValue.length}',
        name: 'AURORA_DIAG',
      );
      lastError = null;
      return ExplodeAudioStream(
        url: urlValue,
        bitrateKbps: bitrateValue is num ? bitrateValue.toInt() : 0,
        containerName: extValue is String && extValue.trim().isNotEmpty
            ? extValue.trim()
            : 'm4a',
      );
    } on MissingPluginException {
      _available = false;
      lastError = 'Bridge unavailable';
      developer.log(
        'newpipe missingPlugin vid=$videoId',
        name: 'AURORA_DIAG',
      );
      return null;
    } on TimeoutException {
      auroraLogger.warning('NewPipe bridge audioUrl timed out, falling back');
      lastError = 'NewPipe: timed out';
      developer.log('newpipe timeout vid=$videoId', name: 'AURORA_DIAG');
      return null;
    } on Object catch (error) {
      // `on Object` (not `on Exception`): mistyped native payloads and
      // channel errors surface as Errors too; they must degrade to the
      // explode fallback, never kill the provider chain.
      lastError = 'NewPipe: ${shortCause(error)}';
      developer.log(
        'newpipe error vid=$videoId err=$lastError',
        name: 'AURORA_DIAG',
      );
      return null;
    }
  }

  /// Fetches playlist metadata and items for [url] (or playlist ID).
  ///
  /// Returns a map with `title` and `items` (List of `Map<String, dynamic>`),
  /// or null when unavailable or on error. Never throws.
  Future<Map<String, dynamic>?> playlist(String url) async {
    try {
      if (!await isAvailable) {
        lastError = 'Bridge unavailable';
        return null;
      }
      if (url.trim().isEmpty) {
        lastError = 'NewPipe: empty playlist url';
        return null;
      }
      final raw = await _channel
          .invokeMethod<Map<Object?, Object?>>(
            'playlist',
            <String, Object>{'url': url.trim()},
          )
          .timeout(bridgeTimeout);
      if (raw == null) {
        lastError = 'NewPipe: empty playlist response';
        return null;
      }
      final title = raw['title'] as String? ?? 'YouTube Playlist';
      final rawItems = raw['items'];
      final items = <Map<String, dynamic>>[];
      if (rawItems is List) {
        for (final item in rawItems) {
          if (item is Map) {
            items.add(Map<String, dynamic>.from(item));
          }
        }
      }
      lastError = null;
      return <String, dynamic>{
        'title': title,
        'items': items,
      };
    } on MissingPluginException {
      _available = false;
      lastError = 'Bridge unavailable';
      return null;
    } on TimeoutException {
      auroraLogger.warning('NewPipe bridge playlist timed out');
      lastError = 'NewPipe: timed out';
      return null;
    } on Object catch (error) {
      lastError = 'NewPipe: ${shortCause(error)}';
      return null;
    }
  }

  /// Pushes the user's YouTube session cookies into the native
  /// extractor (`YoutubeBridge`), so InnerTube/GoogleVideo requests go
  /// out authenticated (no bot-gating, private playlists resolve).
  /// Best-effort: off-Android there is no bridge. Never throws.
  Future<void> setAccountCookies(Map<String, String> cookies) async {
    try {
      await _channel
          .invokeMethod<void>(
            'setAccountCookies',
            <String, Object>{'cookies': Map<String, String>.from(cookies)},
          )
          .timeout(const Duration(seconds: 5));
      lastError = null;
    } on Object catch (error) {
      lastError = 'NewPipe: ${shortCause(error)}';
    }
  }

  /// Clears the session previously pushed with [setAccountCookies].
  /// Best-effort, never throws.
  Future<void> clearAccountCookies() async {
    try {
      await _channel
          .invokeMethod<void>('clearAccountCookies')
          .timeout(const Duration(seconds: 5));
      lastError = null;
    } on Object catch (error) {
      lastError = 'NewPipe: ${shortCause(error)}';
    }
  }

  /// Bitrate ceiling per rung in kbps (null = uncapped).
  static int? _bitrateCapKbps(Quality quality) => switch (quality) {
    Quality.low => 128,
    Quality.medium => 160,
    Quality.high => 256,
    Quality.original => null,
  };
}
