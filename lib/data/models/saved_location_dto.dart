import '../../domain/models/location_item.dart';

/// Local persistence DTO for serializing [LocationItem] into SharedPreferences JSON.
class SavedLocationDto {
  const SavedLocationDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.region,
    required this.country,
    required this.timezone,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String region;
  final String country;
  final String timezone;

  factory SavedLocationDto.fromDomain(LocationItem item) {
    return SavedLocationDto(
      id: item.id,
      name: item.name,
      latitude: item.latitude,
      longitude: item.longitude,
      region: item.region,
      country: item.country,
      timezone: item.timezone,
    );
  }

  factory SavedLocationDto.fromJson(Map<String, dynamic> json) {
    return SavedLocationDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      region: (json['region'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      timezone: (json['timezone'] as String?) ?? 'auto',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'region': region,
      'country': country,
      'timezone': timezone,
    };
  }

  LocationItem toDomain() {
    return LocationItem(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      region: region,
      country: country,
      timezone: timezone,
    );
  }
}
