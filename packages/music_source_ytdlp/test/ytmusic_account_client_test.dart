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
  Future<HttpClientRequest> postUrl(Uri url) async =>
      _FakeHttpRequest(url, _handler);
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  final Map<String, String> values = <String, String>{};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name] = value.toString();
  }
}

class _FakeHttpRequest extends Fake implements HttpClientRequest {
  _FakeHttpRequest(this.uri, this._handler);

  @override
  final Uri uri;
  final Future<HttpClientResponse> Function(Uri uri) _handler;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  void write(Object? obj) {}

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

const Map<String, Object?> _homeFixture = <String, Object?>{
  'contents': <String, Object?>{
    'singleColumnBrowseResultsRenderer': <String, Object?>{
      'tabs': <Object?>[
        <String, Object?>{
          'tabRenderer': <String, Object?>{
            'content': <String, Object?>{
              'sectionListRenderer': <String, Object?>{
                'contents': <Object?>[
                  <String, Object?>{
                    'musicCarouselShelfRenderer': <String, Object?>{
                      'header': <String, Object?>{
                        'musicCarouselShelfBasicHeaderRenderer':
                            <String, Object?>{
                              'title': <String, Object?>{
                                'runs': <Object?>[
                                  <String, Object?>{
                                    'text': 'Because you listened to X',
                                  },
                                ],
                              },
                            },
                      },
                      'contents': <Object?>[
                        <String, Object?>{
                          'musicResponsiveListItemRenderer': <String, Object?>{
                            'flexColumns': <Object?>[
                              <String, Object?>{
                                'musicResponsiveListItemFlexColumnRenderer':
                                    <String, Object?>{
                                      'text': <String, Object?>{
                                        'runs': <Object?>[
                                          <String, Object?>{
                                            'text': 'Song A',
                                          },
                                        ],
                                      },
                                    },
                              },
                              <String, Object?>{
                                'musicResponsiveListItemFlexColumnRenderer':
                                    <String, Object?>{
                                      'text': <String, Object?>{
                                        'runs': <Object?>[
                                          <String, Object?>{
                                            'text': 'Artist A',
                                          },
                                        ],
                                      },
                                    },
                              },
                            ],
                            'thumbnail': <String, Object?>{
                              'musicThumbnailRenderer': <String, Object?>{
                                'thumbnail': <String, Object?>{
                                  'thumbnails': <Object?>[
                                    <String, Object?>{
                                      'url':
                                          'https://i.ytimg.com/vi/AAA111BBBBB/hqdefault.jpg',
                                      'width': 60,
                                    },
                                  ],
                                },
                              },
                            },
                            'navigationEndpoint': <String, Object?>{
                              'watchEndpoint': <String, Object?>{
                                'videoId': 'AAA111BBBBB',
                              },
                            },
                          },
                        },
                      ],
                    },
                  },
                ],
              },
            },
          },
        },
      ],
    },
  },
};

const Map<String, Object?> _libraryFixture = <String, Object?>{
  'contents': <String, Object?>{
    'singleColumnBrowseResultsRenderer': <String, Object?>{
      'tabs': <Object?>[
        <String, Object?>{
          'tabRenderer': <String, Object?>{
            'content': <String, Object?>{
              'sectionListRenderer': <String, Object?>{
                'contents': <Object?>[
                  <String, Object?>{
                    'musicShelfRenderer': <String, Object?>{
                      'contents': <Object?>[
                        <String, Object?>{
                          'musicResponsiveListItemRenderer': <String, Object?>{
                            'flexColumns': <Object?>[
                              <String, Object?>{
                                'musicResponsiveListItemFlexColumnRenderer':
                                    <String, Object?>{
                                      'text': <String, Object?>{
                                        'runs': <Object?>[
                                          <String, Object?>{
                                            'text': 'My Mix',
                                          },
                                        ],
                                      },
                                    },
                              },
                            ],
                            'navigationEndpoint': <String, Object?>{
                              'browseEndpoint': <String, Object?>{
                                'browseId': 'VLPLmyplaylistid01',
                              },
                            },
                          },
                        },
                      ],
                    },
                  },
                ],
              },
            },
          },
        },
      ],
    },
  },
};

YtMusicAccountClient _signedInClient(
  Future<HttpClientResponse> Function(Uri uri) handler,
) {
  return YtMusicAccountClient(http: _FakeHttpClient(handler))
    ..accountCookies = const <String, String>{
      'SID': 'sid-value',
      'SAPISID': 'sapisid-value',
    };
}

void main() {
  group('YtMusicAccountClient', () {
    test('homeShelves parses shelves, tracks, thumbnails', () async {
      final client = _signedInClient(
        (uri) async => _FakeHttpResponse(200, jsonEncode(_homeFixture)),
      );
      final shelves = await client.homeShelves();
      expect(shelves.length, 1);
      expect(shelves.first.title, 'Because you listened to X');
      expect(shelves.first.tracks.length, 1);
      final track = shelves.first.tracks.first;
      expect(track.videoId, 'AAA111BBBBB');
      expect(track.title, 'Song A');
      expect(track.artist, 'Artist A');
      expect(
        track.thumbnailUrl,
        'https://i.ytimg.com/vi/AAA111BBBBB/hqdefault.jpg',
      );
    });

    test('libraryPlaylists strips the VL prefix', () async {
      final client = _signedInClient(
        (uri) async => _FakeHttpResponse(200, jsonEncode(_libraryFixture)),
      );
      final playlists = await client.libraryPlaylists();
      expect(playlists.length, 1);
      expect(playlists.first.playlistId, 'PLmyplaylistid01');
      expect(playlists.first.title, 'My Mix');
    });

    test('signed-out client returns empty without network', () async {
      var called = false;
      final client = YtMusicAccountClient(
        http: _FakeHttpClient((uri) async {
          called = true;
          return _FakeHttpResponse(200, '{}');
        }),
      );
      expect(client.isSignedIn, isFalse);
      expect(await client.homeShelves(), isEmpty);
      expect(await client.libraryPlaylists(), isEmpty);
      expect(called, isFalse);
    });

    test('non-200 browse degrades to empty', () async {
      final client = _signedInClient(
        (uri) async => _FakeHttpResponse(401, '{"error": {}}'),
      );
      expect(await client.homeShelves(), isEmpty);
      expect(await client.libraryPlaylists(), isEmpty);
    });

    test('garbage payload degrades to empty', () async {
      final client = _signedInClient(
        (uri) async => _FakeHttpResponse(200, 'not json{{{'),
      );
      expect(await client.homeShelves(), isEmpty);
    });

    test('direct shelf tab content resolves as one section', () async {
      const body = <String, Object?>{
        'contents': <String, Object?>{
          'singleColumnBrowseResultsRenderer': <String, Object?>{
            'tabs': <Object?>[
              <String, Object?>{
                'tabRenderer': <String, Object?>{
                  'content': <String, Object?>{
                    'musicShelfRenderer': <String, Object?>{
                      'contents': <Object?>[
                        <String, Object?>{
                          'musicResponsiveListItemRenderer': <String, Object?>{
                            'flexColumns': <Object?>[
                              <String, Object?>{
                                'musicResponsiveListItemFlexColumnRenderer':
                                    <String, Object?>{
                                      'text': <String, Object?>{
                                        'runs': <Object?>[
                                          <String, Object?>{
                                            'text': 'Direct Shelf List',
                                          },
                                        ],
                                      },
                                    },
                              },
                            ],
                            'navigationEndpoint': <String, Object?>{
                              'browseEndpoint': <String, Object?>{
                                'browseId': 'VLPLdirectshelf001',
                              },
                            },
                          },
                        },
                      ],
                    },
                  },
                },
              },
            ],
          },
        },
      };
      final client = _signedInClient(
        (uri) async => _FakeHttpResponse(200, jsonEncode(body)),
      );
      final playlists = await client.libraryPlaylists();
      expect(playlists.length, 1);
      expect(playlists.first.playlistId, 'PLdirectshelf001');
    });

    test('two-column rows read direct title and watch endpoint', () async {
      const body = <String, Object?>{
        'contents': <String, Object?>{
          'singleColumnBrowseResultsRenderer': <String, Object?>{
            'tabs': <Object?>[
              <String, Object?>{
                'tabRenderer': <String, Object?>{
                  'content': <String, Object?>{
                    'sectionListRenderer': <String, Object?>{
                      'contents': <Object?>[
                        <String, Object?>{
                          'gridRenderer': <String, Object?>{
                            'items': <Object?>[
                              <String, Object?>{
                                'musicTwoColumnItemRenderer': <String, Object?>{
                                  'title': <String, Object?>{
                                    'runs': <Object?>[
                                      <String, Object?>{
                                        'text': 'Two Column Mix',
                                      },
                                    ],
                                  },
                                  'subtitle': <String, Object?>{
                                    'runs': <Object?>[
                                      <String, Object?>{
                                        'text': 'Playlist • 50 songs',
                                      },
                                    ],
                                  },
                                  'navigationEndpoint': <String, Object?>{
                                    'watchPlaylistEndpoint': <String, Object?>{
                                      'playlistId': 'PLtwocolumn00001',
                                    },
                                  },
                                },
                              },
                            ],
                          },
                        },
                      ],
                    },
                  },
                },
              },
            ],
          },
        },
      };
      final client = _signedInClient(
        (uri) async => _FakeHttpResponse(200, jsonEncode(body)),
      );
      final playlists = await client.libraryPlaylists();
      expect(playlists.length, 1);
      expect(playlists.first.playlistId, 'PLtwocolumn00001');
      expect(playlists.first.title, 'Two Column Mix');
      expect(playlists.first.subtitle, 'Playlist • 50 songs');
    });
  });
}
