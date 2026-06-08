import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'floating_pill_input_box.dart';

class FloatingDrawerPanel extends StatelessWidget {
  const FloatingDrawerPanel({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(16, 16, 0, 16),
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? FloatingPillInputBox.darkBackground.withValues(alpha: 0.96)
        : theme.colorScheme.surface.withValues(alpha: 0.96);

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.18),
              blurRadius: 28,
              spreadRadius: -10,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: ColoredBox(color: background, child: child),
          ),
        ),
      ),
    );
  }
}
