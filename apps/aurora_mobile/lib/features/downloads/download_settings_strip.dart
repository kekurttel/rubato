import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_downloads/aurora_downloads.dart';
import 'package:aurora_mobile/features/downloads/download_providers.dart';
import 'package:aurora_mobile/features/search/search_widgets.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Downloads settings strip: wifi-only, quality, concurrency, folder.
///
/// The app lane mirrors these providers into the queue manager's
/// settings (previously the strip never reached the manager, so the
/// switches were dead); the strip itself stays dependency-free.
class DownloadSettingsStrip extends ConsumerWidget {
  /// Creates the settings strip.
  const DownloadSettingsStrip({super.key});

  /// Opens the download location dialog; the custom row launches the
  /// real system folder picker (`ACTION_OPEN_DOCUMENT_TREE`).
  ///
  /// Tapping "Choose a folder…" dismisses the dialog and opens the SAF
  /// picker via [DownloadTreeChannel.pickFolder]. A picked folder is
  /// persisted (tree URI + display name) and becomes
  /// [DownloadLocation.custom]; dismissing the picker keeps the prior
  /// choice. Picker failures surface as a snackbar, never a throw.
  Future<void> _pickLocation(BuildContext context, WidgetRef ref) async {
    final current = ref.read(downloadLocationProvider);
    final customName = ref.read(downloadCustomNameProvider);
    final selected = await showDialog<DownloadLocation>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download location'),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: RadioGroup<DownloadLocation>(
          groupValue: current,
          onChanged: (value) => Navigator.pop(context, value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in DownloadLocation.values)
                RadioListTile<DownloadLocation>(
                  value: option,
                  title: Text(option.title),
                  subtitle: Text(
                    option == DownloadLocation.custom && customName.isNotEmpty
                        ? customName
                        : option.blurb,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !context.mounted) {
      return;
    }
    if (selected == DownloadLocation.custom) {
      await _pickCustomFolder(context, ref);
      return;
    }
    if (selected != current) {
      await ref.read(downloadLocationProvider.notifier).setLocation(selected);
    }
  }

  /// Launches the SAF folder picker and persists the picked tree.
  Future<void> _pickCustomFolder(BuildContext context, WidgetRef ref) async {
    late final PickedFolder? picked;
    try {
      picked = await DownloadTreeChannel.pickFolder();
    } on AppException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.error.message)));
      }
      return;
    }
    // User dismissed the system picker: keep the prior choice.
    if (picked == null || !context.mounted) {
      return;
    }
    await ref
        .read(downloadLocationProvider.notifier)
        .setCustomFolder(uri: picked.uri, displayName: picked.displayName);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloads → ${picked.displayName}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mirror UI state into the queue manager on every change (the
    // manager defaults match the provider defaults, so no initial
    // push is needed).
    ref
      ..listen<bool>(
        wifiOnlyDownloadsProvider,
        (_, next) => ref
            .read(downloadsServiceProvider)
            ?.updateDownloadSettings(wifiOnly: next),
      )
      ..listen<Quality>(
        downloadQualityProvider,
        (_, next) => ref
            .read(downloadsServiceProvider)
            ?.updateDownloadSettings(quality: next),
      )
      ..listen<int>(
        downloadConcurrencyProvider,
        (_, next) => ref
            .read(downloadsServiceProvider)
            ?.updateDownloadSettings(concurrency: next),
      );
    final wifiOnly = ref.watch(wifiOnlyDownloadsProvider);
    final quality = ref.watch(downloadQualityProvider);
    final concurrency = ref.watch(downloadConcurrencyProvider);
    final location = ref.watch(downloadLocationProvider);
    final dirPath = ref.watch(downloadLocationDirProvider);
    final customName = ref.watch(downloadCustomNameProvider);
    final customUri = ref.watch(downloadCustomUriProvider);
    final locationSubtitle = location == DownloadLocation.custom
        ? (customName.isNotEmpty
              ? customName
              : (customUri.isNotEmpty ? customUri : location.blurb))
        : (dirPath.isEmpty ? location.blurb : dirPath);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          title: const Text('Download on Wi-Fi only'),
          subtitle: const Text('Pause the queue on metered networks'),
          value: wifiOnly,
          onChanged: (value) =>
              ref.read(wifiOnlyDownloadsProvider.notifier).state = value,
        ),
        ListTile(
          title: const Text('Download quality'),
          subtitle: Text(qualitySubtitle(quality)),
          trailing: DropdownButton<Quality>(
            value: quality,
            onChanged: (selected) {
              if (selected != null) {
                ref.read(downloadQualityProvider.notifier).state = selected;
              }
            },
            items: [
              for (final rung in Quality.values)
                DropdownMenuItem(
                  value: rung,
                  child: Text(qualityLabel(rung)),
                ),
            ],
          ),
        ),
        ListTile(
          title: const Text('At once'),
          subtitle: Slider(
            value: concurrency.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            label: '$concurrency',
            onChanged: (value) =>
                ref.read(downloadConcurrencyProvider.notifier).state = value
                    .round()
                    .clamp(1, 3),
          ),
          trailing: Text(
            '$concurrency',
            style: AuroraType.titleSmall,
          ),
        ),
        ListTile(
          title: const Text('Download location'),
          subtitle: Text(
            locationSubtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.folder_outlined),
          onTap: () => _pickLocation(context, ref),
        ),
      ],
    );
  }
}
