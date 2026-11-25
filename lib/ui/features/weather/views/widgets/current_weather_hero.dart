import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:responsi_flutter/domain/models/weather_forecast.dart';
import 'package:responsi_flutter/ui/core/utils/weather_code_helper.dart';
import 'package:responsi_flutter/ui/core/widgets/press_scale.dart';

/// Apple Weather iOS-style centered atmospheric hero header displaying city,
/// ultra-light temperature, condition label, WMO code, and daily High/Low.
class CurrentWeatherHero extends StatelessWidget {
  const CurrentWeatherHero({
    super.key,
    required this.forecast,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenSearch,
  });

  final WeatherForecast forecast;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final current = forecast.current;
    final today = forecast.todayForecast;
    final visual = WeatherCodeHelper.resolve(
      current.weatherCode,
      isDay: current.isDay,
    );
    final updatedTime =
        DateFormat('EEE, d MMM • HH:mm', 'id_ID').format(current.time);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(visual.icon, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '$updatedTime ${forecast.timezoneAbbreviation}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PressScale(
                onTap: onToggleFavorite,
                borderRadius: BorderRadius.circular(999),
                child: Tooltip(
                  message: isFavorite
                      ? 'Hapus dari lokasi favorit'
                      : 'Simpan sebagai lokasi favorit',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isFavorite ? 0.24 : 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.26),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFavorite
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 16,
                          color: isFavorite
                              ? const Color(0xFFFDE047)
                              : Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isFavorite ? 'Tersimpan' : 'Simpan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PressScale(
            onTap: onOpenSearch,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          forecast.location.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.6,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ],
                  ),
                  if (forecast.location.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      forecast.location.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${current.temperature2m.toStringAsFixed(1)}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 82,
              fontWeight: FontWeight.w200,
              letterSpacing: -3.5,
              height: 1.04,
              fontFeatures: [FontFeature.tabularFigures()],
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                visual.label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  'WMO ${current.weatherCode}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (today != null)
            Text(
              'T:${today.temperatureMax.toStringAsFixed(1)}°   R:${today.temperatureMin.toStringAsFixed(1)}°   •   Terasa ${current.apparentTemperature.toStringAsFixed(1)}°',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}
