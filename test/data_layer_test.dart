import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_flutter/data/models/saved_location_dto.dart';
import 'package:responsi_flutter/data/services/geocoding_api_service.dart';
import 'package:responsi_flutter/data/services/local_storage_service.dart';
import 'package:responsi_flutter/data/services/weather_api_service.dart';
import 'package:responsi_flutter/domain/models/location_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WeatherApiService', () {
    test('sends HTTP GET with required Open-Meteo params and parses JSON',
        () async {
      late Uri capturedUri;
      final client = MockClient((request) async {
        expect(request.method, equals('GET'));
        capturedUri = request.url;
        return http.Response(
          jsonEncode({
            'timezone': 'Asia/Jakarta',
            'timezone_abbreviation': 'GMT+7',
            'current': {
              'time': '2026-11-25T17:00',
              'temperature_2m': 25.1,
              'relative_humidity_2m': 95,
              'apparent_temperature': 30.7,
              'precipitation': 0.5,
              'weather_code': 80,
              'wind_speed_10m': 4.5,
              'is_day': 1,
            },
            'daily': {
              'time': ['2026-11-25', '2026-11-26'],
              'weather_code': [81, 80],
              'temperature_2m_max': [29.0, 28.1],
              'temperature_2m_min': [24.4, 23.3],
              'precipitation_probability_max': [100, 95],
            },
          }),
          200,
        );
      });

      final service = WeatherApiService(client: client);
      final response = await service.fetchForecast(
        latitude: -7.4214,
        longitude: 109.2344,
      );

      expect(capturedUri.host, equals('api.open-meteo.com'));
      expect(capturedUri.queryParameters['latitude'], equals('-7.4214'));
      expect(capturedUri.queryParameters['longitude'], equals('109.2344'));
      expect(capturedUri.queryParameters['timezone'], equals('auto'));
      expect(
        capturedUri.queryParameters['current'],
        contains('temperature_2m'),
      );
      expect(
        capturedUri.queryParameters['daily'],
        contains('precipitation_probability_max'),
      );

      final domain = response.toDomain(
        const LocationItem(
          id: 1,
          name: 'Purwokerto',
          latitude: -7.4214,
          longitude: 109.2344,
        ),
      );
      expect(domain.current.temperature2m, equals(25.1));
      expect(domain.current.relativeHumidity2m, equals(95));
      expect(domain.current.apparentTemperature, equals(30.7));
      expect(domain.current.precipitation, equals(0.5));
      expect(domain.current.weatherCode, equals(80));
      expect(domain.current.windSpeed10m, equals(4.5));
      expect(domain.daily, hasLength(2));
      expect(domain.daily.first.temperatureMax, equals(29.0));
      expect(domain.daily.first.temperatureMin, equals(24.4));
      expect(domain.daily.first.precipitationProbabilityMax, equals(100));
    });

    test('throws ApiException on non-200 status code', () async {
      final client = MockClient(
        (_) async => http.Response('Server error', 500),
      );
      final service = WeatherApiService(client: client);

      expect(
        () => service.fetchForecast(latitude: -7.4, longitude: 109.2),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('GeocodingApiService', () {
    test('returns empty list when API omits results key', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'generationtime_ms': 0.1}),
          200,
        ),
      );
      final service = GeocodingApiService(client: client);

      final response = await service.searchLocations('zzzzqqqq');
      expect(response.results, isEmpty);
    });
  });

  group('LocalStorageService', () {
    test('persists and restores favorites, history, and selected location',
        () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageService();

      const city = SavedLocationDto(
        id: 1630328,
        name: 'Kota Purwokerto',
        latitude: -7.42139,
        longitude: 109.23444,
        region: 'Jawa Tengah',
        country: 'Indonesia',
        timezone: 'Asia/Jakarta',
      );

      await storage.saveFavorites([city]);
      await storage.saveHistory([city]);
      await storage.saveSelectedLocation(city);

      final loadedFavs = await storage.loadFavorites();
      final loadedHistory = await storage.loadHistory();
      final loadedSelected = await storage.loadSelectedLocation();

      expect(loadedFavs, hasLength(1));
      expect(loadedFavs.first.name, equals('Kota Purwokerto'));
      expect(loadedHistory, hasLength(1));
      expect(loadedSelected?.name, equals('Kota Purwokerto'));
    });
  });
}
