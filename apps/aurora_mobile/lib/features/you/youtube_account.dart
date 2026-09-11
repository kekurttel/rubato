import 'dart:convert';

import 'package:aurora_music_source_ytdlp/aurora_music_source_ytdlp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// YouTube account auth via user cookies (InnerTune-style).
///
/// Google OAuth on an embedded client is rejected by Google, so the
/// account attaches the way community clients do: the user signs in
/// once inside the app's WebView (or pastes cookies on desktop) and
/// the session cookies (`SID`, `SAPISID`, ...) are stored on-device
/// and forwarded to the native extractor. Authenticated InnerTube
/// requests are not bot-gated, private/unlisted playlists resolve,
/// and the `LL` (liked) / `HL` (history) feeds open. Nothing leaves
/// the device except the cookies YouTube itself requires.
abstract final class YouTubeAccount {
  /// SharedPreferences key holding the cookie map as JSON.
  static const String prefsKey = 'aurora.ytaccount.cookies';

  /// Cookies that must be present for a usable session.
  static const List<String> requiredKeys = <String>['SID', 'SAPISID'];

  /// Parses pasted cookies in any of three shapes (never throws,
  /// empty on garbage):
  /// - `a=b; c=d` header form;
  /// - a JSON object (`{"SID": "...", ...}`);
  /// - raw devtools cookie-table rows pasted as-is (tab/whitespace
  ///   separated `name value …` per line; the header row is skipped).
  static Map<String, String> parseCookies(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const <String, String>{};
    }
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return <String, String>{
            for (final entry in decoded.entries)
              if (entry.key is String && entry.value is String)
                entry.key as String: (entry.value as String).trim(),
          };
        }
      } on FormatException {
        return const <String, String>{};
      }
      return const <String, String>{};
    }
    final out = <String, String>{};
    for (final line in trimmed.split('\n')) {
      // Devtools table paste: `NAME\tVALUE\tDOMAIN…` (values may
      // carry base64 `=` padding, so take the columns verbatim).
      if (line.contains('\t')) {
        final cells = line.split('\t').where((c) => c.trim().isNotEmpty);
        if (cells.length >= 2) {
          final name = cells.first.trim();
          final value = cells.elementAt(1).trim();
          if (_looksLikeCookieName(name) && value.isNotEmpty) {
            out[name] = value;
            continue;
          }
        }
      }
      for (final part in line.split(';')) {
        final eq = part.indexOf('=');
        if (eq <= 0) {
          continue;
        }
        final name = part.substring(0, eq).trim();
        final value = part.substring(eq + 1).trim();
        if (name.isNotEmpty && value.isNotEmpty) {
          out[name] = value;
        }
      }
    }
    return out;
  }

  static bool _looksLikeCookieName(String name) =>
      RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(name) && name != 'Name';

  /// Whether [cookies] look like a signed-in session.
  static bool looksSignedIn(Map<String, String> cookies) {
    for (final key in requiredKeys) {
      if ((cookies[key] ?? '').isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Loads the stored cookies (empty when never signed in).
  static Future<Map<String, String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return parseCookies(prefs.getString(prefsKey) ?? '');
    } on Object {
      return const <String, String>{};
    }
  }

  /// Persists [cookies] (replaces any previous session).
  static Future<void> save(Map<String, String> cookies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, jsonEncode(cookies));
    } on Object {
      // Persistence is best-effort; the in-bridge session still works
      // until the process dies.
    }
  }

  /// Clears the stored session.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefsKey);
    } on Object {
      // Best-effort.
    }
  }

  /// Pushes the stored session into the native extractor (or clears
  /// it when signed out) and into the provider's Dart account client
  /// (account home + library). No-op off-Android for the native side;
  /// the Dart client works on every platform. Never throws.
  static Future<void> syncToBridge(YtdlpProvider ytdlp) async {
    try {
      final cookies = await load();
      ytdlp.setAccountCookies(cookies);
      if (looksSignedIn(cookies)) {
        await ytdlp.newpipe.setAccountCookies(cookies);
      } else {
        await ytdlp.newpipe.clearAccountCookies();
      }
    } on Object {
      // Account sync never breaks startup.
    }
  }
}

/// Whether a YouTube session is stored (refresh via invalidate).
final FutureProvider<bool> ytAccountStatusProvider =
    FutureProvider<bool>((ref) async {
      final cookies = await YouTubeAccount.load();
      return YouTubeAccount.looksSignedIn(cookies);
    });
