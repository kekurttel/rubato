import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

/// Captured output of one yt-dlp subprocess invocation.
@immutable
final class YtdlpProcessResult {
  /// Creates a captured result.
  const YtdlpProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  /// Process exit code (0 = success).
  final int exitCode;

  /// Decoded standard output.
  final String stdout;

  /// Decoded standard error.
  final String stderr;

  /// Whether the process exited successfully.
  bool get isSuccess => exitCode == 0;
}

/// Subprocess boundary for every yt-dlp call (injectable for tests).
///
/// Production code uses [SystemProcessRunner]; tests inject a fake that
/// replays canned `--dump-json` lines without spawning a binary.
abstract class YtdlpProcessRunner {
  /// Runs [executable] with [args] and captures all output.
  Future<YtdlpProcessResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  });

  /// Runs [executable] streaming output lines to [onStdoutLine].
  ///
  /// Used by the downloader to parse `[download] x%` progress. Stderr
  /// lines go to [onStderrLine] when provided.
  Future<YtdlpProcessResult> runStreaming(
    String executable,
    List<String> args, {
    void Function(String line)? onStdoutLine,
    void Function(String line)? onStderrLine,
    Duration timeout = const Duration(hours: 2),
  });
}

/// Production runner backed by `dart:io` [Process].
final class SystemProcessRunner implements YtdlpProcessRunner {
  /// Creates the production runner.
  const SystemProcessRunner();

  @override
  Future<YtdlpProcessResult> run(
    String executable,
    List<String> args, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final result = await Process.run(executable, args).timeout(timeout);
    return YtdlpProcessResult(
      exitCode: result.exitCode,
      stdout: result.stdout is String
          ? result.stdout as String
          : utf8.decode(result.stdout as List<int>, allowMalformed: true),
      stderr: result.stderr is String
          ? result.stderr as String
          : utf8.decode(result.stderr as List<int>, allowMalformed: true),
    );
  }

  @override
  Future<YtdlpProcessResult> runStreaming(
    String executable,
    List<String> args, {
    void Function(String line)? onStdoutLine,
    void Function(String line)? onStderrLine,
    Duration timeout = const Duration(hours: 2),
  }) async {
    final process = await Process.start(executable, args);
    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();
    final stdoutDone = Completer<void>();
    final stderrDone = Completer<void>();
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          stdoutBuffer.writeln(line);
          onStdoutLine?.call(line);
        }, onDone: stdoutDone.complete);
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          stderrBuffer.writeln(line);
          onStderrLine?.call(line);
        }, onDone: stderrDone.complete);
    final exitCode = await process.exitCode.timeout(timeout);
    await Future.wait([stdoutDone.future, stderrDone.future]);
    return YtdlpProcessResult(
      exitCode: exitCode,
      stdout: stdoutBuffer.toString(),
      stderr: stderrBuffer.toString(),
    );
  }
}
