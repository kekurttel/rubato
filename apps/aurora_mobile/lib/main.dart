import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_service/audio_service.dart';
import 'package:aurora_mobile/app.dart';
import 'package:aurora_mobile/bootstrap.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_playback/aurora_playback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

/// Application entry point. All initialization lives in [bootstrap] so
/// cold start stays under budget (spec section 15); widgets must never
/// do heavy work before the first frame.
///
/// Integration wiring (database, providers, playback, downloads, reco
/// scheduler) is built once here and injected as Riverpod overrides;
/// the audio-service notification bridge attaches best-effort.
Future<void> main() async {
  if (Platform.isLinux || Platform.isWindows) {
    JustAudioMediaKit.ensureInitialized();
  }
  await bootstrap();
  final wiring = await buildAuroraWiring();
  try {
    await AudioService.init(
      builder: () => wiring.audioHandler,
      config: auroraAudioServiceConfig,
    );
  } on Object catch (error) {
    debugPrint('AURORA_DIAG audio_service_init error=${error.runtimeType}');
  }
  runApp(
    ProviderScope(
      overrides: wiring.overrides(),
      child: const AuroraApp(),
    ),
  );
  if (Platform.isAndroid) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const channel = MethodChannel('aurora.player/media_store');
      unawaited(
        channel.invokeMethod<bool>('requestNotificationPermission').catchError(
          (_) => false,
        ),
      );
    });
  }
}
