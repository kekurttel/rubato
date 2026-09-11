import 'package:aurora_mobile/features/now_playing/now_playing_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Player boundary (null until the app lane injects the controller).
final Provider<NowPlayingService?> nowPlayingServiceProvider =
    Provider<NowPlayingService?>((ref) => null);

/// Live player frames (idle until the service is wired).
final StreamProvider<NowPlayingInfo> nowPlayingProvider =
    StreamProvider<NowPlayingInfo>((ref) {
      final service = ref.watch(nowPlayingServiceProvider);
      if (service == null) {
        return Stream<NowPlayingInfo>.value(const NowPlayingInfo.idle());
      }
      return service.watch();
    });
