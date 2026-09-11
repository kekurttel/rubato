import 'package:aurora_music_source_local/src/myt_filename.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// One audio row from `MediaStore.Audio.Media` (spec section 7).
///
/// Plain record: the native side (`aurora.player/media_store`) returns
/// `IS_MUSIC != 0` rows and this class only carries them. Indexing into
/// the database happens in the app-layer scan, not here.
@immutable
final class MediaStoreAudio {
  /// Creates a record.
  const MediaStoreAudio({
    required this.mediaId,
    required this.contentUri,
    required this.title,
    required this.displayName,
    this.artist,
    this.album,
    this.albumId,
    this.durationMs = 0,
    this.year,
    this.dataPath,
  });

  /// MediaStore row id (`MediaStore.Audio.Media._ID`).
  final int mediaId;

  /// Playable URI (`content://media/external/audio/media/<id>`);
  /// just_audio/ExoPlayer plays `content://` URIs directly.
  final String contentUri;

  /// Embedded tag title (may be empty when untagged).
  final String title;

  /// File display name with extension (e.g. `Title(_ID_).m4a`).
  final String displayName;

  /// Embedded artist, if the row carries a known one.
  final String? artist;

  /// Embedded album, if the row carries a known one.
  final String? album;

  /// MediaStore album id (`MediaStore.Audio.Media.ALBUM_ID`).
  ///
  /// The native thumbnail lookup serves album art from the albums
  /// collection for this id. Null when the row carries none (the
  /// lookup then falls back to the audio row itself).
  final int? albumId;

  /// Duration in milliseconds (0 when unknown).
  final int durationMs;

  /// Release year, if known.
  final int? year;

  /// Absolute filesystem path (`MediaStore.Audio.Media.DATA`, deprecated
  /// but populated): enables direct embedded-tag reads under
  /// `READ_MEDIA_AUDIO`. Null when the native row carries none.
  final String? dataPath;

  /// Clean display title: MYT `Title(_ID_)` suffix stripped, never raw.
  ///
  /// Prefers the `displayName` parse (the `(_ID_)` suffix lives in the
  /// filename, not the tag), then the tag title, then the bare basename.
  String get cleanTitle {
    final myt = MytFilename.parse(displayName);
    if (myt != null) {
      return myt.title;
    }
    if (title.trim().isNotEmpty) {
      return title.trim();
    }
    return MytFilename.titleFallback(displayName);
  }

  /// Stable provider-scoped id: the MYT `(_ID_)` when the filename has
  /// one, else `mediastore-<mediaId>` (stable across rescans).
  String get sourceTrackId {
    final myt = MytFilename.parse(displayName);
    return myt?.sourceTrackId ?? 'mediastore-$mediaId';
  }
}

/// Dart side of the `aurora.player/media_store` channel.
///
/// Returns `[]` on non-Android platforms, a missing channel, or
/// malformed rows — the scan treats that as an empty library, never an
/// error. Never throws.
abstract final class MediaStoreReader {
  /// Channel opened by `MainActivity`.
  static const String channelName = 'aurora.player/media_store';

  /// `queryAudio` method returning `List<Map>` rows.
  static const String methodQueryAudio = 'queryAudio';

  /// `artworkFor` method returning the cached thumbnail path (or null).
  static const String methodArtworkFor = 'artworkFor';

  /// `readAudioBytes` method returning a raw byte range (or null).
  static const String methodReadAudioBytes = 'readAudioBytes';

  /// Default sniff window (mirrors `TagParser.sniffBytes`, 2 MiB).
  static const int audioBytesDefaultLength = 2 * 1024 * 1024;

  /// Reads a raw byte range of one audio row through its `content://`
  /// URI (never throws).
  ///
  /// Scoped-storage-safe embedded-art source: needs only
  /// `READ_MEDIA_AUDIO` (granted for the scan), unlike the `DATA`
  /// path, which can be null or unreadable on Android 11+. A negative
  /// [offset] reads from the end (mp4 `moov`-at-end tail). Null when
  /// the row is unreadable, on non-Android platforms, or on any
  /// channel error — callers fall through to the thumbnail path.
  static Future<Uint8List?> readAudioBytes(
    int mediaId, {
    int offset = 0,
    int length = audioBytesDefaultLength,
    MethodChannel? channel,
  }) async {
    try {
      final resolved = channel ?? const MethodChannel(channelName);
      final raw = await resolved.invokeMethod<dynamic>(
        methodReadAudioBytes,
        <String, Object?>{
          'audioId': mediaId,
          'offset': offset,
          'length': length,
        },
      );
      if (raw is Uint8List && raw.isNotEmpty) {
        return raw;
      }
      if (raw is List && raw.isNotEmpty) {
        return Uint8List.fromList(raw.cast<int>());
      }
      return null;
    } on Exception catch (_) {
      return null;
    }
  }

  /// Fetches the cached thumbnail path for one MediaStore row.
  ///
  /// The native side renders a 512px JPEG under app cache
  /// (`artwork/local-<audioId>.jpg`) via `loadThumbnail` — from the
  /// albums collection when [albumId] names one, else from the audio
  /// row itself — and returns its absolute path, or null when neither
  /// source carries art. Null on non-Android platforms, a missing
  /// channel, or any error — the scan treats that as "no thumbnail",
  /// never an error. Never throws.
  static Future<String?> artworkFor(
    int mediaId, {
    int? albumId,
    MethodChannel? channel,
  }) async {
    try {
      final resolved = channel ?? const MethodChannel(channelName);
      final args = <String, Object?>{'audioId': mediaId};
      if (albumId != null) {
        args['albumId'] = albumId;
      }
      final raw = await resolved.invokeMethod<dynamic>(
        methodArtworkFor,
        args,
      );
      if (raw is String && raw.isNotEmpty) {
        return raw;
      }
      return null;
    } on Exception catch (_) {
      return null;
    }
  }

  /// Fetches all music rows from MediaStore.
  ///
  /// Pass [channel] in tests to fake the native side.
  static Future<List<MediaStoreAudio>> fetchAudioFiles({
    MethodChannel? channel,
  }) async {
    try {
      final resolved = channel ?? const MethodChannel(channelName);
      final raw = await resolved.invokeMethod<dynamic>(methodQueryAudio);
      if (raw is! List) {
        return const <MediaStoreAudio>[];
      }
      final out = <MediaStoreAudio>[];
      for (final entry in raw) {
        if (entry is! Map) {
          continue;
        }
        final audio = _fromMap(Map<Object?, Object?>.from(entry));
        if (audio != null) {
          out.add(audio);
        }
      }
      return out;
    } on Exception catch (_) {
      // Non-Android, missing plugin, or channel error: no library rows.
      return const <MediaStoreAudio>[];
    }
  }

  /// Parses one channel row; null when the row is unusable (never throws).
  static MediaStoreAudio? _fromMap(Map<Object?, Object?> map) {
    final mediaId = _asInt(map['id']);
    if (mediaId == null) {
      return null;
    }
    final title = (map['title'] as String? ?? '').trim();
    final displayName = (map['displayName'] as String? ?? '').trim();
    if (title.isEmpty && displayName.isEmpty) {
      return null;
    }
    final dataPath = (map['dataPath'] as String? ?? '').trim();
    return MediaStoreAudio(
      mediaId: mediaId,
      contentUri: 'content://media/external/audio/media/$mediaId',
      title: title.isEmpty ? displayName : title,
      displayName: displayName.isEmpty ? title : displayName,
      artist: _knownOrNull(map['artist'] as String?),
      album: _knownOrNull(map['album'] as String?),
      albumId: _asInt(map['albumId']),
      durationMs: _asInt(map['durationMs']) ?? 0,
      year: _asInt(map['year']),
      dataPath: dataPath.isEmpty ? null : dataPath,
    );
  }

  /// Nulls blanks and MediaStore's `<unknown>` placeholder.
  static String? _knownOrNull(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty || value.toLowerCase() == '<unknown>') {
      return null;
    }
    return value;
  }

  /// Coerces channel numbers (Long/Int arrive as `int`).
  static int? _asInt(Object? raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    return null;
  }
}
