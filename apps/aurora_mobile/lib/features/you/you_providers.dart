import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/you/you_service.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// You-tab boundary (null until the app lane injects it).
final Provider<YouService?> youServiceProvider = Provider<YouService?>(
  (ref) => null,
);

/// Aggregate stats (zeroed until the service is wired).
final FutureProvider<YouStats> youStatsProvider = FutureProvider<YouStats>((
  ref,
) async {
  final service = ref.watch(youServiceProvider);
  if (service == null) {
    return const YouStats(
      tracksPlayed: 0,
      minutesListened: 0,
      likeCount: 0,
      playlistCount: 0,
    );
  }
  return service.stats();
});

/// Editable mix-rate triple (spec defaults 0.70 / 0.20 / 0.10).
final StateProvider<MixRates> mixRatesProvider = StateProvider<MixRates>(
  (ref) => (
    exploitation: AuroraDefaults.exploitationRate,
    adjacent: AuroraDefaults.adjacentRate,
    exploration: AuroraDefaults.explorationRate,
  ),
);

/// Editable decay half-life in days (default 45).
final StateProvider<double> decayHalfLifeProvider = StateProvider<double>(
  (ref) => AuroraDefaults.decayHalfLifeDays,
);

/// Editable artwork cache budget in megabytes (default 300).
final StateProvider<int> cacheMbProvider = StateProvider<int>(
  (ref) => AuroraDefaults.artworkCacheMb,
);

/// Network log snapshot (updated on privacy-screen visits).
final StateProvider<List<NetworkCall>> networkLogProvider =
    StateProvider<List<NetworkCall>>((ref) => const <NetworkCall>[]);

/// SharedPreferences key for the persisted accent hex (`#RRGGBB`).
const String accentColorPrefsKey = 'aurora.accentColor';

/// One accent preset (display name + color).
final class AccentPreset {
  /// Creates a preset.
  const AccentPreset({required this.name, required this.color});

  /// Display name shown as tooltip/semantics.
  final String name;

  /// Preset color.
  final Color color;
}

/// Five warm-dark-compatible accent presets (Gold default, spec 4).
const List<AccentPreset> auroraAccentPresets = <AccentPreset>[
  AccentPreset(name: 'Gold', color: Color(0xFFE8B86D)),
  AccentPreset(name: 'Copper', color: Color(0xFFC97B4A)),
  AccentPreset(name: 'Sage', color: Color(0xFF7DCEA0)),
  AccentPreset(name: 'Slate', color: Color(0xFF7FA6C9)),
  AccentPreset(name: 'Rose', color: Color(0xFFD98A9E)),
];

/// Formats [color] as `#RRGGBB` for persistence.
String accentColorToHex(Color color) {
  final rgb = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
  return '#${rgb.toUpperCase()}';
}

/// Parses a persisted `#RRGGBB` (or `RRGGBB` / `#AARRGGBB`) hex value.
///
/// Returns null when [raw] is not a valid hex color.
Color? accentColorFromHex(String? raw) {
  if (raw == null) {
    return null;
  }
  final hex = raw.trim().replaceFirst('#', '');
  if (hex.length != 6 && hex.length != 8) {
    return null;
  }
  final value = int.tryParse(hex, radix: 16);
  if (value == null) {
    return null;
  }
  return Color(hex.length == 6 ? 0xFF000000 | value : value);
}

/// Active brand accent (default gold, spec 4).
///
/// The persisted hex is read at startup from inside this feature (no
/// `main()` changes): the first watch kicks off the async restore and
/// the state flips to the saved preset once it arrives.
final NotifierProvider<AccentColorNotifier, Color> accentColorProvider =
    NotifierProvider<AccentColorNotifier, Color>(AccentColorNotifier.new);

/// Holds the active accent + restores the persisted one.
final class AccentColorNotifier extends Notifier<Color> {
  @override
  Color build() {
    unawaited(_restore());
    return AuroraColors.accent;
  }

  /// Reads the persisted hex (best-effort; default gold stands).
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final color = accentColorFromHex(
        prefs.getString(accentColorPrefsKey),
      );
      if (color != null) {
        state = color;
      }
    } on Exception {
      // Persisted accent is best-effort; default gold stands.
    }
  }

  /// Persists [color] as the active accent.
  Future<void> setAccent(Color color) async {
    state = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(accentColorPrefsKey, accentColorToHex(color));
    } on Exception {
      // Persisted accent is best-effort; the in-memory state stands.
    }
  }
}

/// Persists [color] as the active accent.
Future<void> setAccentColor(
  AccentColorNotifier notifier,
  Color color,
) => notifier.setAccent(color);
