import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/geocoding_response.dart';
import 'weather_api_service.dart';

/// Service wrapping HTTP GET requests to Open-Meteo Geocoding API.
class GeocodingApiService {
  GeocodingApiService({http.Client? client})
      : _client = client ?? http.Client();

  static const String _baseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const Duration _timeout = Duration(seconds: 25);

  final http.Client _client;

  /// Searches cities/locations matching [query] via HTTP GET.
  Future<GeocodingResponse> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const GeocodingResponse(results: []);
    }

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'name': trimmed,
        'count': '15',
        'language': 'id',
        'format': 'json',
      },
    );

    try {
      final response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal mencari lokasi (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons pencarian lokasi tidak valid.');
      }

      return GeocodingResponse.fromJson(decoded);
    } on TimeoutException {
      throw const ApiException(
        'Waktu pencarian lokasi habis. Coba lagi beberapa saat.',
      );
    } on SocketException {
      throw const ApiException(
        'Tidak dapat terhubung ke internet saat mencari kota.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Gagal menghubungi server Open-Meteo Geocoding.',
      );
    } on FormatException catch (e) {
      throw ApiException('Gagal mengurai hasil pencarian JSON: ${e.message}');
    }
  }
}
