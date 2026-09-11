import 'dart:async';

/// Debounced reco wake-up (spec section 14).
///
/// The playback event sink fires [schedule] after every flush burst;
/// the scheduler coalesces them into one profile update 1500 ms after
/// the last event. Pure Dart (a `Timer`), so tests drive it with
/// real short delays or a custom [delay] without any Flutter import.
final class RecoScheduler {
  /// Creates a scheduler with the spec 1500 ms debounce.
  RecoScheduler({
    this.delay = const Duration(milliseconds: 1500),
  });

  /// Debounce window after the last scheduled call.
  final Duration delay;

  Timer? _timer;
  bool _disposed = false;

  /// Whether a recompute is currently pending.
  bool get hasPending => _timer?.isActive ?? false;

  /// Schedules [work], replacing any pending call.
  void schedule(FutureOr<void> Function() work) {
    if (_disposed) {
      return;
    }
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (!_disposed) {
        unawaited(Future.sync(work));
      }
    });
  }

  /// Runs [work] immediately, dropping any pending call.
  Future<void> flushNow(FutureOr<void> Function() work) async {
    _timer?.cancel();
    _timer = null;
    if (!_disposed) {
      await work();
    }
  }

  /// Cancels pending work; the scheduler must not be reused after.
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}
