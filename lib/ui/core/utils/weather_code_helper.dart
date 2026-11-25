import 'package:flutter/material.dart';

/// WMO weather interpretation metadata for UI presentation.
class WeatherVisualInfo {
  const WeatherVisualInfo({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
}

/// Maps Open-Meteo WMO Weather interpretation codes (WW) to Indonesian labels,
/// Material icons, and atmospheric gradient palettes.
abstract final class WeatherCodeHelper {
  static WeatherVisualInfo resolve(int code, {bool isDay = true}) {
    if (code == 0) {
      return isDay
          ? const WeatherVisualInfo(
              label: 'Cerah',
              shortLabel: 'Cerah',
              icon: Icons.wb_sunny_rounded,
              accentColor: Color(0xFFF59E0B),
              gradientColors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
            )
          : const WeatherVisualInfo(
              label: 'Cerah Malam',
              shortLabel: 'Cerah',
              icon: Icons.nightlight_round,
              accentColor: Color(0xFF93C5FD),
              gradientColors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
            );
    }

    if (code == 1 || code == 2) {
      return isDay
          ? const WeatherVisualInfo(
              label: 'Cerah Berawan',
              shortLabel: 'Berawan',
              icon: Icons.wb_cloudy_rounded,
              accentColor: Color(0xFF38BDF8),
              gradientColors: [Color(0xFF1E40AF), Color(0xFF0284C7)],
            )
          : const WeatherVisualInfo(
              label: 'Berawan Sebagian',
              shortLabel: 'Berawan',
              icon: Icons.nights_stay_rounded,
              accentColor: Color(0xFF7DD3FC),
              gradientColors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            );
    }

    if (code == 3) {
      return const WeatherVisualInfo(
        label: 'Mendung / Berawan Tebal',
        shortLabel: 'Mendung',
        icon: Icons.cloud_rounded,
        accentColor: Color(0xFF64748B),
        gradientColors: [Color(0xFF334155), Color(0xFF475569)],
      );
    }

    if (code == 45 || code == 48) {
      return const WeatherVisualInfo(
        label: 'Berkabut',
        shortLabel: 'Kabut',
        icon: Icons.foggy,
        accentColor: Color(0xFF94A3B8),
        gradientColors: [Color(0xFF334155), Color(0xFF64748B)],
      );
    }

    if (code >= 51 && code <= 57) {
      return const WeatherVisualInfo(
        label: 'Gerimis',
        shortLabel: 'Gerimis',
        icon: Icons.grain_rounded,
        accentColor: Color(0xFF38BDF8),
        gradientColors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
      );
    }

    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return WeatherVisualInfo(
        label: code >= 80 ? 'Hujan Lokal / Lebat' : 'Hujan',
        shortLabel: 'Hujan',
        icon: Icons.water_drop_rounded,
        accentColor: const Color(0xFF0EA5E9),
        gradientColors: const [Color(0xFF0F2942), Color(0xFF1D4ED8)],
      );
    }

    if (code >= 71 && code <= 77 || code == 85 || code == 86) {
      return const WeatherVisualInfo(
        label: 'Hujan Salju',
        shortLabel: 'Salju',
        icon: Icons.ac_unit_rounded,
        accentColor: Color(0xFFBAE6FD),
        gradientColors: [Color(0xFF1E3A8A), Color(0xFF64748B)],
      );
    }

    if (code >= 95) {
      return const WeatherVisualInfo(
        label: 'Hujan Petir',
        shortLabel: 'Badai Petir',
        icon: Icons.thunderstorm_rounded,
        accentColor: Color(0xFFFBBF24),
        gradientColors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
      );
    }

    return const WeatherVisualInfo(
      label: 'Berawan',
      shortLabel: 'Berawan',
      icon: Icons.cloud_queue_rounded,
      accentColor: Color(0xFF60A5FA),
      gradientColors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    );
  }
}
