import 'dart:io' show File;

import 'package:aurora_ui_kit/src/colors.dart';
import 'package:aurora_ui_kit/src/typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Cover art with staged fallback (spec section 4):
/// local file -> cached network image -> dominant-color placeholder ->
/// monogram letter. Also serves as the Hero surface for Now Playing.
class CoverImage extends StatelessWidget {
  /// Creates a cover image.
  const CoverImage({
    required this.monogram,
    super.key,
    this.imageUrl,
    this.localPath,
    this.size = 56,
    this.borderRadius = 12,
    this.placeholderColor,
    this.fit = BoxFit.cover,
  });

  /// Fallback letter (usually the title initial).
  final String monogram;

  /// Remote artwork URL, if any.
  final String? imageUrl;

  /// On-disk artwork path, if any.
  final String? localPath;

  /// Square edge length (56 mini, 72 list, 160 grid, 280 featured).
  final double size;

  /// Corner radius (28 for Now Playing, 12 for cards).
  final double borderRadius;

  /// Placeholder tint (artwork dominant color when known).
  final Color? placeholderColor;

  /// How the image fills the box.
  final BoxFit fit;

  bool get _hasLocal => localPath != null && localPath!.isNotEmpty;

  bool get _hasRemote => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final letter = monogram.isEmpty ? '♪' : monogram.characters.first;
    final fallback = Container(
      color: placeholderColor ?? AuroraColors.bg2,
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: AuroraType.titleLarge.copyWith(
          color: AuroraColors.textLow,
        ),
      ),
    );
    final Widget art;
    if (_hasLocal) {
      art = Image.file(
        File(localPath!),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    } else if (_hasRemote) {
      art = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        memCacheWidth: (size * 2).round(),
        memCacheHeight: (size * 2).round(),
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      );
    } else {
      art = fallback;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: size, height: size, child: art),
    );
  }
}
