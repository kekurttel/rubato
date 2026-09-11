import 'package:aurora_core/aurora_core.dart';
import 'package:flutter/widgets.dart';

/// One-time startup. Must stay lightweight: bindings + local logging
/// only. Database, audio session, and provider registry wire up here in
/// Phase 1 (behind async providers, never blocking the first frame).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  initAuroraLogging();
}
