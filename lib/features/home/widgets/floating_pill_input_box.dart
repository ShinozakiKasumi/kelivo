import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Minimal floating input container used by the chat composer.
///
/// The visual shell is intentionally stateless: all text, media and submission
/// state stays in the caller so replacing the chrome does not duplicate chat
/// state.
class FloatingPillInputBox extends StatelessWidget {
  const FloatingPillInputBox({
    super.key,
    required this.input,
    required this.leading,
    required this.trailing,
    this.topContent,
    this.bottomContent,
    this.queuedContent,
    this.backgroundImageActive = false,
  });

  static const Color darkBackground = Color(0xFF1E1E20);

  final Widget input;
  final Widget leading;
  final Widget trailing;
  final Widget? topContent;
  final Widget? bottomContent;
  final Widget? queuedContent;
  final bool backgroundImageActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? darkBackground.withValues(alpha: backgroundImageActive ? 0.88 : 0.96)
        : cs.surface.withValues(alpha: backgroundImageActive ? 0.88 : 0.96);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : cs.outlineVariant.withValues(alpha: 0.42);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.42)
        : Colors.black.withValues(alpha: 0.18);

    final capsule = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (topContent != null) ...[
                  topContent!,
                  const SizedBox(height: 6),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    leading,
                    const SizedBox(width: 6),
                    Expanded(child: input),
                    const SizedBox(width: 6),
                    trailing,
                  ],
                ),
                if (bottomContent != null) ...[
                  const SizedBox(height: 6),
                  bottomContent!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (queuedContent != null) ...[
              queuedContent!,
              const SizedBox(height: 8),
            ],
            capsule,
          ],
        ),
      ),
    );
  }
}
