import '../../domain/models/location_item.dart';
import '../../domain/models/weather_forecast.dart';
import '../services/weather_api_service.dart';

/// Repository acting as the single source of truth for weather forecast data.
class WeatherRepository {
  WeatherRepository({required WeatherApiService apiService})
      : _apiService = apiService;

  final WeatherApiService _apiService;

  /// Fetches live weather forecast from Open-Meteo and maps it to [WeatherForecast].
  Future<WeatherForecast> getWeatherForLocation(LocationItem location) async {
    final response = await _apiService.fetchForecast(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    return response.toDomain(location);
  }
}
