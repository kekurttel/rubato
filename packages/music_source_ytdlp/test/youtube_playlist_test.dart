import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class _FakeHttpClient extends Fake implements HttpClient {
  _FakeHttpClient(this._handler);

  final Future<HttpClientResponse> Function(Uri uri) _handler;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeHttpRequest(url, _handler);
}

class _FakeHttpRequest extends Fake implements HttpClientRequest {
  _FakeHttpRequest(this.uri, this._handler);

  @override
  final Uri uri;
  final Future<HttpClientResponse> Function(Uri uri) _handler;

  @override
  Future<HttpClientResponse> close() => _handler(uri);
}

class _FakeHttpResponse extends Fake implements HttpClientResponse {
  _FakeHttpResponse(this.statusCode, this.body);

  @override
  final int statusCode;
  final String body;

  @override
  Stream<T> transform<T>(StreamTransformer<List<int>, T> streamTransformer) {
    return Stream<List<int>>.fromIterable(<List<int>>[
      utf8.encode(body),
    ]).transform(streamTransformer);
  }
}

void main() {
  group('PipedSearchClient getPlaylist', () {
    test('fetches and parses playlist from mirror', () async {
      final fakeHttp = _FakeHttpClient((uri) async {
        expect(uri.path, '/playlists/PL123');
        const jsonBody = '''
{
  "name": "Piped Playlist",
  "relatedStreams": [
    {
      "url": "/watch?v=video_12345",
      "title": "Stream 2",
      "uploaderName": "Artist 2",
      "uploaderUrl": "/channel/chan2",
      "duration": 200,
      "thumbnail": "https://example.com/thumb2.jpg"
    }
  ]
}
''';
        return _FakeHttpResponse(200, jsonBody);
      });

      final client = PipedSearchClient(http: fakeHttp);
      final result = await client.getPlaylist('PL123');

      expect(result, isNotNull);
      expect(result!['title'], 'Piped Playlist');
      final items = result['items'] as List<Map<String, dynamic>>;
      expect(items.length, 1);
      expect(items.first['videoId'], 'video_12345');
      expect(items.first['title'], 'Stream 2');
      expect(items.first['uploader'], 'Artist 2');
      expect(items.first['channelId'], 'chan2');
      expect(items.first['durationSec'], 200);
    });

    test('returns null on empty playlist id', () async {
      final client = PipedSearchClient();
      final result = await client.getPlaylist('');
      expect(result, isNull);
    });
  });
}
