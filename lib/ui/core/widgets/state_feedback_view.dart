import 'package:flutter/material.dart';

import 'package:responsi_flutter/ui/core/widgets/liquid_glass_card.dart';

/// Reusable loading indicator state styled as an iOS 27 Liquid Glass panel.
class LoadingStateView extends StatelessWidget {
  const LoadingStateView({
    super.key,
    this.message = 'Memuat data dari Open-Meteo...',
    this.useDarkInk = false,
  });

  final String message;
  final bool useDarkInk;

  @override
  Widget build(BuildContext context) {
    final textColor =
        useDarkInk ? const Color(0xFF0F172A) : Colors.white.withOpacity(0.92);
    final spinnerColor =
        useDarkInk ? const Color(0xFF2563EB) : Colors.white;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LiquidGlassCard(
          borderRadius: 24,
          tintOpacity: useDarkInk ? 0.36 : 0.16,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 2.8,
                  color: spinnerColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable empty state Liquid Glass card for empty search or missing weather.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.useDarkInk = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool useDarkInk;

  @override
  Widget build(BuildContext context) {
    final titleColor = useDarkInk ? const Color(0xFF0F172A) : Colors.white;
    final subColor = useDarkInk
        ? const Color(0xFF334155)
        : Colors.white.withOpacity(0.8);
    final iconBg = useDarkInk
        ? const Color(0xFF2563EB).withOpacity(0.14)
        : Colors.white.withOpacity(0.14);
    final iconColor = useDarkInk ? const Color(0xFF1D4ED8) : Colors.white;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LiquidGlassCard(
            borderRadius: 24,
            tintOpacity: useDarkInk ? 0.38 : 0.16,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          useDarkInk ? const Color(0xFF2563EB) : Colors.white,
                      foregroundColor:
                          useDarkInk ? Colors.white : const Color(0xFF0F172A),
                    ),
                    icon: const Icon(Icons.search_rounded),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable error state Liquid Glass card with explicit retry action.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.useDarkInk = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool useDarkInk;

  @override
  Widget build(BuildContext context) {
    final titleColor = useDarkInk ? const Color(0xFF0F172A) : Colors.white;
    final subColor = useDarkInk
        ? const Color(0xFF334155)
        : Colors.white.withOpacity(0.82);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LiquidGlassCard(
            borderRadius: 24,
            tintOpacity: useDarkInk ? 0.38 : 0.16,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444)
                        .withOpacity(useDarkInk ? 0.14 : 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 28,
                    color: useDarkInk
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFFCA5A5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal Memuat Data',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        useDarkInk ? const Color(0xFF2563EB) : Colors.white,
                    foregroundColor:
                        useDarkInk ? Colors.white : const Color(0xFF0F172A),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
