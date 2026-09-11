import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_music_source/aurora_music_source.dart';
import 'package:aurora_music_source_ytdlp/src/explode_client.dart';
import 'package:aurora_music_source_ytdlp/src/invidious_search.dart';
import 'package:aurora_music_source_ytdlp/src/newpipe_bridge.dart';
import 'package:aurora_music_source_ytdlp/src/piped_streams.dart';
import 'package:aurora_music_source_ytdlp/src/process_runner.dart';
import 'package:aurora_music_source_ytdlp/src/stream_resolver.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_binary.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_quality.dart';
import 'package:aurora_music_source_ytdlp/src/ytdlp_search.dart';
import 'package:aurora_music_source_ytdlp/src/ytmusic_account_client.dart';
import 'package:flutter/foundation.dart';

/// Online provider backed by the yt-dlp CLI (lawful-use only).
///
/// - [id] is `ytdlp`; search, download, and streaming are all supported.
/// - Desktop (binary present): `ytsearchN` + `--flat-playlist --dump-json`,
///   `yt-dlp -g` stream URLs, CLI downloads (existing behavior).
/// - Android (no binary): Piped API search first (device-proven, no
///   binary, no Rhino), then the native NewPipe Extractor bridge, then
///   Invidious search, with the pure-Dart [ExplodeClient]
///   streams/details fallback, using the
///   same Track keys (`providerId=ytdlp`, `sourceTrackId=<videoId>`) and
///   the same 6h stream TTL, so UI, DB, and artwork caches are untouched.
///   The CLI stays last resort and never masks earlier runtimes: every
///   search failure is caught as Object and the final error lists which
///   runtimes failed and why.
/// - [resolvePlayable] returns the direct best-audio URL as
///   [MediaHandleKind.authorizedStream] (`expiresAt = now + 6h`), or the
///   verified on-disk file as [MediaHandleKind.localFile].
/// - [artwork] serves the highest-resolution thumbnail cached from
///   search/detail dumps (no extra fetch, no scraping).
/// - [health] is online when the network probe succeeds (binary OR
///   pure-Dart path); otherwise offline (UI falls back to library mode).
///
/// Audio-only, `--no-playlist` by default: no video downloads, no DRM
/// bypass, no private clients, no bundled copyrighted URLs.
final class YtdlpProvider extends MusicProvider {
  /// Creates the provider (inject fakes in tests).
  YtdlpProvider({
    YtdlpBinary? binary,
    YtdlpSearch? search,
    YtdlpStreamResolver? resolver,
    YtdlpProcessRunner? runner,
    ExplodeClient? explode,
    NewPipeBridge? newpipe,
    InvidiousSearchClient? invidious,
    YtMusicAccountClient? account,
    this.pipedStreams,
    this.clock = const SystemClock(),
  }) : binary = binary ?? YtdlpBinary(),
       searcher = search ?? YtdlpSearch(),
       streamResolver = resolver ?? YtdlpStreamResolver(),
       explode = explode ?? ExplodeClient(),
       newpipe = newpipe ?? NewPipeBridge(),
       invidious = invidious ?? InvidiousSearchClient(),
       account = account ?? YtMusicAccountClient(),
       _runner = runner ?? const SystemProcessRunner();

  /// Binary locator.
  final YtdlpBinary binary;

  /// Search delegate (also owns the thumbnail cache).
  final YtdlpSearch searcher;

  /// Stream/local-file resolver.
  final YtdlpStreamResolver streamResolver;

  /// Pure-Dart fallback used when no CLI binary resolves.
  final ExplodeClient explode;

  /// Native NewPipe runtime, preferred on Android (bot-gated explode
  /// manifests return HTTP 403 on-device); falls back to [explode].
  final NewPipeBridge newpipe;

  /// Invidious fallback search (after Piped + NewPipe, before CLI).
  final InvidiousSearchClient invidious;

  /// Piped proxy streams (first pick; shares `explode.pipedSearch`'s
  /// last-good mirror when null and constructed per call).
  final PipedStreamsClient? pipedStreams;

  /// Authenticated YouTube Music client (account home + library).
  ///
  /// Session cookies arrive via [setAccountCookies] from the app layer
  /// after login; empty = signed out (public catalog only).
  final YtMusicAccountClient account;

  /// Stores the account session for [account] and the Dart
  /// googlevideo downloader (never throws).
  void setAccountCookies(Map<String, String> cookies) {
    try {
      final copy = Map<String, String>.from(cookies);
      account.accountCookies = copy;
      explode.accountCookies = copy;
    } on Object {
      // Session sync never breaks the provider.
    }
  }

  /// Injectable clock for entity timestamps.
  final Clock clock;

  final YtdlpProcessRunner _runner;

  /// Artist rows synthesized from search dumps (by artist sourceId).
  final Map<String, Artist> _knownArtists = <String, Artist>{};

  @override
  String get id => ytdlpProviderId;

  @override
  String get displayName => 'Online (yt-dlp)';

  @override
  bool get supportsDownload => true;

  @override
  bool get supportsSearch => true;

  @override
  bool get supportsStream => true;

  /// Current reachability (network probe; binary optional); never throws.
  Future<ProviderHealth> checkHealth() async {
    try {
      return await YtdlpConnectivity.isReachable()
          ? ProviderHealth.online
          : ProviderHealth.offline;
    } on Object {
      return ProviderHealth.offline;
    }
  }

  @override
  Stream<ProviderHealth> health() async* {
    yield await checkHealth();
  }

  @override
  Future<Result<SearchPage, AppError>> search(SearchQuery query) async {
    // Runtime order (device-proven): Piped first (no binary, no Rhino,
    // worked weeks ago with covers), then the NewPipe bridge (instant-fail
    // on this network, so it never costs time), then Invidious (last
    // hosted resort), then the yt-dlp CLI last (needs a binary that is
    // never bundled on-device, so it can never succeed on a phone).
    // Every runtime failure is caught as Object (an Error such as
    // TypeError/ArgumentError must not escape and kill the chain) and
    // recorded; the final Failure lists which runtimes failed and why.
    // A genuine empty (all reachable runtimes returned zero hits) stays
    // a Success with an empty page so the UI shows "no results", not an
    // error banner.
    final causes = <String>[];
    var pipedEmpty = false;
    var newpipeEmpty = false;
    var invidiousEmpty = false;

    // 1. Piped: this IS the explode search runtime (`youtube_explode_dart`
    // search parsing is broken against current markup, so
    // `explode.searchVideos` is Piped-backed by design; streams/details
    // stay on explode).
    try {
      final piped = await explode.searchVideos(
        query.text,
        limit: query.limit.clamp(1, 20),
      );
      switch (piped) {
        case Success(value: final videos):
          if (videos.isNotEmpty) {
            return Success(_pageFromHits(query, videos));
          }
          pipedEmpty = true;
        case Failure(:final error):
          causes.add(_shortPiped(error));
      }
    } on Object catch (error) {
      causes.add('Piped: ${NewPipeBridge.shortCause(error)}');
    }

    // 2. NewPipe bridge (Android native extractor). An empty return
    // covers both "no results" (lastError == null, genuine) and a
    // failed bridge call (lastError set); only the latter is a cause.
    try {
      var available = false;
      try {
        available = await newpipe.isAvailable;
      } on Object {
        available = false;
      }
      if (available) {
        final hits = await newpipe.searchVideos(
          query.text,
          limit: query.limit.clamp(1, 20),
        );
        if (hits.isNotEmpty) {
          try {
            return Success(_pageFromHits(query, hits));
          } on Object catch (error) {
            causes.add('NewPipe: ${NewPipeBridge.shortCause(error)}');
          }
        } else {
          final cause = newpipe.lastError;
          if (cause == null || cause.trim().isEmpty) {
            newpipeEmpty = true;
          } else {
            final trimmed = cause.trim();
            causes.add(
              trimmed.startsWith('NewPipe') || trimmed.startsWith('Bridge')
                  ? (trimmed.startsWith('Bridge')
                        ? 'NewPipe: $trimmed'
                        : trimmed)
                  : 'NewPipe: $trimmed',
            );
          }
        }
      } else {
        causes.add('NewPipe: unavailable');
      }
    } on Object catch (error) {
      causes.add('NewPipe: ${NewPipeBridge.shortCause(error)}');
    }

    // 3. Invidious (last hosted resort: NewPipe above is instant-fail on
    // this network, so this never costs time when the bridge is down).
    try {
      final iv = await invidious.searchVideos(
        query.text,
        limit: query.limit.clamp(1, 20),
      );
      switch (iv) {
        case Success(value: final videos):
          if (videos.isNotEmpty) {
            return Success(_pageFromHits(query, videos));
          }
          invidiousEmpty = true;
        case Failure(:final error):
          causes.add(_shortInvidious(error));
      }
    } on Object catch (error) {
      causes.add('Invidious: ${NewPipeBridge.shortCause(error)}');
    }

    // 4. CLI last resort (binary present on desktop/dev only).
    try {
      var cliAvailable = false;
      try {
        cliAvailable = await binary.isAvailable;
      } on Object {
        cliAvailable = false;
      }
      if (cliAvailable) {
        final cli = await searcher.search(query);
        switch (cli) {
          case Success(value: final page):
            for (final artist in page.artists) {
              _knownArtists[artist.sourceId] = artist;
            }
            return Success(page);
          case Failure(:final error):
            causes.add(_shortCli(error));
        }
      } else {
        causes.add('CLI: no binary');
      }
    } on Object catch (error) {
      causes.add('CLI: ${NewPipeBridge.shortCause(error)}');
    }

    if (causes.isEmpty && (pipedEmpty || newpipeEmpty || invidiousEmpty)) {
      return Success(_pageFromHits(query, const <ExplodeVideoHit>[]));
    }
    final message = causes.isEmpty
        ? 'Online search failed'
        : causes.join(' · ');
    return Failure(
      AppError(
        code: AppErrorCode.network,
        message: message,
        details: 'ytdlp:search-exit',
      ),
    );
  }

  /// Short `Piped: ...` cause for [error] (≤90 chars, no newlines).
  String _shortPiped(AppError error) {
    if (error.details == 'ytdlp:query-too-short') {
      return 'Piped: query too short';
    }
    if (error.details == 'ytdlp:search-exit') {
      final pipedCause = explode.pipedSearch.lastFailure;
      if (pipedCause != null && pipedCause.trim().isNotEmpty) {
        final short = pipedCause.trim();
        return short.length > 82
            ? 'Piped: ${short.substring(0, 82)}…'
            : 'Piped: $short';
      }
      return 'Piped: all mirrors unreachable';
    }
    final base = error.message.trim().replaceAll(RegExp(r'\s+'), ' ');
    final short = base.length > 82 ? '${base.substring(0, 82)}…' : base;
    return 'Piped: $short';
  }

  /// Short `Invidious: ...` cause for [error] (≤90 chars, no newlines).
  String _shortInvidious(AppError error) {
    if (error.details == 'ytdlp:query-too-short') {
      return 'Invidious: query too short';
    }
    if (error.details == 'ytdlp:invidious-search-exit') {
      final ivCause = invidious.lastFailure;
      if (ivCause != null && ivCause.trim().isNotEmpty) {
        final short = ivCause.trim();
        return short.length > 78
            ? 'Invidious: ${short.substring(0, 78)}…'
            : 'Invidious: $short';
      }
      return 'Invidious: all mirrors unreachable';
    }
    final base = error.message.trim().replaceAll(RegExp(r'\s+'), ' ');
    final short = base.length > 78 ? '${base.substring(0, 78)}…' : base;
    return 'Invidious: $short';
  }

  /// Short `CLI: ...` cause for [error] (≤90 chars, no newlines).
  static String _shortCli(AppError error) {
    if (error.details == 'ytdlp:missing-binary') {
      return 'CLI: no binary';
    }
    final base = error.message.trim().replaceAll(RegExp(r'\s+'), ' ');
    final short = base.length > 84 ? '${base.substring(0, 84)}…' : base;
    return 'CLI: $short';
  }

  /// Maps [videos] to a [SearchPage] (CLI page shape), filling the
  /// thumbnail cache; shared by the NewPipe and explode runtimes.
  SearchPage _pageFromHits(SearchQuery query, List<ExplodeVideoHit> videos) {
    final now = clock.nowUtc();
    final tracks = <Track>[];
    final artists = <Artist>[];
    final seenArtists = <String>{};
    for (final hit in videos) {
      if (hit.thumbnailUrl.isNotEmpty) {
        searcher.artworkByVideoId[hit.videoId] = hit.thumbnailUrl;
      }
      final artist = _artistForHit(hit);
      if (query.types.contains(SearchType.track) &&
          tracks.length < query.limit) {
        tracks.add(_trackForHit(hit, artist, now));
      }
      if (query.types.contains(SearchType.artist) &&
          artist != null &&
          seenArtists.add(artist.sourceId) &&
          artists.length < query.limit) {
        artists.add(artist);
      }
    }
    return SearchPage(
      providerId: ytdlpProviderId,
      fetchedAt: now,
      tracks: tracks,
      artists: artists,
    );
  }

  /// Maps one explode hit to a [Track] (CLI `trackFromEntry` equivalent).
  static Track _trackForHit(
    ExplodeVideoHit hit,
    Artist? artist,
    DateTime now,
  ) {
    return Track(
      id: AuroraIds.trackId(ytdlpProviderId, hit.videoId),
      providerId: ytdlpProviderId,
      sourceTrackId: hit.videoId,
      title: hit.title,
      createdAt: now,
      updatedAt: now,
      durationMs: hit.durationMs,
      artistIds: artist == null ? const <String>[] : <String>[artist.id],
    );
  }

  /// Derives the uploader as an [Artist] (null when unnamed).
  static Artist? _artistForHit(ExplodeVideoHit hit) {
    final name = hit.uploader.trim();
    if (name.isEmpty) {
      return null;
    }
    final key = hit.channelId.isNotEmpty ? hit.channelId : _slug(name);
    final sourceId = 'channel-$key';
    return Artist(
      id: AuroraIds.trackId(ytdlpProviderId, sourceId),
      name: name,
      sourceId: sourceId,
      providerId: ytdlpProviderId,
    );
  }

  static String _slug(String raw) {
    final slug = raw
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'unknown' : slug;
  }

  @override
  Future<Result<Track, AppError>> getTrack(String sourceId) async {
    if (await binary.isAvailable) {
      return _cliGetTrack(sourceId);
    }
    // The bridge has no detail lookup: search the id and keep the
    // exact video-id match (YouTube returns the video itself first).
    if (await newpipe.isAvailable) {
      final hits = await newpipe.searchVideos(sourceId, limit: 5);
      ExplodeVideoHit? match;
      for (final hit in hits) {
        if (hit.videoId == sourceId) {
          match = hit;
          break;
        }
      }
      if (match != null) {
        final now = clock.nowUtc();
        final artist = _artistForHit(match);
        if (artist != null) {
          _knownArtists[artist.sourceId] = artist;
        }
        searcher.artworkByVideoId[match.videoId] = match.thumbnailUrl;
        return Success(_trackForHit(match, artist, now));
      }
    }
    final result = await explode.getVideo(sourceId);
    switch (result) {
      case Failure(:final error):
        return Failure(error);
      case Success(value: final hit):
        if (hit == null) {
          return Failure(
            AppError(
              code: AppErrorCode.notFound,
              message: 'Online track not found',
              details: sourceId,
            ),
          );
        }
        final now = clock.nowUtc();
        final artist = _artistForHit(hit);
        if (artist != null) {
          _knownArtists[artist.sourceId] = artist;
        }
        searcher.artworkByVideoId[hit.videoId] = hit.thumbnailUrl;
        return Success(_trackForHit(hit, artist, now));
    }
  }

  /// CLI detail lookup (binary present).
  Future<Result<Track, AppError>> _cliGetTrack(String sourceId) async {
    final resolved = await binary.resolve();
    if (resolved == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'yt-dlp binary not found (install it or set a path)',
          details: 'ytdlp:missing-binary',
        ),
      );
    }
    late final YtdlpProcessResult dump;
    try {
      dump = await _runner.run(resolved, <String>[
        '--dump-json',
        '--no-playlist',
        '--no-warnings',
        '--skip-download',
        YtdlpStreamResolver.videoUrl(sourceId),
      ]);
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Track lookup timed out',
          details: 'ytdlp:detail-timeout',
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
    if (!dump.isSuccess) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'Online track not found',
          details: sourceId,
        ),
      );
    }
    try {
      final decoded = jsonDecode(dump.stdout.trim());
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('expected a JSON object');
      }
      final now = clock.nowUtc();
      final track = YtdlpSearch.trackFromEntry(decoded, now);
      if (track == null) {
        return Failure(
          AppError(
            code: AppErrorCode.notFound,
            message: 'Online track not found',
            details: sourceId,
          ),
        );
      }
      final thumb = YtdlpSearch.bestThumbnail(decoded['thumbnails']);
      if (thumb != null) {
        searcher.artworkByVideoId[track.sourceTrackId] = thumb;
      }
      final artist = YtdlpSearch.artistFromEntry(decoded);
      if (artist != null) {
        _knownArtists[artist.sourceId] = artist;
      }
      return Success(track);
    } on FormatException catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.provider,
          message: 'Provider returned unreadable track metadata',
          details: 'ytdlp:detail-parse',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<ArtistDetails, AppError>> getArtist(String sourceId) async {
    final artist = _knownArtists[sourceId];
    if (artist == null) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message:
              'Artist is only known after an online search '
              '(search first, then open the artist)',
          details: sourceId,
        ),
      );
    }
    return Success(ArtistDetails(artist: artist));
  }

  @override
  Future<Result<AlbumDetails, AppError>> getAlbum(String sourceId) async {
    return Failure(
      AppError(
        code: AppErrorCode.provider,
        message: 'Album pages are not supported by online search in v1',
        details: sourceId,
      ),
    );
  }

  @override
  Future<Result<MediaHandle, AppError>> resolvePlayable(
    Track track,
    Quality quality,
  ) async {
    // Never throws: every escaping Error becomes a typed Failure so the
    // controller's item-error path (not a crash) surfaces it.
    try {
      var binaryAvailable = false;
      try {
        binaryAvailable = await binary.isAvailable;
      } on Object {
        binaryAvailable = false;
      }
      if (binaryAvailable) {
        return streamResolver.resolve(track, quality);
      }
      final localPath = track.localPath;
      if (localPath != null && localPath.isNotEmpty) {
        // Single existence probe per resolve, off the UI isolate.
        try {
          // Single probe per resolve, off the UI isolate.
          // ignore: avoid_slow_async_io
          if (await File(localPath).exists()) {
            return Success(
              MediaHandle(
                kind: MediaHandleKind.localFile,
                uri: localPath,
                qualityLabel: quality.name,
              ),
            );
          }
        } on Object {
          // Fall through to the stream runtimes below.
        }
      }
      final stream = await _bestAudio(track.sourceTrackId, quality);
      switch (stream) {
        case Failure(:final error):
          developer.log(
            'resolvePlayable fail vid=${track.sourceTrackId} '
            'err=${error.code.name}:${error.details}',
            name: 'AURORA_DIAG',
          );
          return Failure(error);
        case Success(value: final audio):
          final host = Uri.tryParse(audio.url)?.host ?? '?';
          developer.log(
            'resolvePlayable ok vid=${track.sourceTrackId} host=$host '
            'kbps=${audio.bitrateKbps} ext=${audio.containerName} '
            'len=${audio.url.length}',
            name: 'AURORA_DIAG',
          );
          return Success(
            MediaHandle(
              kind: MediaHandleKind.authorizedStream,
              uri: audio.url,
              expiresAt: clock.nowUtc().add(YtdlpStreamResolver.streamTtl),
              mimeType: YtdlpQualityFormats.mimeTypeFor(quality),
              qualityLabel: quality.name,
            ),
          );
      }
    } on Object catch (e) {
      return Failure(
        AppError(
          code: AppErrorCode.network,
          message: 'Online resolve failed (${NewPipeBridge.shortCause(e)})',
          details: 'ytdlp:resolve-exit',
          cause: e,
        ),
      );
    }
  }

  /// Best audio via NewPipe first, then Piped proxy, then explode.
  ///
  /// Resolve order is bridge → piped-proxy → explode-direct.
  /// On Android, NewPipe bridge runs locally and extracts direct
  /// googlevideo streams; if unavailable or failing, Piped proxy is tried,
  /// followed by explode direct.
  /// When all runtimes fail, the single returned error names all causes.
  /// Never throws: availability probes are `Object`-guarded.
  Future<Result<ExplodeAudioStream, AppError>> _bestAudio(
    String videoId,
    Quality quality,
  ) async {
    developer.log(
      'provider _bestAudio vid=$videoId q=${quality.name}',
      name: 'AURORA_DIAG',
    );
    String? newpipeCause;
    var bridgeOk = false;
    try {
      bridgeOk = await newpipe.isAvailable;
    } on Object {
      bridgeOk = false;
    }
    if (bridgeOk) {
      final viaNewPipe = await newpipe.bestAudio(videoId, quality);
      if (viaNewPipe != null) {
        final host = Uri.tryParse(viaNewPipe.url)?.host ?? '?';
        developer.log(
          'provider pick=newpipe vid=$videoId host=$host '
          'kbps=${viaNewPipe.bitrateKbps} ext=${viaNewPipe.containerName}',
          name: 'AURORA_DIAG',
        );
        return Success(viaNewPipe);
      }
      newpipeCause = newpipe.lastError ?? 'NewPipe failed';
      developer.log(
        'provider newpipe null vid=$videoId cause=$newpipeCause '
        'fallback=piped',
        name: 'AURORA_DIAG',
      );
    } else {
      newpipeCause = 'Bridge unavailable';
    }
    var pipedCause = 'Piped: failed';
    try {
      final streamsClient =
          pipedStreams ?? PipedStreamsClient(searchClient: explode.pipedSearch);
      final viaPiped = await streamsClient.streamsFor(videoId, quality);
      switch (viaPiped) {
        case Success(value: final piped):
          final host = Uri.tryParse(piped.proxyUrl)?.host ?? '?';
          debugPrint(
            'AURORA_DIAG provider pick=piped vid=$videoId host=$host '
            'kbps=${piped.bitrateKbps} ext=${piped.ext}',
          );
          return Success(
            ExplodeAudioStream(
              url: piped.proxyUrl,
              bitrateKbps: piped.bitrateKbps,
              containerName: piped.ext,
            ),
          );
        case Failure(:final error):
          pipedCause = PipedStreamsClient.shortFailure(error);
          debugPrint(
            'AURORA_DIAG provider piped null vid=$videoId cause=$pipedCause '
            'fallback=explode',
          );
      }
    } on Object catch (error) {
      pipedCause = 'Piped: ${NewPipeBridge.shortCause(error)}';
      debugPrint(
        'AURORA_DIAG provider piped error vid=$videoId cause=$pipedCause '
        'fallback=explode',
      );
    }
    final fb = await explode.bestAudio(videoId, quality);
    switch (fb) {
      case Success(value: final s):
        final host = Uri.tryParse(s.url)?.host ?? '?';
        developer.log(
          'provider pick=explode vid=$videoId host=$host '
          'kbps=${s.bitrateKbps}',
          name: 'AURORA_DIAG',
        );
      case Failure(:final error):
        final combined =
            '${NewPipeBridge.describeFailure(
              newpipeCause: newpipeCause,
              explodeError: error,
            )} · $pipedCause';
        developer.log(
          'provider explode fail vid=$videoId err=$combined',
          name: 'AURORA_DIAG',
        );
        return Failure(
          AppError(
            code: error.code,
            message: combined,
            details: error.details,
            cause: error.cause,
          ),
        );
    }
    return fb;
  }

  @override
  Future<Result<Artwork, AppError>> artwork(Track track) async {
    final url = searcher.artworkByVideoId[track.sourceTrackId];
    if (url == null || url.isEmpty) {
      return Failure(
        AppError(
          code: AppErrorCode.notFound,
          message: 'No cached artwork for this online track',
          details: track.id,
        ),
      );
    }
    return Success(
      Artwork(
        id: 'ytdlp-art-${track.sourceTrackId}',
        updatedAt: clock.nowUtc(),
        url: url,
      ),
    );
  }
}
