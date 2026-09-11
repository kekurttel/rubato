import 'package:aurora_ui_kit/src/colors.dart';
import 'package:aurora_ui_kit/src/typography.dart';
import 'package:flutter/material.dart';

/// Builds the Aurora dark theme (spec section 4).
///
/// Home stays bg0 + large covers + sparse gold: no colorful gradient
/// backgrounds, no default Material green.
///
/// [accent] is the injected brand accent (default gold). It drives the
/// color scheme, selection wash (derived at 24% per spec 4), buttons,
/// sliders, and progress indicators; every other color, radius, and
/// spacing stays identical.
ThemeData buildAuroraTheme({Color accent = AuroraColors.accent}) {
  final accentWash = AuroraColors.accentWashFor(accent);
  final scheme = ColorScheme.dark(
    primary: accent,
    onPrimary: AuroraColors.bg0,
    secondary: accent,
    surface: AuroraColors.bg1,
    onSurface: AuroraColors.textHi,
    error: AuroraColors.danger,
    onError: AuroraColors.textHi,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AuroraColors.bg0,
    canvasColor: AuroraColors.bg1,
    dividerColor: AuroraColors.hairline,
    appBarTheme: const AppBarTheme(
      backgroundColor: AuroraColors.bg0,
      foregroundColor: AuroraColors.textHi,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AuroraType.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AuroraColors.bg1,
      indicatorColor: accentWash,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? accent
              : AuroraColors.textLow,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          letterSpacing: -0.2,
          overflow: TextOverflow.ellipsis,
          color: states.contains(WidgetState.selected)
              ? accent
              : AuroraColors.textLow,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AuroraColors.bg1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AuroraColors.bg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AuroraColors.bg1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: false,
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: AuroraColors.bg0,
      textColor: AuroraColors.textHi,
      iconColor: AuroraColors.textMid,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: AuroraColors.bg3,
      circularTrackColor: AuroraColors.bg3,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AuroraColors.bg3,
      contentTextStyle: AuroraType.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: AuroraType.actionSmallFor(accent),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: AuroraColors.bg0,
        textStyle: AuroraType.actionSmallFor(accent),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AuroraColors.textMid),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      inactiveTrackColor: AuroraColors.bg3,
      thumbColor: accent,
    ),
    textTheme: const TextTheme(
      displayLarge: AuroraType.displayLarge,
      titleLarge: AuroraType.titleLarge,
      titleSmall: AuroraType.titleSmall,
      bodyMedium: AuroraType.bodyMedium,
      bodySmall: AuroraType.bodySmall,
      labelSmall: AuroraType.labelSmall,
    ),
  );
}
