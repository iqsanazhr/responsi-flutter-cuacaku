import '../../domain/models/current_weather.dart';
import '../../domain/models/daily_forecast.dart';
import '../../domain/models/location_item.dart';
import '../../domain/models/weather_forecast.dart';

/// API response DTO for Open-Meteo Weather Forecast API (`/v1/forecast`).
class WeatherResponse {
  const WeatherResponse({
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.current,
    required this.daily,
  });

  final String timezone;
  final String timezoneAbbreviation;
  final CurrentWeatherDto current;
  final DailyWeatherDto daily;

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>?;
    final dailyMap = json['daily'] as Map<String, dynamic>?;

    if (currentMap == null || dailyMap == null) {
      throw const FormatException(
        'Struktur respons API cuaca tidak lengkap (current/daily tidak ditemukan).',
      );
    }

    return WeatherResponse(
      timezone: (json['timezone'] as String?) ?? 'auto',
      timezoneAbbreviation: (json['timezone_abbreviation'] as String?) ?? 'GMT',
      current: CurrentWeatherDto.fromJson(currentMap),
      daily: DailyWeatherDto.fromJson(dailyMap),
    );
  }

  /// Maps raw API response DTO into clean [WeatherForecast] domain model.
  WeatherForecast toDomain(LocationItem location) {
    return WeatherForecast(
      location: location,
      timezone: timezone,
      timezoneAbbreviation: timezoneAbbreviation,
      current: current.toDomain(),
      daily: daily.toDomainList(),
    );
  }
}

/// DTO for `current` object in Open-Meteo Forecast response.
class CurrentWeatherDto {
  const CurrentWeatherDto({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.isDay,
  });

  final String time;
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final int isDay;

  factory CurrentWeatherDto.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherDto(
      time: (json['time'] as String?) ?? DateTime.now().toIso8601String(),
      temperature2m: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      isDay: (json['is_day'] as num?)?.toInt() ?? 1,
    );
  }

  CurrentWeather toDomain() {
    return CurrentWeather(
      time: DateTime.tryParse(time) ?? DateTime.now(),
      temperature2m: temperature2m,
      relativeHumidity2m: relativeHumidity2m,
      apparentTemperature: apparentTemperature,
      precipitation: precipitation,
      weatherCode: weatherCode,
      windSpeed10m: windSpeed10m,
      isDay: isDay == 1,
    );
  }
}

/// DTO for `daily` parallel arrays in Open-Meteo Forecast response.
class DailyWeatherDto {
  const DailyWeatherDto({
    required this.time,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
  });

  final List<String> time;
  final List<int> weatherCode;
  final List<double> temperature2mMax;
  final List<double> temperature2mMin;
  final List<int> precipitationProbabilityMax;

  factory DailyWeatherDto.fromJson(Map<String, dynamic> json) {
    return DailyWeatherDto(
      time: (json['time'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      weatherCode: (json['weather_code'] as List<dynamic>? ?? const [])
          .map((e) => (e as num?)?.toInt() ?? 0)
          .toList(),
      temperature2mMax:
          (json['temperature_2m_max'] as List<dynamic>? ?? const [])
              .map((e) => (e as num?)?.toDouble() ?? 0.0)
              .toList(),
      temperature2mMin:
          (json['temperature_2m_min'] as List<dynamic>? ?? const [])
              .map((e) => (e as num?)?.toDouble() ?? 0.0)
              .toList(),
      precipitationProbabilityMax:
          (json['precipitation_probability_max'] as List<dynamic>? ?? const [])
              .map((e) => (e as num?)?.toInt() ?? 0)
              .toList(),
    );
  }

  List<DailyForecast> toDomainList() {
    final count = time.length;
    final items = <DailyForecast>[];
    for (var i = 0; i < count; i++) {
      final parsedDate = DateTime.tryParse(time[i]);
      if (parsedDate == null) continue;
      items.add(
        DailyForecast(
          date: parsedDate,
          weatherCode: i < weatherCode.length ? weatherCode[i] : 0,
          temperatureMax:
              i < temperature2mMax.length ? temperature2mMax[i] : 0.0,
          temperatureMin:
              i < temperature2mMin.length ? temperature2mMin[i] : 0.0,
          precipitationProbabilityMax: i < precipitationProbabilityMax.length
              ? precipitationProbabilityMax[i]
              : 0,
        ),
      );
    }
    return items;
  }
}
