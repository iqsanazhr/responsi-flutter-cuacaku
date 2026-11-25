import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:responsi_flutter/domain/models/daily_forecast.dart';
import 'package:responsi_flutter/ui/core/utils/weather_code_helper.dart';

/// Adaptive Light/Dark iOS 27 Liquid Glass bottom sheet showing detailed metrics.
class ForecastDetailSheet extends StatelessWidget {
  const ForecastDetailSheet({
    super.key,
    required this.cityName,
    required this.forecast,
  });

  final String cityName;
  final DailyForecast forecast;

  static Future<void> show(
    BuildContext context, {
    required String cityName,
    required DailyForecast forecast,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      isScrollControlled: true,
      builder: (_) => ForecastDetailSheet(
        cityName: cityName,
        forecast: forecast,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText =
        isDark ? Colors.white.withOpacity(0.76) : const Color(0xFF334155);
    final visual = WeatherCodeHelper.resolve(forecast.weatherCode);
    final dateTitle =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(forecast.date);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F1B33).withOpacity(0.88),
                      const Color(0xFF080E1E).withOpacity(0.94),
                    ]
                  : [
                      Colors.white.withOpacity(0.84),
                      const Color(0xFFEAF2FE).withOpacity(0.88),
                    ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(isDark ? 0.25 : 0.85),
                width: 1.2,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: secondaryText.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: visual.accentColor.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: visual.accentColor.withOpacity(0.32),
                          ),
                        ),
                        child:
                            Icon(visual.icon, size: 28, color: visual.accentColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateTitle,
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$cityName • ${visual.label} (WMO ${forecast.weatherCode})',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailTile(
                          label: 'Suhu Maks',
                          value: '${forecast.temperatureMax.toStringAsFixed(1)}°C',
                          icon: Icons.arrow_upward_rounded,
                          color: const Color(0xFFEA580C),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DetailTile(
                          label: 'Suhu Min',
                          value: '${forecast.temperatureMin.toStringAsFixed(1)}°C',
                          icon: Icons.arrow_downward_rounded,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DetailTile(
                          label: 'Peluang Hujan',
                          value: '${forecast.precipitationProbabilityMax}%',
                          icon: Icons.umbrella_rounded,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.18 : 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.72)
                  : const Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
