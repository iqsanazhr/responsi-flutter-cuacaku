import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/weather_response.dart';

/// Custom exception for weather and geocoding API failures.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Service wrapping HTTP GET requests to Open-Meteo Weather Forecast API.
class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const Duration _timeout = Duration(seconds: 25);

  final http.Client _client;

  /// Fetches current and 7-day daily weather forecast using HTTP GET.
  Future<WeatherResponse> fetchForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,is_day',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
      },
    );

    try {
      final response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal memuat data cuaca (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons cuaca tidak valid.');
      }
      if (decoded['error'] == true) {
        final reason = decoded['reason'] as String? ?? 'Kesalahan server API.';
        throw ApiException(reason);
      }

      return WeatherResponse.fromJson(decoded);
    } on TimeoutException {
      throw const ApiException(
        'Waktu permintaan ke server Open-Meteo habis. Periksa koneksi internet Anda.',
      );
    } on SocketException {
      throw const ApiException(
        'Tidak dapat terhubung ke internet. Pastikan perangkat terhubung ke jaringan.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Gagal melakukan koneksi HTTP ke server Open-Meteo.',
      );
    } on FormatException catch (e) {
      throw ApiException('Gagal mengurai data JSON: ${e.message}');
    }
  }
}
