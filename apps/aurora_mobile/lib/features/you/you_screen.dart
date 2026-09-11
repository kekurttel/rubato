import 'dart:async';

import 'package:aurora_mobile/features/library/library_providers.dart';
import 'package:aurora_mobile/features/you/you_providers.dart';
import 'package:aurora_mobile/features/you/you_service.dart';
import 'package:aurora_mobile/features/you/youtube_account.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// You tab: stats, mix sliders, decay, cache, privacy (13.6 + 13.7).
///
/// The three mix sliders always sum to 1: dragging one rebalances
/// the other two proportionally ([rebalanceRates]). Privacy actions
/// confirm before anything destructive runs.
class YouScreen extends ConsumerWidget {
  /// Creates the you screen.
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(youStatsProvider);
    return AuroraScaffold(
      appBar: AppBar(title: const Text('You')),
      body: ListView(
        children: [
          const SectionHeader(title: 'Your listening'),
          stats.when(
            data: (value) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatTile(
                    label: 'Tracks played',
                    value: '${value.tracksPlayed}',
                  ),
                  _StatTile(
                    label: 'Minutes',
                    value: '${value.minutesListened}',
                  ),
                  _StatTile(
                    label: 'Liked',
                    value: '${value.likeCount}',
                  ),
                  _StatTile(
                    label: 'Playlists',
                    value: '${value.playlistCount}',
                  ),
                ],
              ),
            ),
            loading: () => const SkeletonTrackList(count: 1),
            error: (error, _) => ErrorState(
              message: 'Could not load stats.',
              onRetry: () => ref.invalidate(youStatsProvider),
            ),
          ),
          const SectionHeader(title: 'YouTube account'),
          const _YouTubeAccountSection(),
          const SectionHeader(title: 'Your mix'),
          const _MixSliders(),
          const SectionHeader(title: 'Memory'),
          const _DecaySlider(),
          const SectionHeader(title: 'Cache'),
          const _CacheSlider(),
          const SectionHeader(title: 'Appearance'),
          const _AccentColorRow(),
          const SectionHeader(title: 'Your data'),
          const _PrivacyActions(),
          const SectionHeader(title: 'Network log'),
          const _NetworkLog(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// One stat cell.
class _StatTile extends StatelessWidget {
  /// Creates a stat cell.
  const _StatTile({required this.label, required this.value});

  /// Cell caption.
  final String label;

  /// Formatted value.
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AuroraType.titleLarge),
          const SizedBox(height: 4),
          Text(label, style: AuroraType.bodySmall),
        ],
      ),
    );
  }
}

/// YouTube account: sign in/out plus account-feed imports.
///
/// Signed-in sessions authenticate the native extractor (no
/// bot-gating) and unlock the `LL` (liked videos) and `HL` (watch
/// history) feeds as importable playlists.
class _YouTubeAccountSection extends ConsumerWidget {
  /// Creates the section.
  const _YouTubeAccountSection();

  Future<void> _importFeed(
    BuildContext context,
    WidgetRef ref,
    String feedId,
    String fallbackTitle,
  ) async {
    final service = ref.read(libraryServiceProvider);
    if (service == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Importing $fallbackTitle…')),
    );
    final playlist = await service.importYouTubePlaylist(
      'https://www.youtube.com/playlist?list=$feedId',
    );
    if (!context.mounted) {
      return;
    }
    if (playlist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not import — check the connection and account.',
          ),
        ),
      );
      return;
    }
    ref.invalidate(libraryPlaylistsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported ${playlist.title}.')),
    );
    unawaited(context.push('/playlist/${Uri.encodeComponent(playlist.id)}'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(ytAccountStatusProvider).valueOrNull ?? false;
    final service = ref.watch(libraryServiceProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: const Text('YouTube account'),
          subtitle: Text(
            signedIn
                ? 'Connected — streams use your session.'
                : 'Not connected — public catalog only.',
          ),
          trailing: signedIn
              ? TextButton(
                  onPressed: () async {
                    await YouTubeAccount.clear();
                    final wiring = ref.read(auroraWiringProvider);
                    if (wiring != null) {
                      await YouTubeAccount.syncToBridge(wiring.ytdlp);
                    }
                    ref.invalidate(ytAccountStatusProvider);
                  },
                  child: const Text('Sign out'),
                )
              : FilledButton.tonal(
                  onPressed: () => context.push('/yt-login'),
                  child: const Text('Sign in'),
                ),
        ),
        if (signedIn) ...[
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Import liked videos'),
            subtitle: const Text('Your YouTube liked feed as a playlist.'),
            enabled: service != null,
            onTap: () =>
                _importFeed(context, ref, 'LL', 'liked videos'),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Import watch history'),
            subtitle: const Text('Your YouTube history as a playlist.'),
            enabled: service != null,
            onTap: () =>
                _importFeed(context, ref, 'HL', 'watch history'),
          ),
        ],
      ],
    );
  }
}

/// 3-way mix sliders; the triple always sums to 1.
class _MixSliders extends ConsumerWidget {
  /// Creates the sliders.
  const _MixSliders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rates = ref.watch(mixRatesProvider);
    final service = ref.watch(youServiceProvider);
    Future<void> update(int changed, double value) async {
      final next = rebalanceRates(rates, changed, value);
      ref.read(mixRatesProvider.notifier).state = next;
      await service?.setMixRates(next);
    }

    Widget slider({
      required String label,
      required double value,
      required int index,
    }) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AuroraType.bodyMedium),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(0, 1).toDouble(),
              onChanged: (next) => update(index, next),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${(value * 100).round()}%',
              style: AuroraType.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        slider(
          label: 'Favorites',
          value: rates.exploitation,
          index: 0,
        ),
        slider(
          label: 'Adjacent',
          value: rates.adjacent,
          index: 1,
        ),
        slider(
          label: 'Discovery',
          value: rates.exploration,
          index: 2,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Mix: ${(rates.exploitation * 100).round()}/'
            '${(rates.adjacent * 100).round()}/'
            '${(rates.exploration * 100).round()} '
            '(always sums to 100%).',
            style: AuroraType.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// Decay half-life slider (7–180 days).
class _DecaySlider extends ConsumerWidget {
  /// Creates the slider.
  const _DecaySlider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final halfLife = ref.watch(decayHalfLifeProvider);
    final service = ref.watch(youServiceProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            child: Text('Memory', style: AuroraType.bodyMedium),
          ),
          Expanded(
            child: Slider(
              min: 7,
              max: 180,
              divisions: 173,
              value: halfLife.clamp(7, 180).toDouble(),
              onChanged: (next) {
                ref.read(decayHalfLifeProvider.notifier).state = next;
                unawaited(service?.setDecayHalfLifeDays(next));
              },
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '${halfLife.round()} days',
              style: AuroraType.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Artwork cache budget slider (100–1000 MB).
class _CacheSlider extends ConsumerWidget {
  /// Creates the slider.
  const _CacheSlider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheMb = ref.watch(cacheMbProvider);
    final service = ref.watch(youServiceProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            child: Text('Artwork', style: AuroraType.bodyMedium),
          ),
          Expanded(
            child: Slider(
              min: 100,
              max: 1000,
              divisions: 18,
              value: cacheMb.clamp(100, 1000).toDouble(),
              onChanged: (next) {
                ref.read(cacheMbProvider.notifier).state = next.round();
                unawaited(service?.setCacheMb(next.round()));
              },
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$cacheMb MB',
              style: AuroraType.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Accent color presets (persisted, applied to the app theme).
class _AccentColorRow extends ConsumerWidget {
  /// Creates the accent row.
  const _AccentColorRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(accentColorProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Accent color', style: AuroraType.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final preset in auroraAccentPresets)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _AccentSwatch(
                    preset: preset,
                    selected: preset.color.toARGB32() == selected.toARGB32(),
                    onTap: () => unawaited(
                      setAccentColor(
                        ref.read(accentColorProvider.notifier),
                        preset.color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Gold is the default; the choice persists across restarts.',
            style: AuroraType.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// One tappable accent swatch with a selection ring.
class _AccentSwatch extends StatelessWidget {
  /// Creates a swatch.
  const _AccentSwatch({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  /// Preset to render.
  final AccentPreset preset;

  /// Whether this preset is the active accent.
  final bool selected;

  /// Tap callback (persists the preset).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${preset.name} accent',
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: preset.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AuroraColors.textHi : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: selected
              ? const Icon(Icons.check, size: 20, color: Colors.black87)
              : null,
        ),
      ),
    );
  }
}

/// Privacy actions: export / reset / delete with confirmations.
class _PrivacyActions extends ConsumerWidget {
  /// Creates the actions.
  const _PrivacyActions();

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String message,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(youServiceProvider);
    Future<void> snack(String message) async {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.ios_share_outlined),
          title: const Text('Export my data'),
          subtitle: const Text('History, playlists, and profile as JSON.'),
          enabled: service != null,
          onTap: () async {
            final json = await service?.exportJson();
            if (json != null) {
              await snack('Exported ${json.length} characters.');
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.refresh_outlined),
          title: const Text('Reset recommendations'),
          subtitle: const Text('Wipes profile and scores, keeps files.'),
          enabled: service != null,
          onTap: () async {
            if (await _confirm(
              context,
              'Reset recommendations?',
              'Your taste profile and track scores are rebuilt from '
                  'scratch. Playlists and files stay.',
            )) {
              await service?.resetRecommendations();
              await snack('Recommendations reset.');
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Delete history'),
          subtitle: const Text('Listening and search history.'),
          enabled: service != null,
          onTap: () async {
            if (await _confirm(
              context,
              'Delete history?',
              'Listening and search history are removed permanently.',
            )) {
              await service?.deleteHistory();
              await snack('History deleted.');
            }
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.warning_amber_outlined,
            color: AuroraColors.danger,
          ),
          title: const Text('Delete everything'),
          subtitle: const Text('History, profile, playlists, downloads.'),
          enabled: service != null,
          onTap: () async {
            if (await _confirm(
              context,
              'Delete everything?',
              'This removes all Aurora data on this device. '
                  'Downloaded files are deleted too.',
            )) {
              await service?.deleteEverything();
              await snack('All local data deleted.');
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Full privacy details'),
          onTap: () => context.push('/privacy'),
        ),
      ],
    );
  }
}

/// Last-20 network calls: host + purpose only, never payloads.
class _NetworkLog extends ConsumerWidget {
  /// Creates the log list.
  const _NetworkLog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(youServiceProvider);
    final log = service?.networkLog() ?? const <NetworkCall>[];
    if (log.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No provider calls yet — reco and history never use '
          'the network.',
          style: AuroraType.bodySmall,
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final call in log.take(20))
          ListTile(
            dense: true,
            leading: const Icon(Icons.cloud_outlined, size: 20),
            title: Text(call.host),
            trailing: Text(
              netPurposeLabel(call.purpose),
              style: AuroraType.bodySmall,
            ),
          ),
      ],
    );
  }
}
