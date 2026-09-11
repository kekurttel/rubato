import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Content hash for dedupe: sha1(first 64KB + last 64KB + length).
///
/// The whole file is never read (spec section 7), so hashing stays cheap
/// on a 200-file rescan. Files ≤ 128KB hash their full bytes once (no
/// double-counted overlap) plus the length trailer.
abstract final class AudioHash {
  /// Bytes read from each end of the file.
  static const int windowSize = 65536;

  /// Hashes an open file at [path] (empty string when unreadable).
  ///
  /// Never throws: I/O errors yield `''` so scans skip the file instead
  /// of crashing.
  static Future<String> hashFile(String path) async {
    try {
      final file = File(path);
      final length = await file.length();
      final access = await file.open();
      try {
        if (length <= windowSize * 2) {
          final all = await access.read(length);
          return hashBytes(all, all, length);
        }
        final first = await access.read(windowSize);
        await access.setPosition(length - windowSize);
        final last = await access.read(windowSize);
        return hashBytes(first, last, length);
      } finally {
        await access.close();
      }
    } on Exception {
      return '';
    }
  }

  /// Pure hash core (unit-testable without files).
  static String hashBytes(List<int> first, List<int> last, int length) {
    final lengthTrailer = ByteData(8)..setUint64(0, length);
    final digest = sha1.convert(<int>[
      ...first,
      ...last,
      ...lengthTrailer.buffer.asUint8List(),
    ]);
    return digest.toString();
  }
}
