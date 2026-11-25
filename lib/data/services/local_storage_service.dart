import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_location_dto.dart';

/// Local storage wrapper backed by [SharedPreferences].
///
/// Persists favorite locations, search history, and the last selected city
/// so saved user data is automatically restored when the app launches.
class LocalStorageService {
  LocalStorageService({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _favoritesKey = 'saved_favorite_locations_v1';
  static const String _historyKey = 'search_history_locations_v1';
  static const String _selectedLocationKey = 'last_selected_location_v1';
  static const String _themeModeKey = 'app_theme_mode_v1';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool?> loadIsDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_themeModeKey);
  }

  Future<void> saveIsDarkMode(bool isDark) async {
    final prefs = await _prefs;
    await prefs.setBool(_themeModeKey, isDark);
  }

  Future<List<SavedLocationDto>> loadFavorites() => _loadList(_favoritesKey);

  Future<void> saveFavorites(List<SavedLocationDto> items) =>
      _saveList(_favoritesKey, items);

  Future<List<SavedLocationDto>> loadHistory() => _loadList(_historyKey);

  Future<void> saveHistory(List<SavedLocationDto> items) =>
      _saveList(_historyKey, items);

  Future<SavedLocationDto?> loadSelectedLocation() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_selectedLocationKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return SavedLocationDto.fromJson(map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSelectedLocation(SavedLocationDto location) async {
    final prefs = await _prefs;
    await prefs.setString(_selectedLocationKey, jsonEncode(location.toJson()));
  }

  Future<List<SavedLocationDto>> _loadList(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SavedLocationDto.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveList(String key, List<SavedLocationDto> items) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(key, encoded);
  }
}
