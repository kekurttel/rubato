import 'dart:async';
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source_ytdlp/src/process_runner.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_version.dart';

/// Locates the yt-dlp binary and checks basic network reachability.
///
/// Provisioning story:
/// - Desktop/dev: the system `yt-dlp` on `PATH` (install per
///   https://github.com/yt-dlp/yt-dlp#installation, then verify the
///   [YtdlpVersion.pinned] pin in Settings).
/// - Android release: an app-private `bin/yt-dlp` under the app support
///   directory (shipped via the platform lane — Python runtime +
///   ffmpeg through Chaquopy/packaging, never a video pipeline).
///   This package only *looks* there; the platform lane owns the copy.
///
/// No binary is bundled with this package and no download URL is
/// hard-coded here; auto-update stays off by default.
final class YtdlpBinary {
  /// Creates a locator.
  ///
  /// [explicitPath] wins when set (Settings override). [appBinDir] is
  /// the app-private directory searched for `bin/yt-dlp` on Android.
  /// [runner] spawns `--version` probes; [clock] is unused today and
  /// reserved for cached negative lookups.
  YtdlpBinary({
    this.explicitPath,
    this.appBinDir,
    YtdlpProcessRunner? runner,
    this.clock = const SystemClock(),
  }) : _runner = runner ?? const SystemProcessRunner();

  /// Settings override path, when the user picked a binary.
  final String? explicitPath;

  /// App-private directory holding `bin/yt-dlp` (Android lane).
  final Directory? appBinDir;

  /// Injectable clock (reserved for lookup caching).
  final Clock clock;

  final YtdlpProcessRunner _runner;

  String? _cached;

  /// Resolves the binary path, or null when none is available.
  ///
  /// Order: [explicitPath] (must exist) → `bin/yt-dlp` under
  /// [appBinDir] → system `yt-dlp` on `PATH`. The result is cached for
  /// the lifetime of this object; construct a new one after installs.
  Future<String?> resolve() async {
    if (_cached != null) {
      return _cached;
    }
    final explicit = explicitPath;
    if (explicit != null && explicit.isNotEmpty) {
      // Binary probes run off the UI isolate at startup/settings time.
      // ignore: avoid_slow_async_io
      if (await File(explicit).exists()) {
        return _cached = explicit;
      }
      return null;
    }
    final appDir = appBinDir;
    if (appDir != null) {
      final bundled = File(
        '${appDir.path}${Platform.pathSeparator}bin'
        '${Platform.pathSeparator}yt-dlp',
      );
      // App-private bin probe, same off-isolate context as above.
      // ignore: avoid_slow_async_io
      if (await bundled.exists()) {
        return _cached = bundled.path;
      }
    }
    final probe = Platform.isWindows ? 'where' : 'which';
    try {
      final found = await _runner.run(probe, const ['yt-dlp']);
      if (found.isSuccess) {
        final first = found.stdout
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .firstOrNull;
        if (first != null) {
          return _cached = first;
        }
      }
    } on Object {
      // Search-path hardening (P2): a launch Error (not just Exception)
      // must degrade to "no binary", never escape the provider chain.
      return null;
    }
    return null;
  }

  /// Whether a usable binary is currently resolvable.
  Future<bool> get isAvailable async => await resolve() != null;

  /// Runs `yt-dlp --version` and compares against the pin.
  ///
  /// Returns the raw version string on success so Settings can show
  /// "installed X, pinned [YtdlpVersion.pinned]".
  Future<Result<String, AppError>> version() async {
    final binary = await resolve();
    if (binary == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'yt-dlp binary not found (install it or set a path)',
          details: 'ytdlp:missing-binary',
        ),
      );
    }
    try {
      final result = await _runner.run(binary, const ['--version']);
      if (!result.isSuccess) {
        return const Failure(
          AppError(
            code: AppErrorCode.provider,
            message: 'yt-dlp --version failed',
            details: 'ytdlp:version-probe',
          ),
        );
      }
      return Success(result.stdout.trim());
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'yt-dlp --version timed out',
          details: 'ytdlp:version-timeout',
          cause: error,
        ),
      );
    } on Exception catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.io,
          message: 'Could not launch the yt-dlp binary',
          details: 'ytdlp:launch',
          cause: error,
        ),
      );
    }
  }
}

/// Minimal reachability probe for provider health.
///
/// A DNS lookup only — no HTTP client, no accounts, no tracking. The
/// provider reports [ProviderHealth.online] only when a binary resolves
/// AND this probe succeeds; anything else is [ProviderHealth.offline]
/// so the UI falls back to library mode.
abstract final class YtdlpConnectivity {
  /// Host probed for reachability (video pages, never an API).
  static const String probeHost = 'www.youtube.com';

  /// Returns true when [probeHost] resolves within [timeout].
  static Future<bool> isReachable({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final addresses = await InternetAddress.lookup(
        probeHost,
      ).timeout(timeout);
      return addresses.isNotEmpty;
    } on Object {
      return false;
    }
  }
}
