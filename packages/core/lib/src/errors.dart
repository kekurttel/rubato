import 'package:freezed_annotation/freezed_annotation.dart';

part 'errors.freezed.dart';
part 'errors.g.dart';

/// Machine-readable error categories (spec section 5).
enum AppErrorCode {
  /// Transport / provider HTTP failure.
  network,

  /// Requested entity does not exist.
  notFound,

  /// OS permission missing or denied.
  permission,

  /// Filesystem failure.
  io,

  /// Unsupported or corrupt codec/container.
  codec,

  /// Operation was cancelled by the caller.
  cancelled,

  /// Reserved for future official provider APIs.
  unknown,

  /// Music provider rejected the call (quota, auth, unsupported op).
  provider,

  /// Local database failure.
  db,
}

/// Typed application error carried by `Result<T, AppError>`.
///
/// `cause` is excluded from JSON: errors cross isolate boundaries as
/// plain data, never with live object graphs attached.
@freezed
abstract class AppError with _$AppError {
  /// Creates an application error.
  const factory AppError({
    /// Machine-readable category.
    required AppErrorCode code,

    /// Human-readable, log-safe message (no PII, no raw file paths).
    required String message,

    /// Optional extra context (provider id, operation name, ...).
    String? details,

    /// Original exception. Never serialized, never sent anywhere.
    @JsonKey(includeFromJson: false, includeToJson: false) Object? cause,
  }) = _AppError;

  const AppError._();

  /// Deserializes an error from JSON.
  factory AppError.fromJson(Map<String, dynamic> json) =>
      _$AppErrorFromJson(json);
}

/// Thrown error wrapper for trust boundaries (isolates, platform
/// channels) where returning a `Result` is impossible.
///
/// Application code must prefer returning `Result<T, AppError>`.
class AppException implements Exception {
  /// Creates an exception wrapping [error].
  const AppException(this.error);

  /// The typed error payload.
  final AppError error;

  @override
  String toString() => 'AppException(${error.code.name}): ${error.message}';
}
