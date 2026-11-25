import 'package:flutter/material.dart';

import 'package:responsi_flutter/data/repositories/location_repository.dart';
import 'package:responsi_flutter/data/repositories/weather_repository.dart';
import 'package:responsi_flutter/domain/models/location_item.dart';
import 'package:responsi_flutter/domain/models/weather_forecast.dart';

/// UI states for the Home / Weather Screen.
enum WeatherViewStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel managing weather data, active city, favorites, and theme preference.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({
    required WeatherRepository weatherRepository,
    required LocationRepository locationRepository,
  })  : _weatherRepository = weatherRepository,
        _locationRepository = locationRepository;

  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;

  WeatherViewStatus _status = WeatherViewStatus.initial;
  WeatherForecast? _forecast;
  LocationItem? _selectedLocation;
  List<LocationItem> _favorites = const [];
  String? _errorMessage;
  bool _isRefreshing = false;
  ThemeMode _themeMode = ThemeMode.light;

  WeatherViewStatus get status => _status;
  WeatherForecast? get forecast => _forecast;
  LocationItem? get selectedLocation => _selectedLocation;
  List<LocationItem> get favorites => List.unmodifiable(_favorites);
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;
  ThemeMode get themeMode => _themeMode;

  /// Loads persisted favorites and active location, then fetches live weather.
  Future<void> initialize() async {
    _status = WeatherViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final isDark = await _locationRepository.getIsDarkMode();
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
      _favorites = await _locationRepository.getFavorites();
      final initialLocation = await _locationRepository.getOrFetchInitialLocation();
      _selectedLocation = initialLocation;
      await _fetchWeather(initialLocation);
    } catch (e) {
      _status = WeatherViewStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Selects a new city, persists it as active & in history, and loads live weather.
  Future<void> selectLocation(LocationItem location) async {
    _selectedLocation = location;
    _status = WeatherViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await _locationRepository.saveSelectedLocation(location);
    await _locationRepository.addToHistory(location);
    await _fetchWeather(location);
  }

  /// Refreshes weather data for the currently selected location.
  Future<void> refreshWeather() async {
    final location = _selectedLocation;
    if (location == null) {
      await initialize();
      return;
    }

    if (_forecast == null) {
      _status = WeatherViewStatus.loading;
    }
    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _weatherRepository.getWeatherForLocation(location);
      _forecast = result;
      _status = result.daily.isEmpty
          ? WeatherViewStatus.empty
          : WeatherViewStatus.loaded;
    } catch (e) {
      if (_forecast == null) {
        _status = WeatherViewStatus.error;
      }
      _errorMessage = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Toggles favorite status for [location] and persists to local storage.
  Future<void> toggleFavorite(LocationItem location) async {
    _favorites = await _locationRepository.toggleFavorite(location);
    notifyListeners();
  }

  /// Reloads favorites from repository (e.g. after returning from Search screen).
  Future<void> syncFavorites() async {
    _favorites = await _locationRepository.getFavorites();
    notifyListeners();
  }

  bool isFavorite(LocationItem location) {
    return _favorites.any((item) => item.uniqueKey == location.uniqueKey);
  }

  Future<void> toggleThemeMode() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _locationRepository.saveIsDarkMode(_themeMode == ThemeMode.dark);
  }

  Future<void> _fetchWeather(LocationItem location) async {
    try {
      final result = await _weatherRepository.getWeatherForLocation(location);
      _forecast = result;
      _status = result.daily.isEmpty
          ? WeatherViewStatus.empty
          : WeatherViewStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = WeatherViewStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
