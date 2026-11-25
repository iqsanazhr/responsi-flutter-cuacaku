import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:responsi_flutter/domain/models/location_item.dart';
import 'package:responsi_flutter/ui/core/widgets/atmospheric_sky_background.dart';
import 'package:responsi_flutter/ui/core/widgets/liquid_glass_card.dart';
import 'package:responsi_flutter/ui/core/widgets/press_scale.dart';
import 'package:responsi_flutter/ui/core/widgets/state_feedback_view.dart';
import 'package:responsi_flutter/ui/features/search/views/search_location_screen.dart';
import 'package:responsi_flutter/ui/features/weather/view_models/weather_view_model.dart';
import 'package:responsi_flutter/ui/features/weather/views/forecast_detail_sheet.dart';
import 'package:responsi_flutter/ui/features/weather/views/widgets/current_weather_hero.dart';
import 'package:responsi_flutter/ui/features/weather/views/widgets/daily_forecast_list.dart';
import 'package:responsi_flutter/ui/features/weather/views/widgets/favorite_cities_strip.dart';
import 'package:responsi_flutter/ui/features/weather/views/widgets/weather_metrics_grid.dart';

/// Home / Weather Screen crafted 1:1 after Apple Weather (iOS 26/27 Liquid Glass):
/// live sky canvas, centered ultra-light hero temperature, Liquid Glass bento
/// metrics, 7-day thermal range bars, and floating bottom glass dock.
class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  Future<void> _openSearchScreen() async {
    final weatherVm = context.read<WeatherViewModel>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const SearchLocationScreen(),
      ),
    );
    if (mounted) {
      await weatherVm.syncFavorites();
    }
  }

  Future<void> _handleSelectFavorite(LocationItem location) async {
    await context.read<WeatherViewModel>().selectLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final disableAnim = MediaQuery.disableAnimationsOf(context);
    final currentWeather = weatherVm.forecast?.current;

    return Scaffold(
      backgroundColor: const Color(0xFF0B172A),
      body: AtmosphericSkyBackground(
        weatherCode: currentWeather?.weatherCode ?? 80,
        isDay: currentWeather?.isDay ?? true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: disableAnim
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) {
                    final scale = Tween<double>(begin: 0.96, end: 1.0)
                        .animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: scale, child: child),
                    );
                  },
                  child: _buildBody(context, weatherVm),
                ),
              ),
              _LiquidGlassBottomBar(
                weatherVm: weatherVm,
                onRefresh: weatherVm.isRefreshing
                    ? null
                    : () => weatherVm.refreshWeather(),
                onOpenSearch: _openSearchScreen,
                onSelectCity: _handleSelectFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel weatherVm) {
    switch (weatherVm.status) {
      case WeatherViewStatus.initial:
      case WeatherViewStatus.loading:
        return const LoadingStateView(
          key: ValueKey('weather_loading'),
          message: 'Mengambil data cuaca terbaru dari Open-Meteo...',
        );
      case WeatherViewStatus.error:
        return ErrorStateView(
          key: const ValueKey('weather_error'),
          message: weatherVm.errorMessage ??
              'Terjadi kesalahan saat mengambil data cuaca.',
          onRetry: weatherVm.refreshWeather,
        );
      case WeatherViewStatus.empty:
        return EmptyStateView(
          key: const ValueKey('weather_empty'),
          icon: Icons.location_searching_rounded,
          title: 'Data Cuaca Belum Tersedia',
          subtitle:
              'Pilih kota terlebih dahulu melalui halaman pencarian untuk menampilkan informasi cuaca terkini.',
          actionLabel: 'Cari Kota',
          onAction: _openSearchScreen,
        );
      case WeatherViewStatus.loaded:
        final forecast = weatherVm.forecast;
        if (forecast == null) {
          return EmptyStateView(
            key: const ValueKey('weather_null'),
            icon: Icons.location_searching_rounded,
            title: 'Lokasi Belum Dipilih',
            subtitle: 'Silakan cari kota untuk melihat prakiraan cuaca.',
            actionLabel: 'Cari Kota',
            onAction: _openSearchScreen,
          );
        }

        final isFav = weatherVm.isFavorite(forecast.location);

        return RefreshIndicator(
          key: ValueKey('weather_loaded_${forecast.location.uniqueKey}'),
          color: Colors.white,
          backgroundColor: const Color(0xFF1E3A8A),
          onRefresh: weatherVm.refreshWeather,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (weatherVm.errorMessage != null) ...[
                          _InlineRefreshErrorBanner(
                            message: weatherVm.errorMessage!,
                            onRetry: weatherVm.refreshWeather,
                          ),
                          const SizedBox(height: 12),
                        ],
                        CurrentWeatherHero(
                          forecast: forecast,
                          isFavorite: isFav,
                          onToggleFavorite: () =>
                              weatherVm.toggleFavorite(forecast.location),
                          onOpenSearch: _openSearchScreen,
                        ),
                        const SizedBox(height: 18),
                        FavoriteCitiesStrip(
                          favorites: weatherVm.favorites,
                          selectedLocation: weatherVm.selectedLocation,
                          onSelectCity: _handleSelectFavorite,
                          onOpenSearch: _openSearchScreen,
                        ),
                        const SizedBox(height: 16),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: DailyForecastList(
                                  daily: forecast.daily,
                                  onSelectDay: (day) =>
                                      ForecastDetailSheet.show(
                                    context,
                                    cityName: forecast.location.name,
                                    forecast: day,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 6,
                                child: WeatherMetricsGrid(forecast: forecast),
                              ),
                            ],
                          )
                        else ...[
                          DailyForecastList(
                            daily: forecast.daily,
                            onSelectDay: (day) => ForecastDetailSheet.show(
                              context,
                              cityName: forecast.location.name,
                              forecast: day,
                            ),
                          ),
                          const SizedBox(height: 14),
                          WeatherMetricsGrid(forecast: forecast),
                        ],
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Data cuaca real-time oleh Open-Meteo API',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.58),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}

/// Floating iOS 26/27 Liquid Glass bottom navigation dock with city dots & search trigger.
class _LiquidGlassBottomBar extends StatelessWidget {
  const _LiquidGlassBottomBar({
    required this.weatherVm,
    required this.onRefresh,
    required this.onOpenSearch,
    required this.onSelectCity,
  });

  final WeatherViewModel weatherVm;
  final VoidCallback? onRefresh;
  final VoidCallback onOpenSearch;
  final ValueChanged<LocationItem> onSelectCity;

  @override
  Widget build(BuildContext context) {
    final favorites = weatherVm.favorites;
    final activeKey = weatherVm.selectedLocation?.uniqueKey;
    final isDark = weatherVm.themeMode == ThemeMode.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: LiquidGlassCard(
              borderRadius: 999,
              tintOpacity: 0.18,
              enableBlur: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  PressScale(
                    onTap: onRefresh,
                    borderRadius: BorderRadius.circular(999),
                    child: Tooltip(
                      message: 'Muat ulang cuaca',
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: weatherVm.isRefreshing
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  PressScale(
                    onTap: weatherVm.toggleThemeMode,
                    borderRadius: BorderRadius.circular(999),
                    child: Tooltip(
                      message: isDark
                          ? 'Beralih ke Mode Terang'
                          : 'Beralih ke Mode Gelap',
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: isDark
                              ? const Color(0xFFFDE047)
                              : Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: favorites.isEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.near_me_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    weatherVm.selectedLocation?.name ??
                                        'CuacaKu',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: favorites.map((city) {
                                  final isCurrent = city.uniqueKey == activeKey;
                                  return GestureDetector(
                                    onTap: () => onSelectCity(city),
                                    child: Tooltip(
                                      message: city.name,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 6,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          width: isCurrent ? 18 : 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: isCurrent
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.42),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PressScale(
                    onTap: onOpenSearch,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.24),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.list_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Cari Kota',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _InlineRefreshErrorBanner extends StatelessWidget {
  const _InlineRefreshErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFDE047),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }
}
