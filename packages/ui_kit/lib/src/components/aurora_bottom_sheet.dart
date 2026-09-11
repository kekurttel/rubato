import 'package:aurora_ui_kit/src/colors.dart';
import 'package:flutter/material.dart';

/// Aurora bottom sheet: bg1 surface, 20px top radius, drag handle.
///
/// Used for overflow menus, queue, "Why this track", quality pickers.
class AuroraBottomSheet extends StatelessWidget {
  /// Creates a bottom sheet body.
  const AuroraBottomSheet({required this.child, super.key});

  /// Sheet content below the handle.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AuroraColors.bg3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Shows an [AuroraBottomSheet] modally.
Future<T?> showAuroraBottomSheet<T>({
  /// Build context for the sheet.
  required BuildContext context,

  /// Sheet content builder.
  required Widget Function(BuildContext context) builder,

  /// Whether the sheet sizes to its content (default true).
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: AuroraColors.bg1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => AuroraBottomSheet(child: builder(context)),
  );
}
