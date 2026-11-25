/// Domain model representing a geographic city/location.
class LocationItem {
  const LocationItem({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.region = '',
    this.country = '',
    this.timezone = 'auto',
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String region;
  final String country;
  final String timezone;

  /// Human-readable subtitle combining administrative region and country.
  String get subtitle {
    final parts = <String>[
      if (region.isNotEmpty) region,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  /// Unique key to compare locations reliably across API and local storage.
  String get uniqueKey =>
      '${id}_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationItem &&
        other.id == id &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(id, latitude, longitude);
}
