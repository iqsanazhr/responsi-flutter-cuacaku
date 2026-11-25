import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:responsi_flutter/domain/models/weather_forecast.dart';
import 'package:responsi_flutter/ui/core/utils/weather_code_helper.dart';
import 'package:responsi_flutter/ui/core/widgets/liquid_glass_card.dart';

/// Apple Weather iOS-style 2-up Liquid Glass Bento tiles displaying all
/// required Open-Meteo meteorological metrics.
class WeatherMetricsGrid extends StatelessWidget {
  const WeatherMetricsGrid({super.key, required this.forecast});

  final WeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    final current = forecast.current;
    final today = forecast.todayForecast;
    final visual = WeatherCodeHelper.resolve(
      current.weatherCode,
      isDay: current.isDay,
    );

    final metrics = [
      _GlassMetric(
        icon: Icons.thermostat_rounded,
        title: 'TERASA SEPERTI',
        value: '${current.apparentTemperature.toStringAsFixed(1)}°',
        subtitle: current.apparentTemperature >= current.temperature2m
            ? 'Kelembapan membuat terasa lebih hangat.'
            : 'Angin membuat terasa lebih sejuk.',
      ),
      _GlassMetric(
        icon: Icons.water_drop_outlined,
        title: 'KELEMBAPAN',
        value: '${current.relativeHumidity2m}%',
        subtitle: current.relativeHumidity2m >= 80
            ? 'Kondisi udara sangat lembap.'
            : 'Tingkat kelembapan udara normal.',
      ),
      _GlassMetric(
        icon: Icons.air_rounded,
        title: 'ANGIN',
        value: '${current.windSpeed10m.toStringAsFixed(1)} km/j',
        subtitle: 'Kecepatan angin permukaan (10m).',
      ),
      _GlassMetric(
        icon: Icons.grain_rounded,
        title: 'CURAH HUJAN',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
        subtitle: current.precipitation > 0
            ? 'Terdeteksi presipitasi saat ini.'
            : 'Tidak ada curah hujan tercatat.',
      ),
      _GlassMetric(
        icon: Icons.umbrella_rounded,
        title: 'PELUANG HUJAN',
        value: '${today?.precipitationProbabilityMax ?? 0}%',
        subtitle: 'Probabilitas hujan maksimum hari ini.',
      ),
      _GlassMetric(
        icon: visual.icon,
        title: 'KODE CUACA',
        value: 'WMO ${current.weatherCode}',
        subtitle: visual.label,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 560 ? 3 : 2;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: itemWidth,
                  child: _GlassMetricTile(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _GlassMetric {
  const _GlassMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
}

class _GlassMetricTile extends StatelessWidget {
  const _GlassMetricTile({required this.metric});

  final _GlassMetric metric;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                metric.icon,
                size: 14,
                color: Colors.white.withOpacity(0.75),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  metric.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
