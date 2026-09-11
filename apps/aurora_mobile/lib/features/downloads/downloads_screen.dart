import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/downloads/download_providers.dart';
import 'package:aurora_mobile/features/downloads/download_settings_strip.dart';
import 'package:aurora_mobile/features/downloads/downloads_service.dart';
import 'package:aurora_mobile/features/search/search_providers.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Human label for a [DownloadState].
String downloadStateLabel(DownloadState state) => switch (state) {
  DownloadState.queued => 'Queued',
  DownloadState.fetchingMeta => 'Fetching info',
  DownloadState.downloading => 'Downloading',
  DownloadState.verifying => 'Verifying',
  DownloadState.completed => 'Downloaded',
  DownloadState.paused => 'Paused',
  DownloadState.failed => 'Failed',
  DownloadState.canceled => 'Canceled',
  DownloadState.fileMissing => 'File missing',
};

/// Downloads tab: settings strip + active / completed job lists.
///
/// Job control (pause / resume / retry / cancel) delegates to the
/// injected queue service; the airplane badge + banner mirror the
/// shared offline flag so the tab stays honest without a route.
class DownloadsScreen extends ConsumerWidget {
  /// Creates the downloads screen.
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Surface terminal job failures as snackbars with the actual
    // reason (the per-job row already shows it persistently); only
    // newly-failed jobs snack, so rebuilds never repeat them. A
    // `permission` failure while a custom SAF folder is active means
    // the tree grant was revoked: fall back to app-private storage so
    // future jobs have a writable dir, then explain with a second
    // snackbar (the first already carried the typed failure reason).
    ref.listen(downloadJobsProvider, (previous, next) {
      final before = <String>{
        for (final job in previous?.valueOrNull ?? const <DownloadJob>[])
          if (job.state == DownloadState.failed) job.id,
      };
      for (final job in next.valueOrNull ?? const <DownloadJob>[]) {
        if (job.state == DownloadState.failed && !before.contains(job.id)) {
          final reason = job.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                reason == null || reason.isEmpty
                    ? 'Download failed'
                    : 'Download failed: $reason',
              ),
            ),
          );
          if (job.errorCode == AppErrorCode.permission.name &&
              ref.read(downloadLocationProvider) == DownloadLocation.custom) {
            unawaited(
              ref
                  .read(downloadLocationProvider.notifier)
                  .fallBackToAppPrivate()
                  .then((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Lost access to the chosen folder — using '
                            'app-private storage. Pick the folder again '
                            'to restore it.',
                          ),
                        ),
                      );
                    }
                  }),
            );
          }
        }
      }
    });
    final offline = ref.watch(isOfflineProvider);
    final active = ref.watch(activeDownloadJobsProvider);
    final finished = ref.watch(finishedDownloadJobsProvider);
    return AuroraScaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [OfflineBadge(offline: offline)],
      ),
      body: ListView(
        children: [
          if (offline)
            const OfflineBanner(
              message: 'You are offline — new downloads wait for a connection.',
            ),
          const DownloadSettingsStrip(),
          const SectionHeader(title: 'Active'),
          if (active.isEmpty)
            const EmptyState(
              title: 'Nothing downloading',
              message: 'Use Search to stream or save songs for offline.',
              icon: Icons.download_outlined,
            )
          else
            for (final job in active) _DownloadJobTile(job: job),
          const SectionHeader(title: 'Completed'),
          if (finished.isEmpty)
            const EmptyState(
              title: 'No finished downloads yet',
              message: 'Verified files land here.',
              icon: Icons.download_done_outlined,
            )
          else
            for (final job in finished) _DownloadJobTile(job: job),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// One queue row: glyph, progress, and state-appropriate controls.
class _DownloadJobTile extends ConsumerWidget {
  /// Creates a job row.
  const _DownloadJobTile({required this.job});

  /// Job to render.
  final DownloadJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(downloadsServiceProvider);
    if (service == null) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<String?>(
      future: service.trackTitle(job.trackId),
      builder: (context, snapshot) {
        final title = snapshot.data?.trim();
        return _buildRow(
          context,
          service,
          (title == null || title.isEmpty) ? job.trackId : title,
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    DownloadsService service,
    String title,
  ) {
    final subtitle = job.errorMessage?.isNotEmpty ?? false
        ? '${downloadStateLabel(job.state)} · ${job.errorMessage}'
        : downloadStateLabel(job.state);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          DownloadGlyph(
            state: job.state,
            progress: job.progress,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AuroraType.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AuroraType.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (job.isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: job.progress.clamp(0, 1).toDouble(),
                    ),
                  ),
              ],
            ),
          ),
          ..._controls(service),
        ],
      ),
    );
  }

  List<Widget> _controls(DownloadsService? service) {
    if (service == null) {
      return const <Widget>[];
    }
    switch (job.state) {
      case DownloadState.queued:
      case DownloadState.fetchingMeta:
      case DownloadState.downloading:
      case DownloadState.verifying:
        return [
          IconButton(
            onPressed: () => service.pause(job.id),
            icon: const Icon(Icons.pause_outlined),
            tooltip: 'Pause',
          ),
          IconButton(
            onPressed: () => service.cancel(job.id),
            icon: const Icon(Icons.close_outlined),
            tooltip: 'Cancel',
          ),
        ];
      case DownloadState.paused:
        return [
          IconButton(
            onPressed: () => service.resume(job.id),
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: 'Resume',
          ),
          IconButton(
            onPressed: () => service.cancel(job.id),
            icon: const Icon(Icons.close_outlined),
            tooltip: 'Cancel',
          ),
        ];
      case DownloadState.failed:
      case DownloadState.canceled:
      case DownloadState.fileMissing:
        return [
          IconButton(
            onPressed: () => service.retry(job.id),
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Retry',
          ),
        ];
      case DownloadState.completed:
        return const <Widget>[];
    }
  }
}
