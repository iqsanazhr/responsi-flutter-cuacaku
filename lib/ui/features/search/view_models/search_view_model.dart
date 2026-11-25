import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:responsi_flutter/data/repositories/location_repository.dart';
import 'package:responsi_flutter/domain/models/location_item.dart';

/// UI states for the Search / Location Screen.
enum SearchViewStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel handling city search via Open-Meteo Geocoding API,
/// persisted favorite locations, and recent search history.
class SearchViewModel extends ChangeNotifier {
  SearchViewModel({required LocationRepository locationRepository})
      : _locationRepository = locationRepository;

  final LocationRepository _locationRepository;

  SearchViewStatus _status = SearchViewStatus.idle;
  String _query = '';
  List<LocationItem> _searchResults = const [];
  List<LocationItem> _favorites = const [];
  List<LocationItem> _history = const [];
  String? _errorMessage;

  Timer? _debounceTimer;
  int _requestSequence = 0;

  SearchViewStatus get status => _status;
  String get query => _query;
  List<LocationItem> get searchResults => List.unmodifiable(_searchResults);
  List<LocationItem> get favorites => List.unmodifiable(_favorites);
  List<LocationItem> get history => List.unmodifiable(_history);
  String? get errorMessage => _errorMessage;

  /// Loads favorites and search history from SharedPreferences.
  Future<void> loadSavedData() async {
    _favorites = await _locationRepository.getFavorites();
    _history = await _locationRepository.getSearchHistory();
    notifyListeners();
  }

  /// Debounces text input changes before calling the Geocoding API.
  void onQueryChanged(String value) {
    _query = value;
    _debounceTimer?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _requestSequence++;
      _searchResults = const [];
      _errorMessage = null;
      _status = SearchViewStatus.idle;
      notifyListeners();
      return;
    }

    if (trimmed.length < 2) {
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      search(trimmed);
    });
  }

  /// Executes an immediate city search against Open-Meteo Geocoding API.
  Future<void> search(String rawQuery) async {
    _debounceTimer?.cancel();
    final trimmed = rawQuery.trim();
    _query = rawQuery;

    if (trimmed.isEmpty) {
      _searchResults = const [];
      _errorMessage = null;
      _status = SearchViewStatus.idle;
      notifyListeners();
      return;
    }

    final currentSeq = ++_requestSequence;
    _status = SearchViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _locationRepository.searchCities(trimmed);
      if (currentSeq != _requestSequence) return;

      _searchResults = results;
      _status = results.isEmpty
          ? SearchViewStatus.empty
          : SearchViewStatus.loaded;
    } catch (e) {
      if (currentSeq != _requestSequence) return;
      _status = SearchViewStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Toggles favorite status for [location] and refreshes persisted list.
  Future<void> toggleFavorite(LocationItem location) async {
    _favorites = await _locationRepository.toggleFavorite(location);
    notifyListeners();
  }

  /// Records a selected location into search history.
  Future<void> recordSelection(LocationItem location) async {
    _history = await _locationRepository.addToHistory(location);
    notifyListeners();
  }

  Future<void> removeHistoryItem(LocationItem location) async {
    _history = await _locationRepository.removeFromHistory(location);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _locationRepository.clearSearchHistory();
    _history = const [];
    notifyListeners();
  }

  bool isFavorite(LocationItem location) {
    return _favorites.any((item) => item.uniqueKey == location.uniqueKey);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
