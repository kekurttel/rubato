import 'package:aurora_ui_kit/src/colors.dart';
import 'package:aurora_ui_kit/src/typography.dart';
import 'package:flutter/material.dart';

/// Section heading: uppercase label plus an optional gold action.
///
/// Empty snapshots hide their whole section (never render "null").
class SectionHeader extends StatelessWidget {
  /// Creates a section header.
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  /// Section title (uppercased at render).
  final String title;

  /// Optional trailing action (e.g. "See all").
  final String? actionLabel;

  /// Action callback. When null, no action is shown.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AuroraType.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Horizontal cover rail with an optional [SectionHeader] on top.
class HorizontalCoverRail extends StatelessWidget {
  /// Creates a horizontal cover rail.
  const HorizontalCoverRail({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.title,
    this.actionLabel,
    this.onAction,
    this.height = 190,
  });

  /// Section title. When null, no header is rendered.
  final String? title;

  /// Optional header action label.
  final String? actionLabel;

  /// Header action callback.
  final VoidCallback? onAction;

  /// Number of cards in the rail.
  final int itemCount;

  /// Card builder.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Rail height including the header-adjacent cards.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          SectionHeader(
            title: title!,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemCount,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}

/// Static shimmer-free placeholder box (pulse lands in Phase 5).
class SkeletonBox extends StatelessWidget {
  /// Creates a skeleton placeholder box.
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 8,
  });

  /// Box width (null = expand).
  final double? width;

  /// Box height.
  final double height;

  /// Corner radius.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AuroraColors.bg3,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton list mirroring `TrackTile` rows (cover + two lines).
class SkeletonTrackList extends StatelessWidget {
  /// Creates a skeleton track list.
  const SkeletonTrackList({super.key, this.count = 8});

  /// Number of placeholder rows.
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SkeletonBox(width: 56, height: 56, borderRadius: 12),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 160),
                    SizedBox(height: 8),
                    SkeletonBox(width: 110),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centered empty state: illustration icon + guidance, never blank.
class EmptyState extends StatelessWidget {
  /// Creates an empty state.
  const EmptyState({
    required this.title,
    super.key,
    this.message,
    this.icon = Icons.music_note_outlined,
    this.actionLabel,
    this.onAction,
  });

  /// Headline.
  final String title;

  /// Guidance line (e.g. "Try an artist you own" when offline).
  final String? message;

  /// Illustration icon.
  final IconData icon;

  /// Optional action label (e.g. "Open Settings").
  final String? actionLabel;

  /// Action callback. When null, no button is shown.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AuroraColors.textLow),
            const SizedBox(height: 16),
            Text(
              title,
              style: AuroraType.titleSmall,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AuroraType.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered inline error with retry (spec: errors are inline, retryable).
class ErrorState extends StatelessWidget {
  /// Creates an error state.
  const ErrorState({required this.message, super.key, this.onRetry});

  /// What went wrong (log-safe, user-readable).
  final String message;

  /// Retry callback. When null, no button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AuroraColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AuroraType.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
