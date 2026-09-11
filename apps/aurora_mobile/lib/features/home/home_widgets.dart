import 'dart:async';

import 'package:aurora_core/aurora_core.dart';
import 'package:aurora_mobile/features/home/home_providers.dart';
import 'package:aurora_mobile/features/home/home_service.dart';
import 'package:aurora_mobile/features/home/mix_detail_screen.dart';
import 'package:aurora_mobile/library_scan.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Large home cover card: artwork, title, artist, Why on long-press.
class HomeTrackCard extends ConsumerWidget {
  /// Creates a home card.
  const HomeTrackCard({
    required this.entry,
    super.key,
    this.size = 160,
    this.imageUrl,
    this.localPath,
  });

  /// Entry to render.
  final HomeRecoEntry entry;

  /// Square cover edge (160 grid, 120 compact).
  final double size;

  /// Real cover-art URL, when the lane provides one (null = monogram).
  final String? imageUrl;

  /// Real on-disk artwork path, when the lane provides one.
  final String? localPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(homeActionsProvider);
    // Explicit pass-through wins; otherwise the scan-cached local
    // cover resolves here so rails never need their own art plumbing.
    final localArt =
        localPath ??
        ref.watch(localTrackArtProvider(entry.track.id)).valueOrNull;
    final fallbackUrl =
        localArt == null ? trackFallbackThumbnailUrl(entry.track) : null;
    return GestureDetector(
      onTap: () => unawaited(
        actions?.playTracks([entry.track]),
      ),
      onLongPress: () => WhyReasonsSheet.show(context, entry),
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverImage(
              monogram: entry.track.title,
              imageUrl: imageUrl ?? fallbackUrl,
              localPath: localArt,
              size: size,
            ),
            const SizedBox(height: 8),
            Text(
              entry.track.title,
              style: AuroraType.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              actions?.artistLine(entry.track) ?? 'Unknown artist',
              style: AuroraType.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Daily-mix card: mix title plus the seed line; taps play the mix.
class HomeMixCard extends ConsumerWidget {
  /// Creates a mix card.
  const HomeMixCard({
    required this.title,
    required this.subtitle,
    required this.entries,
    super.key,
    this.imageUrl,
    this.localPath,
  });

  /// Mix title (Daily Mix 1 ...).
  final String title;

  /// Seed line (artist / genre / time bucket).
  final String subtitle;

  /// Mix tracks (first cover illustrates the card).
  final List<HomeRecoEntry> entries;

  /// Real cover-art URL for the card art (null = monogram).
  final String? imageUrl;

  /// Real on-disk artwork path for the card art (null = monogram).
  final String? localPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = entries.isEmpty ? null : entries.first;
    final firstId = first?.track.id;
    final localArt =
        localPath ??
        (firstId == null
            ? null
            : ref.watch(localTrackArtProvider(firstId)).valueOrNull);
    final fallbackUrl =
        localArt == null && first != null
            ? trackFallbackThumbnailUrl(first.track)
            : null;
    return GestureDetector(
      onTap: () {
        unawaited(
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MixDetailScreen(
                title: title,
                subtitle: subtitle,
                entries: entries,
              ),
            ),
          ),
        );
      },
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverImage(
              monogram: first?.track.title ?? title,
              imageUrl: imageUrl ?? fallbackUrl,
              localPath: localArt,
              size: 160,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AuroraType.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: AuroraType.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Continue-listening card with a progress bar.
class ContinueCard extends ConsumerWidget {
  /// Creates a continue card.
  const ContinueCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  /// Item to render.
  final ContinueItem item;

  /// Resume tap handler.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Album resumes show the scan-cached album cover; playlists keep
    // the monogram tile (no playlist art is persisted).
    final art = item.isPlaylist
        ? null
        : ref.watch(localAlbumArtProvider(item.id)).valueOrNull;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverImage(
              monogram: item.title,
              localPath: art,
              size: 120,
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: AuroraType.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.subtitle,
              style: AuroraType.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: item.progress.clamp(0, 1).toDouble(),
              minHeight: 2,
              backgroundColor: AuroraColors.bg3,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AuroraColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Why this track" bottom sheet (long-press on any home card/row).
abstract final class WhyReasonsSheet {
  /// Shows the sheet for [entry].
  static Future<void> show(BuildContext context, HomeRecoEntry entry) =>
      showAuroraBottomSheet<void>(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.track.title,
                style: AuroraType.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text('Why this track', style: AuroraType.labelSmall),
              const SizedBox(height: 12),
              if (entry.reasons.isEmpty)
                const Text(
                  'Fresh recommendation — listen more and '
                  'this panel fills in.',
                  style: AuroraType.bodyMedium,
                )
              else
                for (final reason in entry.reasons.take(6))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_outlined,
                          size: 16,
                          color: AuroraColors.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            reason.label,
                            style: AuroraType.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      );
}

/// Mood chip bar: horizontal single-select filter (tap again to clear).
///
/// Unselected chips sit on the theme surface; the selected chip is
/// picked out with the injected accent. No global restyle.
class HomeMoodBar extends ConsumerWidget {
  /// Creates the mood bar.
  const HomeMoodBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(homeMoodProvider);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: HomeMood.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mood = HomeMood.values[index];
          final isSelected = mood == selected;
          return GestureDetector(
            onTap: () => ref.read(homeMoodProvider.notifier).state = isSelected
                ? null
                : mood,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AuroraColors.bg2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AuroraColors.accent : AuroraColors.bg3,
                ),
              ),
              child: Text(
                mood.label,
                style: AuroraType.labelSmall.copyWith(
                  color: isSelected
                      ? AuroraColors.accent
                      : AuroraColors.textMid,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Album card for the recommended-albums shelf: cover, title, year.
///
/// The cover resolves from the scan-cached album artwork (monogram
/// while none is stored; never invented art); tap opens the album
/// detail route.
class HomeAlbumCard extends ConsumerWidget {
  /// Creates an album card.
  const HomeAlbumCard({required this.album, required this.onTap, super.key});

  /// Album to render.
  final Album album;

  /// Card tap handler (routes to `/album/:id`).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = album.year?.toString() ?? '';
    final art = ref.watch(localAlbumArtProvider(album.id)).valueOrNull;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverImage(
              monogram: album.title,
              localPath: art,
              size: 120,
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              style: AuroraType.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (year.isNotEmpty)
              Text(
                year,
                style: AuroraType.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
