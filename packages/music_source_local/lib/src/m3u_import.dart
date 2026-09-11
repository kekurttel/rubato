import 'package:meta/meta.dart';

/// One playable entry of an `.m3u` playlist.
@immutable
final class M3uEntry {
  /// Creates an entry.
  const M3uEntry({required this.location, this.title});

  /// Raw location line (file path or URL, trimmed, never empty).
  final String location;

  /// `#EXTINF` display title, when the playlist provided one.
  final String? title;
}

/// Tolerant `.m3u` import, including the user's `[MYT].m3u`.
///
/// Rules (spec section 1): empty files import as empty playlists (never
/// an error); missing entries are kept as-is (resolution skips them
/// later); `#` comment lines are ignored except `#EXTINF`, whose title
/// attaches to the next location line. Never throws.
abstract final class M3uImport {
  /// Parses [content] (may be null/empty → empty list).
  static List<M3uEntry> parseContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return const <M3uEntry>[];
    }
    final entries = <M3uEntry>[];
    String? pendingTitle;
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim().replaceAll('\r', '');
      if (line.isEmpty) {
        continue;
      }
      if (line.startsWith('#EXTINF:')) {
        pendingTitle = _extInfTitle(line);
        continue;
      }
      if (line.startsWith('#')) {
        continue;
      }
      entries.add(M3uEntry(location: line, title: pendingTitle));
      pendingTitle = null;
    }
    return entries;
  }

  /// Title after the first comma of an `#EXTINF` line, if any.
  static String? _extInfTitle(String line) {
    final comma = line.indexOf(',');
    if (comma < 0 || comma == line.length - 1) {
      return null;
    }
    final title = line.substring(comma + 1).trim();
    return title.isEmpty ? null : title;
  }
}
