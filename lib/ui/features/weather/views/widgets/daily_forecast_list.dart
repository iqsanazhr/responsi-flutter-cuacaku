import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:responsi_flutter/domain/models/daily_forecast.dart';
import 'package:responsi_flutter/ui/core/utils/weather_code_helper.dart';
import 'package:responsi_flutter/ui/core/widgets/liquid_glass_card.dart';
import 'package:responsi_flutter/ui/core/widgets/press_scale.dart';

/// Apple Weather iOS-style Liquid Glass 7-Day Forecast module with
/// proportional thermal gradient range bars and zero-overflow responsive rows.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.daily,
    required this.onSelectDay,
  });

  final List<DailyForecast> daily;
  final ValueChanged<DailyForecast> onSelectDay;

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) {
      return const SizedBox.shrink();
    }

    final globalMin = daily.map((d) => d.temperatureMin).reduce(math.min);
    final globalMax = daily.map((d) => d.temperatureMax).reduce(math.max);
    final span = math.max(1.0, globalMax - globalMin);

    return LiquidGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.72),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'PRAKIRAAN ${daily.length} HARI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.18),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.white.withOpacity(0.14),
            ),
            itemBuilder: (context, index) {
              final item = daily[index];
              final visual = WeatherCodeHelper.resolve(item.weatherCode);
              final dayLabel = index == 0
                  ? 'Hari Ini'
                  : DateFormat('EEE, d', 'id_ID').format(item.date);

              final startFraction = (item.temperatureMin - globalMin) / span;
              final endFraction = (item.temperatureMax - globalMin) / span;

              return PressScale(
                onTap: () => onSelectDay(item),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 68,
                        child: Text(
                          dayLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight:
                                index == 0 ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 44,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              visual.icon,
                              size: 20,
                              color: visual.accentColor ==
                                      const Color(0xFF0EA5E9)
                                  ? Colors.white
                                  : visual.accentColor,
                            ),
                            if (item.precipitationProbabilityMax > 0)
                              Text(
                                '${item.precipitationProbabilityMax}%',
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Color(0xFF7DD3FC),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${item.temperatureMin.toStringAsFixed(0)}°',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, barConstraints) {
                            final w = barConstraints.maxWidth;
                            final left = (startFraction * w).clamp(0.0, w);
                            final barWidth = math.max(
                              8.0,
                              (endFraction - startFraction) * w,
                            );
                            return Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: math.min(left, math.max(0.0, w - barWidth)),
                                    width: math.min(barWidth, w),
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF38BDF8),
                                            Color(0xFFFACC15),
                                            Color(0xFFF97316),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${item.temperatureMax.toStringAsFixed(0)}°',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
