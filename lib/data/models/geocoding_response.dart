import '../../domain/models/location_item.dart';

/// API response DTO for Open-Meteo Geocoding API (`/v1/search`).
class GeocodingResponse {
  const GeocodingResponse({required this.results});

  final List<GeocodingResultDto> results;

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? const [];
    return GeocodingResponse(
      results: rawResults
          .whereType<Map<String, dynamic>>()
          .map(GeocodingResultDto.fromJson)
          .toList(),
    );
  }
}

/// Single location item returned by Open-Meteo Geocoding API.
class GeocodingResultDto {
  const GeocodingResultDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.admin1,
    required this.country,
    required this.timezone,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String admin1;
  final String country;
  final String timezone;

  factory GeocodingResultDto.fromJson(Map<String, dynamic> json) {
    return GeocodingResultDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Lokasi Tidak Diketahui',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      admin1: (json['admin1'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      timezone: (json['timezone'] as String?) ?? 'auto',
    );
  }

  /// Maps raw API DTO to clean Domain model.
  LocationItem toDomain() {
    return LocationItem(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      region: admin1,
      country: country,
      timezone: timezone,
    );
  }
}
