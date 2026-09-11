import 'package:aurora_core/aurora_core.dart';

/// Audio-only format selectors per quality rung.
///
/// Documented contract (spec 7): low = m4a ~128k, medium = opus ~160k,
/// high = m4a ~256k (default for downloads), original = best audio with
/// no bitrate cap. Every selector prefers audio-only streams; video
/// streams are never selected.
abstract final class YtdlpQualityFormats {
  /// yt-dlp `-f` selector for [quality].
  static String formatFor(Quality quality) => switch (quality) {
    Quality.low =>
      'bestaudio[ext=m4a][abr<=128]/'
          'bestaudio[abr<=128]/'
          'bestaudio[ext=m4a]/bestaudio',
    Quality.medium => 'bestaudio[abr<=160]/bestaudio',
    Quality.high =>
      'bestaudio[ext=m4a][abr<=256]/'
          'bestaudio[abr<=256]/'
          'bestaudio[ext=m4a]/bestaudio',
    Quality.original => 'bestaudio/best',
  };

  /// `--audio-format` used when extracting downloads for [quality].
  ///
  /// Downloads transcode to m4a (ALAC/AAC in MP4) so files play
  /// everywhere including MediaStore; streaming keeps the source codec
  /// (no transcode on the stream path).
  static String audioFormatFor(Quality quality) => switch (quality) {
    Quality.low => 'm4a',
    Quality.medium => 'm4a',
    Quality.high => 'm4a',
    Quality.original => 'm4a',
  };

  /// MIME hint for a stream resolved at [quality].
  static String mimeTypeFor(Quality quality) => switch (quality) {
    Quality.medium => 'audio/opus',
    Quality.low => 'audio/mp4',
    Quality.high => 'audio/mp4',
    Quality.original => 'audio/mp4',
  };
}
