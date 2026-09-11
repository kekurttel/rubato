import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Best-effort embedded tags (ID3v2 + mp4 atoms, spec section 7).
///
/// The parser never throws: corrupt or unknown containers yield empty
/// fields and the scan falls back to the MYT filename. Only the frames
/// the library needs are decoded (title/artist/album/year/track/art).
@immutable
final class AudioTags {
  /// Creates a tag set (all fields optional).
  const AudioTags({
    this.title,
    this.artist,
    this.album,
    this.year,
    this.trackNumber,
    this.artworkBytes,
    this.artworkMime,
  });

  /// Empty tag set (no usable metadata).
  static const AudioTags empty = AudioTags();

  /// Track title, if embedded.
  final String? title;

  /// Lead artist, if embedded.
  final String? artist;

  /// Album title, if embedded.
  final String? album;

  /// Release year, if embedded.
  final int? year;

  /// Track number within the album, if embedded.
  final int? trackNumber;

  /// Embedded cover bytes (first APIC/covr wins), if any.
  final Uint8List? artworkBytes;

  /// MIME of [artworkBytes] (`image/jpeg`, `image/png`, ...).
  final String? artworkMime;

  /// Whether every field is null.
  bool get isEmpty =>
      title == null &&
      artist == null &&
      album == null &&
      year == null &&
      trackNumber == null &&
      artworkBytes == null;

  /// Whether an embedded cover is present.
  bool get hasArtwork => artworkBytes != null && artworkBytes!.isNotEmpty;
}

/// Best-effort tag reader (ID3v2.3/2.4 text + APIC, mp4 ilst).
abstract final class TagParser {
  /// Cap for tag sniffing reads (tags live at the file head, except
  /// mp4 `moov`-at-end files, which fall back to the filename).
  static const int sniffBytes = 2 * 1024 * 1024;

  /// Parses tags for the file at [path] (never throws).
  static Future<AudioTags> parseFile(String path) async {
    try {
      final file = File(path);
      final length = await file.length();
      final access = await file.open();
      try {
        final headLen = length < sniffBytes ? length : sniffBytes;
        final head = await access.read(headLen);
        final tags = parseBytes(head);
        if (tags.hasArtwork) {
          return tags;
        }
        // mp4 `moov`-at-end files (common for downloads): the
        // `ilst/covr` lives past the head window, so one tail probe
        // recovers art the head parse cannot see.
        if (length > headLen && _mayBeMp4(head, path)) {
          final tailLen = length - headLen < sniffBytes
              ? length - headLen
              : sniffBytes;
          await access.setPosition(length - tailLen);
          final tail = await access.read(tailLen);
          final tailTags = parseMp4(tail);
          if (tailTags.hasArtwork) {
            return AudioTags(
              title: tags.title ?? tailTags.title,
              artist: tags.artist ?? tailTags.artist,
              album: tags.album ?? tailTags.album,
              year: tags.year ?? tailTags.year,
              trackNumber: tags.trackNumber ?? tailTags.trackNumber,
              artworkBytes: tailTags.artworkBytes,
              artworkMime: tailTags.artworkMime,
            );
          }
        }
        return tags;
      } finally {
        await access.close();
      }
    } on Exception {
      return AudioTags.empty;
    }
  }

  /// Parses in-memory [bytes] (never throws).
  static AudioTags parseBytes(List<int> bytes) {
    try {
      if (_isId3(bytes)) {
        return parseId3(bytes);
      }
      if (_isFlac(bytes)) {
        return parseFlac(bytes);
      }
      if (_isOgg(bytes)) {
        return parseOgg(bytes);
      }
      if (_isMp4(bytes)) {
        return parseMp4(bytes);
      }
      // Ogg/FLAC markers can sit past an ID3 header only for mp3;
      // otherwise a head-window slice of mp4 `mdat` may hide the
      // `ftyp` — still try the vorbis scan before giving up.
      return parseOgg(bytes);
    } on Exception {
      return AudioTags.empty;
    }
  }

  /// Whether [bytes] start with an ID3v2 header.
  static bool _isId3(List<int> bytes) =>
      bytes.length > 10 &&
      bytes[0] == 0x49 &&
      bytes[1] == 0x44 &&
      bytes[2] == 0x33;

  /// Whether [bytes] look like an mp4 (`ftyp` in the first box).
  static bool _isMp4(List<int> bytes) =>
      bytes.length > 12 &&
      bytes[4] == 0x66 &&
      bytes[5] == 0x74 &&
      bytes[6] == 0x79 &&
      bytes[7] == 0x70;

  /// Whether [bytes] start with the FLAC stream marker.
  static bool _isFlac(List<int> bytes) =>
      bytes.length > 4 &&
      bytes[0] == 0x66 &&
      bytes[1] == 0x4C &&
      bytes[2] == 0x61 &&
      bytes[3] == 0x43;

  /// Whether [bytes] start with an Ogg page (vorbis/opus).
  static bool _isOgg(List<int> bytes) =>
      bytes.length > 4 &&
      bytes[0] == 0x4F &&
      bytes[1] == 0x67 &&
      bytes[2] == 0x67 &&
      bytes[3] == 0x53;

  /// Head-window heuristic for the tail probe: real `ftyp`, or an
  /// audio extension whose head is all `mdat` (no marker visible).
  static bool _mayBeMp4(List<int> head, String path) {
    if (_isMp4(head)) {
      return true;
    }
    final lower = path.toLowerCase();
    return lower.endsWith('.m4a') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.aac');
  }

  /// Parses ID3v2.3/2.4 frames (best-effort, never throws).
  static AudioTags parseId3(List<int> bytes) {
    try {
      if (!_isId3(bytes)) {
        return AudioTags.empty;
      }
      final version = bytes[3];
      final flags = bytes[5];
      var tagEnd = 10 + _syncSafeInt(bytes, 6);
      if (tagEnd > bytes.length) {
        tagEnd = bytes.length;
      }
      var offset = 10;
      if ((flags & 0x40) != 0 && offset + 4 <= tagEnd) {
        final extSize = version == 4
            ? _syncSafeInt(bytes, offset)
            : _be32(bytes, offset);
        offset += 4 + extSize;
      }
      String? title;
      String? artist;
      String? album;
      int? year;
      int? trackNumber;
      Uint8List? art;
      String? artMime;
      while (offset + 10 <= tagEnd) {
        if (bytes[offset] == 0) {
          break;
        }
        final frameId = ascii.decode(
          bytes.sublist(offset, offset + 4),
          allowInvalid: true,
        );
        final size = version == 4
            ? _syncSafeInt(bytes, offset + 4)
            : _be32(bytes, offset + 4);
        final dataStart = offset + 10;
        final dataEnd = dataStart + size;
        if (size <= 0 || dataEnd > tagEnd) {
          break;
        }
        final data = bytes.sublist(dataStart, dataEnd);
        switch (frameId) {
          case 'TIT2':
            title ??= _decodeText(data);
          case 'TPE1':
            artist ??= _decodeText(data);
          case 'TALB':
            album ??= _decodeText(data);
          case 'TYER' || 'TDRC':
            year ??= _parseYear(_decodeText(data));
          case 'TRCK':
            trackNumber ??= _parseTrackNumber(_decodeText(data));
          case 'APIC':
            if (art == null) {
              final pic = _decodeApic(data);
              art = pic?.bytes;
              artMime = pic?.mime;
            }
        }
        offset = dataEnd;
      }
      return AudioTags(
        title: _nonEmpty(title),
        artist: _nonEmpty(artist),
        album: _nonEmpty(album),
        year: year,
        trackNumber: trackNumber,
        artworkBytes: art,
        artworkMime: artMime,
      );
    } on Exception {
      return AudioTags.empty;
    }
  }

  /// Parses mp4 `moov/udta/meta/ilst` items (best-effort, never throws).
  static AudioTags parseMp4(List<int> bytes) {
    try {
      String? title;
      String? artist;
      String? album;
      int? year;
      int? trackNumber;
      Uint8List? art;
      String? artMime;
      void visit(int start, int end, {required bool inIlst}) {
        var offset = start;
        while (offset + 8 <= end && offset + 8 <= bytes.length) {
          var size = _be32(bytes, offset);
          final type = _boxType(bytes, offset + 4);
          var header = 8;
          if (size == 1 && offset + 16 <= end) {
            size = _be64(bytes, offset + 8);
            header = 16;
          }
          if (size < header) {
            return;
          }
          var payload = offset + header;
          var boxEnd = offset + size;
          if (boxEnd > end || boxEnd > bytes.length) {
            boxEnd = end;
          }
          if (type == 'meta') {
            payload += 4;
          }
          if (type == 'moov' ||
              type == 'udta' ||
              type == 'meta' ||
              type == 'ilst') {
            visit(payload, boxEnd, inIlst: type == 'ilst');
          } else if (inIlst) {
            final item = _decodeIlstItem(type, payload, boxEnd, bytes);
            // `©`-prefixed names (0xA9) do not survive ASCII decode,
            // so match the raw bytes (see [_ilstKind]).
            switch (_ilstKind(bytes, offset)) {
              case 'nam':
                title ??= item.text;
              case 'art':
                artist ??= item.text;
              case 'alb':
                album ??= item.text;
              case 'day':
                year ??= _parseYear(item.text);
              case 'trkn':
                trackNumber ??= item.trackNumber;
              case 'covr':
                if (art == null && item.bytes != null) {
                  art = item.bytes;
                  artMime = item.mime;
                }
            }
          }
          if (boxEnd <= offset) {
            return;
          }
          offset = boxEnd;
        }
      }

      visit(0, bytes.length, inIlst: false);
      if (art == null) {
        // Tail-window slices start mid-`mdat`, so the box walk above
        // stalls on payload zeros: re-anchor on the `moov` marker and
        // walk once more (covers `moov`-at-end downloads).
        final moov = _indexOfMarker(bytes, 'moov');
        if (moov != null && moov >= 4) {
          visit(moov - 4, bytes.length, inIlst: false);
        }
      }
      return AudioTags(
        title: _nonEmpty(title),
        artist: _nonEmpty(artist),
        album: _nonEmpty(album),
        year: year,
        trackNumber: trackNumber,
        artworkBytes: art,
        artworkMime: artMime,
      );
    } on Exception {
      return AudioTags.empty;
    }
  }

  static _IlstValue _decodeIlstItem(
    String type,
    int payload,
    int boxEnd,
    List<int> bytes,
  ) {
    if (payload + 8 > boxEnd || payload + 8 > bytes.length) {
      return const _IlstValue();
    }
    // Items hold one `data` box: size + 'data' + 4B kind + 4B locale.
    final innerSize = _be32(bytes, payload);
    final innerType = _boxType(bytes, payload + 4);
    if (innerType != 'data' || innerSize < 16) {
      return const _IlstValue();
    }
    final kind = _be32(bytes, payload + 8);
    final valueStart = payload + 16;
    final valueEnd = (payload + innerSize).clamp(0, boxEnd);
    if (valueStart >= valueEnd || valueEnd > bytes.length) {
      return const _IlstValue();
    }
    final value = bytes.sublist(valueStart, valueEnd);
    if (type == 'trkn' && value.length >= 4) {
      return _IlstValue(trackNumber: (value[2] << 8) | value[3]);
    }
    if (type == 'covr') {
      final mime = kind == 14 ? 'image/png' : 'image/jpeg';
      return _IlstValue(bytes: Uint8List.fromList(value), mime: mime);
    }
    return _IlstValue(
      text: _nonEmpty(utf8.decode(value, allowMalformed: true).trim()),
    );
  }

  static _ApicValue? _decodeApic(List<int> data) {
    if (data.length < 4) {
      return null;
    }
    final encoding = data[0];
    var i = 1;
    while (i < data.length && data[i] != 0) {
      i++;
    }
    if (i >= data.length) {
      return null;
    }
    final mime = ascii.decode(data.sublist(1, i), allowInvalid: true);
    i += 2; // Skip NUL + picture-type byte.
    if (i >= data.length) {
      return null;
    }
    // Skip the description (encoding-aware NUL terminator).
    if (encoding == 1 || encoding == 2) {
      while (i + 1 < data.length && !(data[i] == 0 && data[i + 1] == 0)) {
        i++;
      }
      i += 2;
    } else {
      while (i < data.length && data[i] != 0) {
        i++;
      }
      i += 1;
    }
    if (i >= data.length) {
      return null;
    }
    final normalizedMime = mime.isEmpty
        ? 'image/jpeg'
        : mime.contains('/')
        ? mime
        : 'image/$mime';
    return _ApicValue(
      bytes: Uint8List.fromList(data.sublist(i)),
      mime: normalizedMime,
    );
  }

  /// Parses FLAC metadata blocks (art + vorbis text, never throws).
  ///
  /// Block 6 (`PICTURE`) decodes directly; block 4 (`VORBIS_COMMENT`)
  /// contributes text fields and may carry a base64
  /// `METADATA_BLOCK_PICTURE` (the opus/vorbis convention).
  static AudioTags parseFlac(List<int> bytes) {
    try {
      if (!_isFlac(bytes)) {
        return AudioTags.empty;
      }
      var offset = 4;
      String? title;
      String? artist;
      String? album;
      int? year;
      int? trackNumber;
      Uint8List? art;
      String? artMime;
      while (offset + 4 <= bytes.length) {
        final last = (bytes[offset] & 0x80) != 0;
        final type = bytes[offset] & 0x7F;
        final len =
            (bytes[offset + 1] << 16) |
            (bytes[offset + 2] << 8) |
            bytes[offset + 3];
        offset += 4;
        if (len < 0 || offset + len > bytes.length) {
          break;
        }
        final block = bytes.sublist(offset, offset + len);
        if (type == 6 && art == null) {
          final pic = _decodeFlacPicture(block);
          if (pic != null) {
            art = pic.bytes;
            artMime = pic.mime;
          }
        } else if (type == 4) {
          final comments = _parseVorbisComment(block);
          title ??= _nonEmpty(comments['title']);
          artist ??= _nonEmpty(comments['artist']);
          album ??= _nonEmpty(comments['album']);
          year ??= _parseYear(comments['date'] ?? comments['year']);
          trackNumber ??= _parseTrackNumber(comments['tracknumber']);
          if (art == null && comments['metadata_block_picture'] != null) {
            final pic = _pictureFromBase64(
              comments['metadata_block_picture']!,
            );
            if (pic != null) {
              art = pic.bytes;
              artMime = pic.mime;
            }
          }
        }
        offset += len;
        if (last) {
          break;
        }
      }
      if (art == null) {
        final pic = _scanVorbisPicture(bytes);
        if (pic != null) {
          art = pic.bytes;
          artMime = pic.mime;
        }
      }
      return AudioTags(
        title: _nonEmpty(title),
        artist: _nonEmpty(artist),
        album: _nonEmpty(album),
        year: year,
        trackNumber: trackNumber,
        artworkBytes: art,
        artworkMime: artMime,
      );
    } on Exception {
      return AudioTags.empty;
    }
  }

  /// Parses Ogg-vorbis/opus tags (art-only best effort, never throws).
  ///
  /// Page framing is skipped: the `METADATA_BLOCK_PICTURE=` comment is
  /// located by scan, which survives head-window truncation as long as
  /// the tags live at the stream head (the usual layout).
  static AudioTags parseOgg(List<int> bytes) {
    try {
      final pic = _scanVorbisPicture(bytes);
      if (pic == null) {
        return AudioTags.empty;
      }
      return AudioTags(artworkBytes: pic.bytes, artworkMime: pic.mime);
    } on Exception {
      return AudioTags.empty;
    }
  }

  /// Decodes one FLAC `PICTURE` block payload (never throws).
  static _ApicValue? _decodeFlacPicture(List<int> block) {
    try {
      int u32(int at) =>
          (block[at] << 24) |
          (block[at + 1] << 16) |
          (block[at + 2] << 8) |
          block[at + 3];
      var o = 0;
      if (block.length < 32) {
        return null;
      }
      o += 4; // Picture type (0 = front cover); ignored.
      final mimeLen = u32(o);
      o += 4;
      if (mimeLen < 0 || o + mimeLen > block.length) {
        return null;
      }
      final mime = ascii.decode(
        block.sublist(o, o + mimeLen),
        allowInvalid: true,
      );
      o += mimeLen;
      if (o + 4 > block.length) {
        return null;
      }
      final descLen = u32(o);
      o += 4;
      if (descLen < 0 || o + descLen > block.length) {
        return null;
      }
      o += descLen + 16; // Description + w/h/depth/colors.
      if (o + 4 > block.length) {
        return null;
      }
      final dataLen = u32(o);
      o += 4;
      if (dataLen <= 0 || o + dataLen > block.length) {
        return null;
      }
      final normalizedMime = mime.isEmpty
          ? 'image/jpeg'
          : mime.contains('/')
          ? mime
          : 'image/$mime';
      return _ApicValue(
        bytes: Uint8List.fromList(block.sublist(o, o + dataLen)),
        mime: normalizedMime,
      );
    } on Exception {
      return null;
    }
  }

  /// Lower-cased vorbis key → raw value for one comment block.
  static Map<String, String> _parseVorbisComment(List<int> block) {
    final out = <String, String>{};
    try {
      int u32le(int at) =>
          block[at] |
          (block[at + 1] << 8) |
          (block[at + 2] << 16) |
          (block[at + 3] << 24);
      var o = 0;
      if (block.length < 4) {
        return out;
      }
      final vendorLen = u32le(o);
      o += 4;
      if (vendorLen < 0 || o + vendorLen > block.length) {
        return out;
      }
      o += vendorLen;
      if (o + 4 > block.length) {
        return out;
      }
      final count = u32le(o);
      o += 4;
      for (var i = 0; i < count; i++) {
        if (o + 4 > block.length) {
          break;
        }
        final len = u32le(o);
        o += 4;
        if (len <= 0 || o + len > block.length) {
          break;
        }
        final entry = utf8.decode(
          block.sublist(o, o + len),
          allowMalformed: true,
        );
        o += len;
        final eq = entry.indexOf('=');
        if (eq > 0) {
          out.putIfAbsent(
            entry.substring(0, eq).trim().toLowerCase(),
            () => entry.substring(eq + 1),
          );
        }
      }
    } on Exception {
      // Best-effort: whatever parsed so far stands.
    }
    return out;
  }

  /// Base64 `METADATA_BLOCK_PICTURE` → picture (never throws).
  static _ApicValue? _pictureFromBase64(String raw) {
    try {
      final cleaned = raw.trim().replaceAll(RegExp(r'\s+'), '');
      if (cleaned.isEmpty) {
        return null;
      }
      return _decodeFlacPicture(base64.decode(cleaned));
    } on Exception {
      return null;
    }
  }

  /// Scans raw [bytes] for a `METADATA_BLOCK_PICTURE=` base64 run.
  ///
  /// Ogg page framing makes length-prefixed parsing fiddly; the marker
  /// itself is ASCII-stable, so the first decodable run that parses as
  /// a FLAC picture wins. Never throws.
  static _ApicValue? _scanVorbisPicture(List<int> bytes) {
    try {
      const marker = 'METADATA_BLOCK_PICTURE=';
      if (bytes.length < marker.length + 32) {
        return null;
      }
      bool isB64(int c) =>
          (c >= 0x41 && c <= 0x5A) ||
          (c >= 0x61 && c <= 0x7A) ||
          (c >= 0x30 && c <= 0x39) ||
          c == 0x2B ||
          c == 0x2F ||
          c == 0x3D;
      for (var i = 0; i + marker.length <= bytes.length; i++) {
        var match = true;
        for (var k = 0; k < marker.length; k++) {
          if (bytes[i + k] != marker.codeUnitAt(k)) {
            match = false;
            break;
          }
        }
        if (!match) {
          continue;
        }
        final j = i + marker.length;
        var end = j;
        while (end < bytes.length && isB64(bytes[end])) {
          end++;
        }
        if (end - j < 32) {
          continue;
        }
        final pic = _pictureFromBase64(
          ascii.decode(bytes.sublist(j, end), allowInvalid: true),
        );
        if (pic != null) {
          return pic;
        }
      }
      return null;
    } on Exception {
      return null;
    }
  }

  static String? _decodeText(List<int> data) {
    if (data.isEmpty) {
      return null;
    }
    final encoding = data[0];
    final body = data.sublist(1);
    try {
      switch (encoding) {
        case 1 || 2:
          return _nonEmpty(_decodeUtf16(body, bigEndian: encoding == 2));
        case 3:
          return _nonEmpty(utf8.decode(body, allowMalformed: true).trim());
        case _:
          return _nonEmpty(
            latin1.decode(body).replaceAll('\x00', '').trim(),
          );
      }
    } on Exception {
      return null;
    }
  }

  static String _decodeUtf16(List<int> body, {required bool bigEndian}) {
    var bytes = body;
    var be = bigEndian;
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      be = false;
      bytes = bytes.sublist(2);
    } else if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
      be = true;
      bytes = bytes.sublist(2);
    }
    final units = <int>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      final unit = be
          ? (bytes[i] << 8) | bytes[i + 1]
          : bytes[i] | (bytes[i + 1] << 8);
      if (unit == 0) {
        break;
      }
      units.add(unit);
    }
    return String.fromCharCodes(units).trim();
  }

  static int _be32(List<int> bytes, int offset) =>
      (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];

  static int _be64(List<int> bytes, int offset) {
    var value = 0;
    for (var i = 0; i < 8; i++) {
      value = (value << 8) | bytes[offset + i];
    }
    return value;
  }

  static int _syncSafeInt(List<int> bytes, int offset) =>
      ((bytes[offset] & 0x7F) << 21) |
      ((bytes[offset + 1] & 0x7F) << 14) |
      ((bytes[offset + 2] & 0x7F) << 7) |
      (bytes[offset + 3] & 0x7F);

  static String _boxType(List<int> bytes, int offset) =>
      ascii.decode(bytes.sublist(offset, offset + 4), allowInvalid: true);

  /// Normalized `ilst` item kind for the box at [offset] (never throws).
  ///
  /// Apple item names are `0xA9 + 3 ASCII` (`©nam`, `©ART`, `©alb`,
  /// `©day`); the leading byte is not ASCII-decodable, so the decoded
  /// [String] switch would never match them. Matching raw bytes keeps
  /// title/artist/album/year extraction working. Returns `''` for
  /// unknown items.
  static String _ilstKind(List<int> bytes, int offset) {
    try {
      if (offset + 8 > bytes.length) {
        return '';
      }
      final b0 = bytes[offset + 4];
      final b1 = bytes[offset + 5];
      final b2 = bytes[offset + 6];
      final b3 = bytes[offset + 7];
      if (b0 == 0xA9) {
        if (b1 == 0x6E && b2 == 0x61 && b3 == 0x6D) {
          return 'nam'; // ©nam title
        }
        if (b1 == 0x41 && b2 == 0x52 && b3 == 0x54) {
          return 'art'; // ©ART artist
        }
        if (b1 == 0x61 && b2 == 0x6C && b3 == 0x62) {
          return 'alb'; // ©alb album
        }
        if (b1 == 0x64 && b2 == 0x61 && b3 == 0x79) {
          return 'day'; // ©day release date
        }
        return '';
      }
      if (b0 == 0x74 && b1 == 0x72 && b2 == 0x6B && b3 == 0x6E) {
        return 'trkn';
      }
      if (b0 == 0x63 && b1 == 0x6F && b2 == 0x76 && b3 == 0x72) {
        return 'covr';
      }
      return '';
    } on Exception {
      return '';
    }
  }

  /// Offset of the ASCII [marker] in [bytes], or null (never throws).
  static int? _indexOfMarker(List<int> bytes, String marker) {
    try {
      if (bytes.length < 4 || marker.length != 4) {
        return null;
      }
      for (var i = 0; i + 4 <= bytes.length; i++) {
        if (bytes[i] == marker.codeUnitAt(0) &&
            bytes[i + 1] == marker.codeUnitAt(1) &&
            bytes[i + 2] == marker.codeUnitAt(2) &&
            bytes[i + 3] == marker.codeUnitAt(3)) {
          return i;
        }
      }
      return null;
    } on Exception {
      return null;
    }
  }

  static int? _parseYear(String? raw) {
    if (raw == null) {
      return null;
    }
    final match = RegExp(r'\d{4}').firstMatch(raw);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  static int? _parseTrackNumber(String? raw) {
    if (raw == null) {
      return null;
    }
    return int.tryParse(raw.split('/').first.trim());
  }

  static String? _nonEmpty(String? raw) =>
      raw == null || raw.trim().isEmpty ? null : raw.trim();
}

/// Decoded `ilst` item payload.
@immutable
final class _IlstValue {
  /// Creates a value.
  const _IlstValue({this.text, this.bytes, this.mime, this.trackNumber});

  /// Text payload, if any.
  final String? text;

  /// Binary payload (artwork), if any.
  final Uint8List? bytes;

  /// MIME of [bytes], if any.
  final String? mime;

  /// Track number, if this was a `trkn` item.
  final int? trackNumber;
}

/// Decoded APIC frame payload.
@immutable
final class _ApicValue {
  /// Creates a value.
  const _ApicValue({required this.bytes, required this.mime});

  /// Cover bytes.
  final Uint8List bytes;

  /// Cover MIME.
  final String mime;
}
