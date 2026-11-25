import '../../domain/models/location_item.dart';
import '../models/saved_location_dto.dart';
import '../services/geocoding_api_service.dart';
import '../services/local_storage_service.dart';

/// Repository managing city search via Open-Meteo Geocoding API and
/// local persistence of favorites, search history, and active location.
class LocationRepository {
  LocationRepository({
    required GeocodingApiService geocodingApiService,
    required LocalStorageService localStorageService,
  })  : _geocodingApiService = geocodingApiService,
        _localStorageService = localStorageService;

  static const int _maxHistoryItems = 10;

  final GeocodingApiService _geocodingApiService;
  final LocalStorageService _localStorageService;

  /// Searches cities from Open-Meteo Geocoding API.
  Future<List<LocationItem>> searchCities(String query) async {
    final response = await _geocodingApiService.searchLocations(query);
    return response.results.map((dto) => dto.toDomain()).toList();
  }

  /// Resolves the initial location from local storage, or fetches default city from API.
  Future<LocationItem> getOrFetchInitialLocation() async {
    final saved = await _localStorageService.loadSelectedLocation();
    if (saved != null) {
      return saved.toDomain();
    }

    try {
      final results = await searchCities('Purwokerto');
      if (results.isNotEmpty) {
        final first = results.first;
        await saveSelectedLocation(first);
        return first;
      }
    } catch (_) {
      // Fallback to default city coordinates so Weather API can still be queried.
    }

    const fallbackCity = LocationItem(
      id: 1630328,
      name: 'Kota Purwokerto',
      latitude: -7.42139,
      longitude: 109.23444,
      region: 'Jawa Tengah',
      country: 'Indonesia',
      timezone: 'Asia/Jakarta',
    );
    await saveSelectedLocation(fallbackCity);
    return fallbackCity;
  }

  Future<LocationItem?> getSelectedLocation() async {
    final dto = await _localStorageService.loadSelectedLocation();
    return dto?.toDomain();
  }

  Future<void> saveSelectedLocation(LocationItem location) async {
    await _localStorageService.saveSelectedLocation(
      SavedLocationDto.fromDomain(location),
    );
  }

  Future<List<LocationItem>> getFavorites() async {
    final list = await _localStorageService.loadFavorites();
    return list.map((dto) => dto.toDomain()).toList();
  }

  /// Toggles favorite state for [location] and returns the updated list.
  Future<List<LocationItem>> toggleFavorite(LocationItem location) async {
    final current = await getFavorites();
    final exists = current.any((item) => item.uniqueKey == location.uniqueKey);

    final updated = exists
        ? current
            .where((item) => item.uniqueKey != location.uniqueKey)
            .toList()
        : [location, ...current];

    await _localStorageService.saveFavorites(
      updated.map(SavedLocationDto.fromDomain).toList(),
    );
    return updated;
  }

  Future<List<LocationItem>> getSearchHistory() async {
    final list = await _localStorageService.loadHistory();
    return list.map((dto) => dto.toDomain()).toList();
  }

  /// Prepends [location] to recent history (deduplicated, capped at 10 items).
  Future<List<LocationItem>> addToHistory(LocationItem location) async {
    final current = await getSearchHistory();
    final filtered = current
        .where((item) => item.uniqueKey != location.uniqueKey)
        .toList();
    final updated = [location, ...filtered].take(_maxHistoryItems).toList();

    await _localStorageService.saveHistory(
      updated.map(SavedLocationDto.fromDomain).toList(),
    );
    return updated;
  }

  Future<List<LocationItem>> removeFromHistory(LocationItem location) async {
    final current = await getSearchHistory();
    final updated = current
        .where((item) => item.uniqueKey != location.uniqueKey)
        .toList();
    await _localStorageService.saveHistory(
      updated.map(SavedLocationDto.fromDomain).toList(),
    );
    return updated;
  }

  Future<void> clearSearchHistory() async {
    await _localStorageService.saveHistory(const []);
  }

  Future<bool?> getIsDarkMode() => _localStorageService.loadIsDarkMode();

  Future<void> saveIsDarkMode(bool isDark) =>
      _localStorageService.saveIsDarkMode(isDark);
}
