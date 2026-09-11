import 'package:aurora_ui_kit/src/colors.dart';
import 'package:flutter/material.dart';

/// Base scaffold: bg0 canvas with pass-through Scaffold behavior.
///
/// Screens add their own scroll views; the shell adds the bottom nav +
/// mini-player via [bottomNavigationBar].
class AuroraScaffold extends StatelessWidget {
  /// Creates the base scaffold.
  const AuroraScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
  });

  /// Main content.
  final Widget body;

  /// Optional top bar.
  final PreferredSizeWidget? appBar;

  /// Shell slot: mini-player + bottom navigation.
  final Widget? bottomNavigationBar;

  /// Optional action (e.g. Library "create playlist").
  final Widget? floatingActionButton;

  /// Passed through to [Scaffold].
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuroraColors.bg0,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
