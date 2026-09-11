import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/search/search_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raw search text (set by the field after a 220 ms debounce).
final StateProvider<String> searchTextProvider = StateProvider<String>(
  (ref) => '',
);

/// Active search tab.
final StateProvider<SearchTab> searchTabProvider = StateProvider<SearchTab>(
  (ref) => SearchTab.songs,
);

/// Airplane/offline flag (app lane mirrors provider health here).
///
/// Drives the offline badge + banner; search still serves local FTS.
final StateProvider<bool> isOfflineProvider = StateProvider<bool>(
  (ref) => false,
);

/// Search boundary (null until the app lane injects the repositories).
final Provider<CatalogSearchService?> catalogSearchServiceProvider =
    Provider<CatalogSearchService?>((ref) => null);

/// Row actions boundary (null until the app lane injects it).
final Provider<SearchActions?> searchActionsProvider = Provider<SearchActions?>(
  (ref) => null,
);

/// Whether [text] is a runnable query (min 2 chars, spec section 11).
bool isRunnableQuery(String text) => text.trim().length >= 2;

/// Local FTS results for the current query (null when idle/unwired).
final FutureProvider<SearchPage?> localResultsProvider =
    FutureProvider<SearchPage?>((ref) async {
      final text = ref.watch(searchTextProvider).trim();
      if (!isRunnableQuery(text)) {
        return null;
      }
      final service = ref.watch(catalogSearchServiceProvider);
      if (service == null) {
        return null;
      }
      return service.searchLocal(SearchQuery(text: text));
    });

/// Online (yt-dlp) results for the current query (null when idle).
final FutureProvider<SearchPage?> onlineResultsProvider =
    FutureProvider<SearchPage?>((ref) async {
      final text = ref.watch(searchTextProvider).trim();
      if (!isRunnableQuery(text)) {
        return null;
      }
      final service = ref.watch(catalogSearchServiceProvider);
      if (service == null) {
        return null;
      }
      return service.searchOnline(SearchQuery(text: text));
    });

/// Online reachability (offline until the service is wired).
final StreamProvider<ProviderHealth> onlineHealthProvider =
    StreamProvider<ProviderHealth>((ref) {
      final service = ref.watch(catalogSearchServiceProvider);
      if (service == null) {
        return Stream<ProviderHealth>.value(ProviderHealth.offline);
      }
      return service.onlineHealth();
    });
