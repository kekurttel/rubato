import 'dart:io' show Platform;

import 'package:talker/talker.dart';

Talker? _talker;

/// Local-only application logger (talker, no network sink — spec 16).
///
/// Never attach a crash-reporting or analytics observer that leaves the
/// device. Never log raw file paths containing the user name; pass them
/// through [redactHomePath] first.
Talker get auroraLogger => _talker ??= Talker();

/// Initializes logging. Safe to call more than once. Does no heavy work
/// so cold start stays under budget (spec section 15).
void initAuroraLogging() {
  _talker ??= Talker();
  auroraLogger.info('Aurora logging ready (local only, no network sink).');
}

/// Replaces the OS home directory in [path] with `~` for log safety.
String redactHomePath(String path) {
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
  if (home.isEmpty || !path.startsWith(home)) {
    return path;
  }
  return '~${path.substring(home.length)}';
}
