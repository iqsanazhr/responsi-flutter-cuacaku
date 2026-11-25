import 'current_weather.dart';
import 'daily_forecast.dart';
import 'location_item.dart';

/// Aggregate domain model combining location metadata, current weather, and daily forecast.
class WeatherForecast {
  const WeatherForecast({
    required this.location,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.current,
    required this.daily,
  });

  final LocationItem location;
  final String timezone;
  final String timezoneAbbreviation;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  /// Convenience getter for today's forecast summary if available.
  DailyForecast? get todayForecast => daily.isNotEmpty ? daily.first : null;
}
