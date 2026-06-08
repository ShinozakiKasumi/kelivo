import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../icons/lucide_adapter.dart';
import '../../../shared/widgets/ios_tactile.dart';
import '../../../theme/app_font_weights.dart';
import 'floating_pill_input_box.dart';

class FloatingPillAppBar extends StatelessWidget {
  const FloatingPillAppBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.onMenuTap,
    required this.onTitleTap,
    required this.onToolsTap,
    required this.menuSemanticLabel,
    required this.toolsSemanticLabel,
    this.leadingIcon = Lucide.Menu,
    this.trailingIcon = Lucide.Settings2,
    this.extraAction,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onMenuTap;
  final VoidCallback onTitleTap;
  final VoidCallback onToolsTap;
  final String menuSemanticLabel;
  final String toolsSemanticLabel;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final Widget? extraAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = Colors.white.withValues(alpha: isDark ? 0.94 : 0.90);
    final muted = Colors.white.withValues(alpha: isDark ? 0.58 : 0.62);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.36)
        : Colors.black.withValues(alpha: 0.18);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: FloatingPillInputBox.darkBackground.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 22,
                spreadRadius: -10,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    IosIconButton(
                      icon: leadingIcon,
                      size: 22,
                      minSize: 44,
                      color: muted,
                      semanticLabel: menuSemanticLabel,
                      onTap: onMenuTap,
                    ),
                    Expanded(
                      child: IosCardPress(
                        onTap: onTitleTap,
                        borderRadius: BorderRadius.circular(32),
                        baseColor: Colors.transparent,
                        pressedBlendStrength: 0.18,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: foreground,
                                      fontSize: 15,
                                      fontWeight: AppFontWeights.semibold,
                                      height: 1.08,
                                    ),
                                  ),
                                  if (subtitle != null &&
                                      subtitle!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 11,
                                        fontWeight: AppFontWeights.medium,
                                        height: 1.05,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Lucide.ChevronDown, size: 15, color: muted),
                          ],
                        ),
                      ),
                    ),
                    if (extraAction != null) extraAction!,
                    IosIconButton(
                      icon: trailingIcon,
                      size: 21,
                      minSize: 44,
                      color: muted,
                      semanticLabel: toolsSemanticLabel,
                      onTap: onToolsTap,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
