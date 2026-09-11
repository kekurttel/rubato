/// Aurora MusicProvider plugin interface + registry (spec section 7).
library;

export 'package:aurora_core/aurora_core.dart'
    show
        Album,
        AppError,
        AppErrorCode,
        AppException,
        Artist,
        Artwork,
        Failure,
        MediaHandle,
        MediaHandleKind,
        PlaySource,
        ProviderHealth,
        Quality,
        Result,
        SearchPage,
        SearchQuery,
        SearchType,
        Success,
        Track;
export 'src/models.dart';
export 'src/music_provider.dart';
export 'src/provider_registry.dart';
