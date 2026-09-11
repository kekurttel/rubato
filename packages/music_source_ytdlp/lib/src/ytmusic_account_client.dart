import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// One YouTube Music track from an authenticated browse response.
final class YtMusicTrack {
  /// Creates the track.
  const YtMusicTrack({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
  });

  /// 11-char video id.
  final String videoId;

  /// Track title.
  final String title;

  /// Joined artist/subtitle line.
  final String artist;

  /// Best thumbnail URL (may be empty).
  final String thumbnailUrl;
}

/// One personalized shelf from the account's YouTube Music home.
final class YtMusicShelf {
  /// Creates the shelf.
  const YtMusicShelf({required this.title, required this.tracks});

  /// Shelf header (e.g. "Because you listened to …").
  final String title;

  /// Tracks in shelf order.
  final List<YtMusicTrack> tracks;
}

/// One playlist from the account's YouTube Music library.
final class YtMusicPlaylist {
  /// Creates the playlist entry.
  const YtMusicPlaylist({
    required this.playlistId,
    required this.title,
    required this.subtitle,
    required this.thumbnailUrl,
  });

  /// Playlist id WITHOUT the `VL` browse prefix.
  final String playlistId;

  /// Playlist title.
  final String title;

  /// Count/owner line.
  final String subtitle;

  /// Best thumbnail URL (may be empty).
  final String thumbnailUrl;
}

/// Authenticated YouTube Music InnerTube client (pure Dart).
///
/// Uses the signed-in session pushed into [YtMusicAccountClient.accountCookies]
/// (InnerTune pattern): `Cookie` + `SAPISIDHASH` authorization + the
/// `WEB_REMIX` client, so the account's real home feed
/// (`FEmusic_home`) and library (`FEmusic_library_landing`) resolve
/// instead of the public catalog. Every method never throws: offline,
/// expired sessions, and schema drift surface as empty results so
/// callers fall back to the public charts.
final class YtMusicAccountClient {
  /// Creates the client (an `HttpClient` override helps tests).
  YtMusicAccountClient({this._http});

  final HttpClient? _http;

  /// Session cookies (`SID`, `SAPISID`, …) pushed from the app layer
  /// after login; empty = signed out.
  Map<String, String> accountCookies = const <String, String>{};

  /// Whether a usable session is present.
  bool get isSignedIn {
    final cookies = accountCookies;
    return (cookies['SID'] ?? '').isNotEmpty &&
        (cookies['SAPISID'] ?? '').isNotEmpty;
  }

  /// Per-request budget (InnerTube browse is one round trip).
  static const Duration timeout = Duration(seconds: 15);

  static const String _origin = 'https://music.youtube.com';

  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8 Build/AP2A.240905.003) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/126.0.0.0 Mobile Safari/537.36';

  /// Personalized home shelves for the signed-in account
  /// (`FEmusic_home`). Empty when signed out, offline, or expired.
  Future<List<YtMusicShelf>> homeShelves() async {
    final json = await _browse(const <String, Object?>{
      'browseId': 'FEmusic_home',
    });
    if (json == null) {
      return const <YtMusicShelf>[];
    }
    try {
      final shelves = parseHomeShelves(json);
      debugPrint('AURORA_DIAG ytm home shelves=${shelves.length}');
      return shelves;
    } on Object {
      return const <YtMusicShelf>[];
    }
  }

  /// Parses a `browse` response into home shelves (exposed for tests).
  @visibleForTesting
  static List<YtMusicShelf> parseHomeShelves(Map<String, Object?> json) {
    final out = <YtMusicShelf>[];
    for (final section in _sections(json)) {
      if (section is! Map<String, Object?>) {
        continue;
      }
      final shelf = _asMap(section['musicCarouselShelfRenderer']);
      if (shelf == null) {
        continue;
      }
      final title = _runsText(
        _asMap(
          _asMap(
            _asMap(shelf['header'])
                ?['musicCarouselShelfBasicHeaderRenderer'],
          )?['title'],
        )?['runs'],
      );
      final tracks = <YtMusicTrack>[];
      for (final item in _asList(shelf['contents'])) {
        final track = _trackFromItem(item);
        if (track != null) {
          tracks.add(track);
        }
      }
      if (tracks.isNotEmpty) {
        out.add(
          YtMusicShelf(
            title: title.isEmpty ? 'For you' : title,
            tracks: tracks,
          ),
        );
      }
    }
    return out;
  }

  /// Playlists in the account's library
  /// (`FEmusic_library_landing`). Empty when signed out/offline.
  Future<List<YtMusicPlaylist>> libraryPlaylists() async {
    final json = await _browse(const <String, Object?>{
      'browseId': 'FEmusic_library_landing',
    });
    if (json == null) {
      return const <YtMusicPlaylist>[];
    }
    try {
      final playlists = parseLibraryPlaylists(json);
      debugPrint(
        'AURORA_DIAG ytm library playlists=${playlists.length} '
        'skeleton=${_skeletonOf(json)}',
      );
      return playlists;
    } on Object {
      return const <YtMusicPlaylist>[];
    }
  }

  /// Structural skeleton of a browse body for logcat (renderer keys +
  /// list lengths only — never titles, ids, or any string values).
  static String _skeletonOf(Map<String, Object?> json) {
    try {
      final out = StringBuffer();
      void visit(Object? node, int depth) {
        if (depth > 7) {
          return;
        }
        if (node is List) {
          out.write('[${node.length}]');
          if (node.isNotEmpty) {
            visit(node.first, depth + 1);
          }
          return;
        }
        if (node is! Map<String, Object?>) {
          return;
        }
        var first = true;
        for (final key in node.keys) {
          if (!_isRendererKey(key)) {
            continue;
          }
          if (!first) {
            out.write(',');
          }
          first = false;
          out.write(key);
          visit(node[key], depth + 1);
        }
      }

      visit(json, 0);
      final skeleton = out.toString();
      return skeleton.isEmpty
          ? 'no-renderers'
          : skeleton.substring(0, skeleton.length.clamp(0, 400));
    } on Object {
      return 'skeleton-error';
    }
  }

  static bool _isRendererKey(String key) =>
      key.endsWith('Renderer') ||
      key.endsWith('ShelfRenderer') ||
      key == 'contents' ||
      key == 'content' ||
      key == 'tabs' ||
      key == 'items' ||
      key == 'sections';

  /// Parses a `browse` response into library playlists (for tests).
  @visibleForTesting
  static List<YtMusicPlaylist> parseLibraryPlaylists(
    Map<String, Object?> json,
  ) {
    final out = <YtMusicPlaylist>[];
    final seen = <String>{};
    for (final section in _sections(json)) {
      for (final item in _walkItems(section)) {
        final playlist = _playlistFromItem(item);
        if (playlist != null && seen.add(playlist.playlistId)) {
          out.add(playlist);
        }
      }
    }
    return out;
  }

  /// Raw authenticated `browse` call. Null on any failure. The
  /// response is JSON even for signed-out/expired sessions
  /// (`LOGIN_REQUIRED`), never the HTML bot page. Diagnostics go
  /// through `debugPrint` (release-visible) with endpoint + status
  /// only — never URLs, cookies, or bodies.
  Future<Map<String, Object?>?> _browse(Map<String, Object?> body) async {
    final endpoint = body['browseId'];
    if (!isSignedIn) {
      debugPrint('AURORA_DIAG ytm browse endpoint=$endpoint signedIn=false');
      return null;
    }
    HttpClient? owned;
    try {
      final client = _http ?? (owned = HttpClient());
      final request = await client
          .postUrl(
            Uri.parse(
              'https://music.youtube.com/youtubei/v1/browse?prettyPrint=false',
            ),
          )
          .timeout(timeout);
      request.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set(HttpHeaders.userAgentHeader, _userAgent)
        ..set('Origin', _origin)
        ..set('X-Youtube-Client-Name', '67')
        ..set('X-Youtube-Client-Version', _clientVersion)
        ..set(HttpHeaders.cookieHeader, _cookieHeader());
      final auth = _sapisidHash();
      if (auth != null) {
        request.headers.set(HttpHeaders.authorizationHeader, auth);
      }
      request.write(
        jsonEncode(<String, Object?>{
          'context': <String, Object?>{
            'client': <String, Object?>{
              'clientName': 'WEB_REMIX',
              'clientVersion': _clientVersion,
              'hl': 'en',
              'gl': 'US',
            },
          },
          ...body,
        }),
      );
      final response = await request.close().timeout(timeout);
      final text = await response.transform(utf8.decoder).join().timeout(
        timeout,
      );
      debugPrint(
        'AURORA_DIAG ytm browse endpoint=$endpoint '
        'status=${response.statusCode} bytes=${text.length}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, Object?>) {
        debugPrint(
          'AURORA_DIAG ytm browse endpoint=$endpoint non-map body',
        );
        return null;
      }
      // Signed-out/expired sessions answer JSON with an error object;
      // surface that shape in one word so logcat tells auth apart
      // from schema drift.
      final playability = _playabilityOf(decoded);
      debugPrint(
        'AURORA_DIAG ytm browse endpoint=$endpoint playability=$playability',
      );
      return decoded;
    } on Object catch (error) {
      debugPrint(
        'AURORA_DIAG ytm browse endpoint=$endpoint '
        'error=${error.runtimeType}',
      );
      return null;
    } finally {
      owned?.close(force: true);
    }
  }

  /// One-word auth/shape signal from a browse body (`ok`,
  /// `login-required`, `error:<code>`, `unknown`).
  static String _playabilityOf(Map<String, Object?> json) {
    try {
      final text = jsonEncode(json);
      if (text.contains('LOGIN_REQUIRED')) {
        return 'login-required';
      }
      if (text.contains('"error"') && !text.contains('sectionListRenderer')) {
        return 'error-body';
      }
      return 'ok';
    } on Object {
      return 'unknown';
    }
  }

  static const String _clientVersion = '1.20250616.01.00';

  String _cookieHeader() {
    final cookies = accountCookies;
    return cookies.entries
        .where((e) => e.key.isNotEmpty && e.value.isNotEmpty)
        .map((e) => '${e.key}=${e.value}')
        .join('; ');
  }

  String? _sapisidHash() {
    final sapisid = accountCookies['SAPISID'] ?? '';
    if (sapisid.isEmpty) {
      return null;
    }
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final digest = sha1.convert(utf8.encode('$ts $sapisid $_origin'));
    return 'SAPISIDHASH ${ts}_$digest';
  }

  /// Sections of the first tab: `sectionListRenderer.contents`, or —
  /// when the tab content IS a shelf/grid renderer directly — that
  /// renderer alone. Empty on any shape drift. Never throws.
  static List<Object?> _sections(Map<String, Object?> root) {
    try {
      final contents = _asMap(root['contents']);
      final single = _asMap(
        contents?['singleColumnBrowseResultsRenderer'],
      );
      final tabs = _asList(single?['tabs']);
      if (tabs.isEmpty) {
        return const <Object?>[];
      }
      final out = <Object?>[];
      // Do not assume the first tab is the library tab. YouTube Music
      // changes tab ordering/surface selection across account types and
      // clients; playlist rows may live in a later tab.
      for (final tab in tabs) {
        final tabRenderer = _asMap(_asMap(tab)?['tabRenderer']);
        final content = _asMap(tabRenderer?['content']);
        if (content == null) {
          continue;
        }
        final sections = _asMap(content['sectionListRenderer']);
        if (sections != null) {
          out.addAll(_asList(sections['contents']));
          continue;
        }
        // Tab content is a shelf/grid itself (some library surfaces).
        for (final key in const [
          'musicCarouselShelfRenderer',
          'musicShelfRenderer',
          'musicPlaylistShelfRenderer',
          'musicLibraryPersonalPlaylistsShelfRenderer',
          'gridRenderer',
        ]) {
          if (content[key] is Map) {
            out.add(content);
            break;
          }
        }
      }
      return out;
    } on Object {
      return const <Object?>[];
    }
  }

  /// All renderers under [node] (shelf contents + grid items).
  static List<Object?> _walkItems(Object? node) {
    final out = <Object?>[];
    void visit(Object? current) {
      if (current is List) {
        current.forEach(visit);
        return;
      }
      if (current is! Map<String, Object?>) {
        return;
      }
      for (final key in const [
        'musicCarouselShelfRenderer',
        'musicShelfRenderer',
        'musicPlaylistShelfRenderer',
        'musicLibraryPersonalPlaylistsShelfRenderer',
        'gridRenderer',
        'musicTwoColumnBrowseResultsRenderer',
      ]) {
        final inner = _asMap(current[key]);
        if (inner != null) {
          _asList(inner['contents']).forEach(out.add);
          _asList(inner['items']).forEach(out.add);
        }
      }
      for (final value in current.values) {
        if (value is Map || value is List) {
          visit(value);
        }
      }
    }

    visit(node);
    return out;
  }

  static YtMusicTrack? _trackFromItem(Object? item) {
    if (item is! Map<String, Object?>) {
      return null;
    }
    Map<String, Object?>? endpoint;
    Map<String, Object?>? flex;
    for (final key in const [
      'musicTwoColumnItemRenderer',
      'musicResponsiveListItemRenderer',
    ]) {
      final renderer = _asMap(item[key]);
      if (renderer == null) {
        continue;
      }
      endpoint =
          _asMap(_asMap(renderer['navigationEndpoint'])?['watchEndpoint']) ??
          endpoint;
      final columns = _asList(renderer['flexColumns']);
      if (flex == null && columns.isNotEmpty) {
        flex = _asMap(columns.first);
      }
      // `musicTwoColumnItemRenderer` rows carry `title`/`subtitle`
      // runs directly (no flex columns); responsive rows use flex.
      final directTitle = _runsText(_asMap(renderer['title'])?['runs']);
      final directSubtitle = _runsText(
        _asMap(renderer['subtitle'])?['runs'],
      );
      final thumbs = _bestThumbnail(renderer['thumbnail']);
      final flexTitle = _runsText(
        _asMap(
          _asMap(flex?['musicResponsiveListItemFlexColumnRenderer'])?['text'],
        )?['runs'],
      );
      final title = directTitle.isNotEmpty ? directTitle : flexTitle;
      final flexSubtitle = _subtitleText(renderer);
      final subtitle = directSubtitle.isNotEmpty
          ? directSubtitle
          : flexSubtitle;
      final videoId = _asMap(endpoint)?['videoId'];
      if (videoId is String && videoId.isNotEmpty) {
        return YtMusicTrack(
          videoId: videoId,
          title: title.isEmpty ? 'Untitled' : title,
          artist: subtitle,
          thumbnailUrl: thumbs,
        );
      }
    }
    // Shelf items sometimes nest the endpoint one level deeper.
    for (final value in item.values) {
      final nested = _trackFromItem(value);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  static YtMusicPlaylist? _playlistFromItem(Object? item) {
    if (item is! Map<String, Object?>) {
      return null;
    }
    for (final key in const [
      'musicTwoColumnItemRenderer',
      'musicTwoRowItemRenderer',
      'musicResponsiveListItemRenderer',
    ]) {
      final renderer = _asMap(item[key]);
      if (renderer == null) {
        continue;
      }
      final endpoint = _asMap(renderer['navigationEndpoint']);
      // Library rows navigate via `browseEndpoint` (`VL<id>`); some
      // rows (Liked, mixes) use `watchPlaylistEndpoint` with the raw
      // playlist id instead.
      final browse = _asMap(endpoint?['browseEndpoint']);
      final browseId = browse?['browseId'];
      final watch = _asMap(endpoint?['watchPlaylistEndpoint']);
      final watchId = watch?['playlistId'];
      final String id;
      if (browseId is String && browseId.startsWith('VL')) {
        id = browseId.substring(2);
      } else if (watchId is String && watchId.isNotEmpty) {
        id = watchId;
      } else {
        continue;
      }
      if (id.isEmpty) {
        continue;
      }
      final directTitle = _runsText(
        _asMap(renderer['title'])?['runs'],
      );
      final columns = _asList(renderer['flexColumns']);
      final first = _asMap(
        columns.isNotEmpty ? columns.first : null,
      );
      final flexTitle = _runsText(
        _asMap(
          _asMap(
            first?['musicResponsiveListItemFlexColumnRenderer'],
          )?['text'],
        )?['runs'],
      );
      final title = directTitle.isNotEmpty ? directTitle : flexTitle;
      final directSubtitle = _runsText(
        _asMap(renderer['subtitle'])?['runs'],
      );
      final flexSubtitle = _subtitleText(renderer);
      var thumbnailUrl = _bestThumbnail(
        renderer['thumbnail'] ?? renderer['thumbnailRenderer'],
      );
      // Library playlist rows do not always expose a playlist thumbnail.
      // They often still contain the first track's video id, which gives
      // us a stable YouTube thumbnail fallback without another request.
      if (thumbnailUrl.isEmpty) {
        final firstVideoId = _firstVideoId(renderer);
        if (firstVideoId != null) {
          thumbnailUrl =
              'https://i.ytimg.com/vi/$firstVideoId/hqdefault.jpg';
        }
      }
      return YtMusicPlaylist(
        playlistId: id,
        title: title.isEmpty ? 'Playlist' : title,
        subtitle: directSubtitle.isNotEmpty ? directSubtitle : flexSubtitle,
        thumbnailUrl: thumbnailUrl,
      );
    }
    return null;
  }

  static String? _firstVideoId(Object? node) {
    String? found;
    void visit(Object? current) {
      if (found != null) {
        return;
      }
      if (current is List) {
        for (final item in current) {
          visit(item);
          if (found != null) {
            return;
          }
        }
        return;
      }
      if (current is! Map<String, Object?>) {
        return;
      }
      final direct = current['videoId'];
      if (direct is String && direct.length == 11) {
        found = direct;
        return;
      }
      for (final value in current.values) {
        if (value is Map || value is List) {
          visit(value);
          if (found != null) {
            return;
          }
        }
      }
    }

    visit(node);
    return found;
  }

  static String _subtitleText(Map<String, Object?> renderer) {
    final columns = _asList(renderer['flexColumns']);
    final parts = <String>[];
    for (final column in columns.skip(1).take(2)) {
      final text = _runsText(
        _asMap(
          _asMap(
            _asMap(column)?['musicResponsiveListItemFlexColumnRenderer'],
          )?['text'],
        )?['runs'],
      );
      if (text.isNotEmpty) {
        parts.add(text);
      }
    }
    return parts.join(' • ');
  }

  /// Joins a `runs` list (`[{text: …}]`) into plain text.
  static String _runsText(Object? runs) {
    if (runs is! List) {
      return '';
    }
    return runs
        .whereType<Map<String, Object?>>()
        .map((r) => r['text'])
        .whereType<String>()
        .join();
  }

  static String _bestThumbnail(Object? node) {
    String? best;
    var bestWidth = 0;
    void visit(Object? current) {
      if (current is List) {
        current.forEach(visit);
        return;
      }
      if (current is! Map<String, Object?>) {
        return;
      }
      final url = current['url'];
      if (url is String && url.isNotEmpty) {
        final width = current['width'];
        final w = width is num ? width.toInt() : 0;
        if (best == null || w >= bestWidth) {
          best = url.startsWith('https:') ? url : 'https:$url';
          bestWidth = w;
        }
      }
      current.values.forEach(visit);
    }

    visit(node);
    return best ?? '';
  }

  static Map<String, Object?>? _asMap(Object? value) =>
      value is Map<String, Object?> ? value : null;

  static List<Object?> _asList(Object? value) =>
      value is List ? value : const <Object?>[];
}
