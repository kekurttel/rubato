import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aurora_music_source_local/src/tag_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Synthetic cover payload (not a valid image, but the parser only
/// slices bytes — validity is the UI decoder's problem).
const List<int> _fakeJpeg = <int>[0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4];

List<int> _be32(int v) => <int>[
  (v >> 24) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 8) & 0xFF,
  v & 0xFF,
];

List<int> _box(String type, List<int> payload) => <int>[
  ..._be32(8 + payload.length),
  ...ascii.encode(type),
  ...payload,
];

/// Box with raw (non-ASCII) type bytes, e.g. `©nam` = A9 6E 61 6D.
List<int> _boxRaw(List<int> type, List<int> payload) => <int>[
  ..._be32(8 + payload.length),
  ...type,
  ...payload,
];

/// Text `data` box (kind 1 = utf-8) for an `ilst` text item.
List<int> _textData(String text) {
  final raw = utf8.encode(text);
  return <int>[
    ..._be32(16 + raw.length),
    ...ascii.encode('data'),
    ..._be32(1),
    ..._be32(0),
    ...raw,
  ];
}

/// Minimal `moov/udta/meta/ilst` tree with one jpeg item + title.
List<int> _moovWithCovr(List<int> image) {
  final data = <int>[
    ..._be32(16 + image.length),
    ...ascii.encode('data'),
    ..._be32(13), // kind 13 = jpeg
    ..._be32(0), // locale
    ...image,
  ];
  final ilst = <int>[
    ..._box('covr', data),
    ..._boxRaw(<int>[0xA9, 0x6E, 0x61, 0x6D], _textData('Tail Title')),
  ];
  final ilstBox = _box('ilst', ilst);
  final meta = _box('meta', <int>[0, 0, 0, 0, ...ilstBox]);
  final udata = _box('udta', meta);
  return _box('moov', udata);
}

List<int> _ftyp() => <int>[
  ..._be32(20),
  ...ascii.encode('ftyp'),
  ...ascii.encode('isom'),
  ..._be32(0),
  ...ascii.encode('isom'),
];

/// FLAC `PICTURE` block payload for [image] with [mime].
List<int> _flacPicture(List<int> image, String mime) {
  final mimeBytes = ascii.encode(mime);
  return <int>[
    ..._be32(3), // front cover
    ..._be32(mimeBytes.length),
    ...mimeBytes,
    ..._be32(0), // empty description
    ...List<int>.filled(16, 0), // w/h/depth/colors
    ..._be32(image.length),
    ...image,
  ];
}

List<int> _flacBlock(int type, List<int> payload, {required bool last}) =>
    <int>[
      (last ? 0x80 : 0) | type,
      (payload.length >> 16) & 0xFF,
      (payload.length >> 8) & 0xFF,
      payload.length & 0xFF,
      ...payload,
    ];

List<int> _le32(int v) => <int>[
  v & 0xFF,
  (v >> 8) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 24) & 0xFF,
];

/// Vorbis-comment block payload from `key=value` [entries].
List<int> _vorbisComment(Map<String, String> entries) {
  final vendor = ascii.encode('test');
  final fields = <int>[
    ..._le32(vendor.length),
    ...vendor,
    ..._le32(entries.length),
  ];
  for (final entry in entries.entries) {
    final raw = utf8.encode('${entry.key}=${entry.value}');
    fields.addAll(<int>[..._le32(raw.length), ...raw]);
  }
  return fields;
}

void main() {
  test('mp4 covr at head parses', () {
    final bytes = <int>[..._ftyp(), ..._moovWithCovr(_fakeJpeg)];
    final tags = TagParser.parseBytes(bytes);
    expect(tags.title, 'Tail Title');
    expect(tags.hasArtwork, isTrue);
    expect(tags.artworkMime, 'image/jpeg');
    expect(tags.artworkBytes, orderedEquals(_fakeJpeg));
  });

  test('mp4 covr at tail (moov-at-end) parses via parseFile', () async {
    final moov = _moovWithCovr(_fakeJpeg);
    const padLen = TagParser.sniffBytes + 64;
    final dir = await Directory.systemTemp.createTemp('aurora-moov-tail');
    try {
      final file = File('${dir.path}/tail.m4a');
      await file.writeAsBytes(<int>[
        ..._ftyp(),
        ...List<int>.filled(padLen, 0),
        ...moov,
      ], flush: true);
      final tags = await TagParser.parseFile(file.path);
      expect(tags.hasArtwork, isTrue);
      expect(tags.artworkBytes, orderedEquals(_fakeJpeg));
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('flac PICTURE block parses', () {
    final pic = _flacPicture(_fakeJpeg, 'image/jpeg');
    final bytes = <int>[
      ...ascii.encode('fLaC'),
      ..._flacBlock(6, pic, last: true),
    ];
    final tags = TagParser.parseBytes(bytes);
    expect(tags.hasArtwork, isTrue);
    expect(tags.artworkMime, 'image/jpeg');
    expect(tags.artworkBytes, orderedEquals(_fakeJpeg));
  });

  test('flac vorbis METADATA_BLOCK_PICTURE parses', () {
    final pic = _flacPicture(_fakeJpeg, 'image/png');
    final comment = _vorbisComment(<String, String>{
      'TITLE': 'Tail Song',
      'METADATA_BLOCK_PICTURE': base64.encode(pic),
    });
    final bytes = <int>[
      ...ascii.encode('fLaC'),
      ..._flacBlock(4, comment, last: true),
    ];
    final tags = TagParser.parseBytes(bytes);
    expect(tags.title, 'Tail Song');
    expect(tags.hasArtwork, isTrue);
    expect(tags.artworkMime, 'image/png');
    expect(tags.artworkBytes, orderedEquals(_fakeJpeg));
  });

  test('ogg METADATA_BLOCK_PICTURE scans', () {
    final pic = _flacPicture(_fakeJpeg, 'image/jpeg');
    final bytes = <int>[
      ...ascii.encode('OggS'),
      ...List<int>.filled(32, 0),
      ...ascii.encode('METADATA_BLOCK_PICTURE=${base64.encode(pic)}'),
      0,
    ];
    final tags = TagParser.parseBytes(bytes);
    expect(tags.hasArtwork, isTrue);
    expect(tags.artworkBytes, orderedEquals(_fakeJpeg));
  });

  test('empty bytes stay empty', () {
    expect(TagParser.parseBytes(Uint8List(0)).isEmpty, isTrue);
    expect(
      TagParser.parseBytes(utf8.encode('not audio at all.......'))
          .hasArtwork,
      isFalse,
    );
  });
}
