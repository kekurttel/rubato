/// Discriminated-union result type used by every fallible public API.
///
/// Prefer returning [Result] over throwing: callers are forced to handle
/// the failure branch. `AppException` exists only at trust boundaries
/// (isolates, platform channels) where a thrown error is unavoidable.
sealed class Result<T, E> {
  /// Creates a result. See [Success] and [Failure].
  const Result();

  /// Whether this is a [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Whether this is a [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// The success value, or `null` on failure.
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// The failure value, or `null` on success.
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  /// Folds both branches into a single value.
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) =>
      switch (this) {
        Success(:final value) => onSuccess(value),
        Failure(:final error) => onFailure(error),
      };

  /// Maps the success value, preserving failures.
  Result<U, E> map<U>(U Function(T value) transform) => switch (this) {
    Success(:final value) => Success<U, E>(transform(value)),
    Failure(:final error) => Failure<U, E>(error),
  };

  /// Maps the failure value, preserving successes.
  Result<T, F> mapError<F>(F Function(E error) transform) => switch (this) {
    Success(:final value) => Success<T, F>(value),
    Failure(:final error) => Failure<T, F>(transform(error)),
  };

  /// Chains a fallible computation on success (short-circuits on failure).
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) transform) =>
      switch (this) {
        Success(:final value) => transform(value),
        Failure(:final error) => Failure<U, E>(error),
      };

  /// Returns the success value, or [fallback] on failure.
  T getOrElse(T Function(E error) fallback) => switch (this) {
    Success(:final value) => value,
    Failure(:final error) => fallback(error),
  };

  /// Returns the success value, or throws [StateError] on failure.
  ///
  /// Use only where failure is a programming bug, never for expected
  /// errors (those stay in the [Failure] branch).
  T getOrThrow() => switch (this) {
    Success(:final value) => value,
    Failure(:final error) => throw StateError('Result failure: $error'),
  };

  /// Runs [effect] on success (for side-effect taps in a chain).
  void onSuccess(void Function(T value) effect) {
    if (this is Success<T, E>) {
      effect((this as Success<T, E>).value);
    }
  }

  /// Runs [effect] on failure (for side-effect taps in a chain).
  void onFailure(void Function(E error) effect) {
    if (this is Failure<T, E>) {
      effect((this as Failure<T, E>).error);
    }
  }
}

/// The success branch of [Result].
final class Success<T, E> extends Result<T, E> {
  /// Creates a success wrapping [value].
  const Success(this.value);

  /// The wrapped success value.
  final T value;

  @override
  String toString() => 'Success($value)';
}

/// The failure branch of [Result].
final class Failure<T, E> extends Result<T, E> {
  /// Creates a failure wrapping [error].
  const Failure(this.error);

  /// The wrapped failure value.
  final E error;

  @override
  String toString() => 'Failure($error)';
}
