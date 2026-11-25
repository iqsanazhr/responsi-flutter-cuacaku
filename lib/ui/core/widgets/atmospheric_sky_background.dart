import 'package:flutter/material.dart';

import 'package:responsi_flutter/ui/core/utils/weather_code_helper.dart';

/// Full-bleed atmospheric sky canvas that dynamically reflects live WMO
/// weather conditions and day/night state with GPU-friendly painted particles.
class AtmosphericSkyBackground extends StatelessWidget {
  const AtmosphericSkyBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  final int weatherCode;
  final bool isDay;
  final Widget child;

  bool get _isRainy =>
      (weatherCode >= 51 && weatherCode <= 67) ||
      (weatherCode >= 80 && weatherCode <= 82) ||
      weatherCode >= 95;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final visual = WeatherCodeHelper.resolve(
      weatherCode,
      isDay: isDay,
    );
    final disableAnim = MediaQuery.disableAnimationsOf(context);

    final topColor = isDarkTheme
        ? Color.lerp(visual.gradientColors.first, const Color(0xFF040812), 0.56)!
        : visual.gradientColors.first;
    final midColor = isDarkTheme
        ? Color.lerp(visual.gradientColors.last, const Color(0xFF081022), 0.50)!
        : visual.gradientColors.last;
    final bottomColor = isDarkTheme
        ? const Color(0xFF040710)
        : (Color.lerp(
              visual.gradientColors.last,
              const Color(0xFF0B2347),
              0.22,
            ) ??
            visual.gradientColors.last);

    return AnimatedContainer(
      duration:
          disableAnim ? Duration.zero : const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, midColor, bottomColor],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _AtmospherePainter(
                    isRainy: _isRainy,
                    isDay: isDay && !isDarkTheme,
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({
    required this.isRainy,
    required this.isDay,
  });

  final bool isRainy;
  final bool isDay;

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDay ? Colors.white : const Color(0xFF93C5FD)).withOpacity(0.16),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.78, size.height * 0.12),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawRect(Offset.zero & size, glowPaint);

    if (isRainy) {
      final rainPaint = Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round;

      const dropCount = 34;
      for (var i = 0; i < dropCount; i++) {
        final seedX = ((i * 73) % 100) / 100.0;
        final seedY = ((i * 41) % 100) / 100.0;
        final x = seedX * size.width;
        final y = seedY * size.height;
        canvas.drawLine(
          Offset(x, y),
          Offset(x - 4, y + 18),
          rainPaint,
        );
      }
    } else if (!isDay) {
      final starPaint = Paint()..color = Colors.white.withOpacity(0.24);
      for (var i = 0; i < 28; i++) {
        final x = (((i * 89) % 100) / 100.0) * size.width;
        final y = (((i * 37) % 60) / 100.0) * size.height;
        final radius = (i % 3 == 0) ? 1.5 : 1.0;
        canvas.drawCircle(Offset(x, y), radius, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.isRainy != isRainy || oldDelegate.isDay != isDay;
  }
}
