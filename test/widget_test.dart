import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:responsi_flutter/data/repositories/location_repository.dart';
import 'package:responsi_flutter/data/repositories/weather_repository.dart';
import 'package:responsi_flutter/data/services/geocoding_api_service.dart';
import 'package:responsi_flutter/data/services/local_storage_service.dart';
import 'package:responsi_flutter/data/services/weather_api_service.dart';
import 'package:responsi_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  CuacaKuApp buildTestApp(http.Client client) {
    final storage = LocalStorageService();
    return CuacaKuApp(
      weatherRepository: WeatherRepository(
        apiService: WeatherApiService(client: client),
      ),
      locationRepository: LocationRepository(
        geocodingApiService: GeocodingApiService(client: client),
        localStorageService: storage,
      ),
    );
  }

  Future<void> pumpFrames(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
      'Home screen displays iOS 27 Liquid Glass weather UI and navigates to Search screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});

    final mockClient = MockClient((request) async {
      if (request.url.host == 'geocoding-api.open-meteo.com') {
        final query = request.url.queryParameters['name'] ?? '';
        if (query == 'tidakada') {
          return http.Response(jsonEncode({'generationtime_ms': 0.1}), 200);
        }
        if (query.toLowerCase().contains('bandung')) {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'id': 1650357,
                  'name': 'Bandung',
                  'latitude': -6.9222,
                  'longitude': 107.6069,
                  'admin1': 'Jawa Barat',
                  'country': 'Indonesia',
                  'timezone': 'Asia/Jakarta',
                },
              ],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 1630328,
                'name': 'Kota Purwokerto',
                'latitude': -7.42139,
                'longitude': 109.23444,
                'admin1': 'Jawa Tengah',
                'country': 'Indonesia',
                'timezone': 'Asia/Jakarta',
              },
            ],
          }),
          200,
        );
      }

      final lat = request.url.queryParameters['latitude'] ?? '';
      final isBandung = lat.startsWith('-6.92');

      return http.Response(
        jsonEncode({
          'timezone': 'Asia/Jakarta',
          'timezone_abbreviation': 'GMT+7',
          'current': {
            'time': '2026-11-25T17:00',
            'temperature_2m': isBandung ? 22.4 : 25.1,
            'relative_humidity_2m': isBandung ? 82 : 95,
            'apparent_temperature': isBandung ? 24.0 : 30.7,
            'precipitation': 0.5,
            'weather_code': isBandung ? 2 : 80,
            'wind_speed_10m': 4.5,
            'is_day': 1,
          },
          'daily': {
            'time': ['2026-11-25', '2026-11-26'],
            'weather_code': [80, 2],
            'temperature_2m_max': [29.0, 30.1],
            'temperature_2m_min': [24.4, 23.2],
            'precipitation_probability_max': [100, 60],
          },
        }),
        200,
      );
    });

    await tester.pumpWidget(buildTestApp(mockClient));
    await pumpFrames(tester);

    expect(find.text('Kota Purwokerto'), findsWidgets);
    expect(find.text('25.1°'), findsOneWidget);
    expect(find.text('95%'), findsOneWidget);
    expect(find.text('4.5 km/j'), findsOneWidget);
    expect(find.text('0.5 mm'), findsOneWidget);

    // Toggle Light -> Dark Mode and verify icon switches
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await pumpFrames(tester);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    // Tap bottom dock Search button
    await tester.tap(find.text('Cari Kota'));
    await pumpFrames(tester);

    expect(find.text('Cari Lokasi'), findsOneWidget);

    // Search unknown city -> empty state
    await tester.enterText(find.byType(TextField), 'tidakada');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await pumpFrames(tester);
    expect(find.text('Lokasi Tidak Ditemukan'), findsOneWidget);

    // Search Bandung -> results appear
    await tester.enterText(find.byType(TextField), 'Bandung');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await pumpFrames(tester);

    final bandungResultFinder = find.descendant(
      of: find.byType(ListView),
      matching: find.text('Bandung'),
    );
    expect(bandungResultFinder, findsOneWidget);
    expect(find.text('Jawa Barat, Indonesia'), findsOneWidget);

    // Toggle bookmark favorite on Bandung
    await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
    await pumpFrames(tester);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

    // Select Bandung -> returns to Home and updates weather
    await tester.tap(bandungResultFinder);
    await pumpFrames(tester);

    expect(find.text('Bandung'), findsWidgets);
    expect(find.text('22.4°'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);
  });

  testWidgets('Home screen renders cleanly on wide desktop layout (1024x768)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});

    final mockClient = MockClient((request) async {
      if (request.url.host == 'geocoding-api.open-meteo.com') {
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 1630328,
                'name': 'Kota Purwokerto',
                'latitude': -7.42139,
                'longitude': 109.23444,
                'admin1': 'Jawa Tengah',
                'country': 'Indonesia',
                'timezone': 'Asia/Jakarta',
              },
            ],
          }),
          200,
        );
      }
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
            'weather_code': [80, 2],
            'temperature_2m_max': [29.0, 30.1],
            'temperature_2m_min': [24.4, 23.2],
            'precipitation_probability_max': [100, 60],
          },
        }),
        200,
      );
    });

    await tester.pumpWidget(buildTestApp(mockClient));
    await pumpFrames(tester);

    expect(find.text('Kota Purwokerto'), findsWidgets);
    expect(find.text('25.1°'), findsOneWidget);
  });

  testWidgets('Home screen displays error state and recovers on retry',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    var shouldFail = true;

    final mockClient = MockClient((request) async {
      if (shouldFail) {
        return http.Response('Network error', 503);
      }
      if (request.url.host == 'geocoding-api.open-meteo.com') {
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 1630328,
                'name': 'Kota Purwokerto',
                'latitude': -7.42139,
                'longitude': 109.23444,
                'admin1': 'Jawa Tengah',
                'country': 'Indonesia',
                'timezone': 'Asia/Jakarta',
              },
            ],
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'timezone': 'Asia/Jakarta',
          'timezone_abbreviation': 'GMT+7',
          'current': {
            'time': '2026-11-25T17:00',
            'temperature_2m': 26.0,
            'relative_humidity_2m': 80,
            'apparent_temperature': 28.0,
            'precipitation': 0.0,
            'weather_code': 1,
            'wind_speed_10m': 6.0,
            'is_day': 1,
          },
          'daily': {
            'time': ['2026-11-25'],
            'weather_code': [1],
            'temperature_2m_max': [31.0],
            'temperature_2m_min': [23.0],
            'precipitation_probability_max': [20],
          },
        }),
        200,
      );
    });

    await tester.pumpWidget(buildTestApp(mockClient));
    await pumpFrames(tester);

    expect(find.text('Gagal Memuat Data'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.text('Coba Lagi'));
    await pumpFrames(tester);

    expect(find.text('Kota Purwokerto'), findsWidgets);
    expect(find.text('26.0°'), findsOneWidget);
  });
}
