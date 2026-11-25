import 'dart:ui';

import 'package:flutter/material.dart';

/// iOS 26/27 Liquid Glass panel featuring translucent frosted layering, specular
/// rim highlight, and optional hardware-accelerated backdrop blur.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.tintOpacity = 0.16,
    this.enableBlur = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double tintOpacity;
  final bool enableBlur;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topColor = isDark
        ? Colors.white.withOpacity(tintOpacity * 0.78)
        : Colors.white.withOpacity(tintOpacity + 0.08);
    final bottomColor = isDark
        ? Colors.black.withOpacity(0.28)
        : Colors.white.withOpacity(tintOpacity * 0.78);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.20)
        : Colors.white.withOpacity(0.30);

    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [topColor, bottomColor],
        ),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: child,
    );

    if (!enableBlur) {
      return ClipRRect(borderRadius: radius, child: container);
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: container,
      ),
    );
  }
}
