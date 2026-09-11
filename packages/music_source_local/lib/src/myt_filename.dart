import 'package:meta/meta.dart';

/// Parsed MYT-style filename: `Title(_<11-char-id>_).ext`.
///
/// The user's existing collection (`~/Music/allmusic/`, ~200 files) uses
/// this shape. The UI must never show the raw `(_ID_)` suffix; [title] is
/// the clean display title and [sourceTrackId] is the stable id.
@immutable
final class MytFilename {
  /// Creates a parsed filename.
  const MytFilename({required this.title, required this.sourceTrackId});

  /// Matches `Title(_ID_).ext` with an 11-char id (YouTube-id shaped).
  ///
  /// The title part is greedy so `A (live)(_abc_)` keeps its real
  /// parentheses; only the trailing `(_ID_)` is stripped.
  static final RegExp pattern = RegExp(
    r'^(.*)\(_([A-Za-z0-9_-]{11})_\)\.(m4a|mp3|opus|ogg|oga|flac|wav|aac)$',
    caseSensitive: false,
  );

  /// Clean display title (trimmed, never the raw filename).
  final String title;

  /// Stable provider-scoped id (the 11-char `(_ID_)` part).
  final String sourceTrackId;

  /// Parses [filename] (basename only, no directories).
  ///
  /// Returns null when the name is not MYT-shaped; callers fall back to
  /// the basename-without-extension as title. Never throws.
  static MytFilename? parse(String filename) {
    final base = filename.split('/').last.split(r'\').last;
    final match = pattern.firstMatch(base.trim());
    if (match == null) {
      return null;
    }
    final title = match.group(1)!.trim();
    final id = match.group(2)!;
    if (title.isEmpty) {
      return null;
    }
    return MytFilename(title: title, sourceTrackId: id);
  }

  /// Whether [filename] is MYT-shaped.
  static bool isMytFilename(String filename) => parse(filename) != null;

  /// Title fallback for non-MYT names: basename without extension.
  static String titleFallback(String filename) {
    final base = filename.split('/').last.split(r'\').last.trim();
    final dot = base.lastIndexOf('.');
    final withoutExt = dot <= 0 ? base : base.substring(0, dot);
    return withoutExt.trim().isEmpty ? base : withoutExt.trim();
  }
}
