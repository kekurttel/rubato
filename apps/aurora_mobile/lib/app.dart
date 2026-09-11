import 'dart:async';

import 'package:aurora_mobile/features/home/home_providers.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:aurora_mobile/features/you/you_providers.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_mobile/router.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget: Aurora theme + go_router configuration.
///
/// Riverpod overrides (clock, database, provider registry, audio
/// handler per spec section 14) attach at the `ProviderScope` in
/// `main.dart` once those providers exist (Phase 1).
class AuroraApp extends ConsumerStatefulWidget {
  /// Creates the root widget.
  const AuroraApp({super.key});

  @override
  ConsumerState<AuroraApp> createState() => _AuroraAppState();
}

class _AuroraAppState extends ConsumerState<AuroraApp> {
  @override
  void initState() {
    super.initState();
    // Cold-start budget (spec section 15): the MediaStore scan runs
    // after the first frame, never in `main()`.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scanOnce());
  }

  /// Indexes the device library exactly once per process.
  Future<void> _scanOnce() async {
    if (!mounted || ref.read(hasScannedProvider)) {
      return;
    }
    final wiring = ref.read(auroraWiringProvider);
    if (wiring == null) {
      return;
    }
    ref.read(hasScannedProvider.notifier).state = true;
    final result = await scanDeviceLibrary(wiring);
    if (!mounted) {
      return;
    }
    ref.read(libraryScanStateProvider.notifier).state = result;
    if (result.status == DeviceLibraryScanStatus.ok) {
      invalidateLibraryAfterScan(ref);
    }
    unawaited(
      enrichHomeWithOnlineRecommendations(wiring).then((_) {
        if (mounted) {
          ref.invalidate(homeEntriesProvider);
        }
      }).catchError((Object _) {}),
    );
    unawaited(
      enrichYtMusicCharts(wiring).then((_) {
        if (mounted) {
          ref.invalidate(homeEntriesProvider);
        }
      }).catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);
    return MaterialApp.router(
      title: 'Rubato',
      theme: buildAuroraTheme(accent: accent),
      routerConfig: auroraRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
