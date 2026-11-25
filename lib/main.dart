import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'data/repositories/location_repository.dart';
import 'data/repositories/weather_repository.dart';
import 'data/services/geocoding_api_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/weather_api_service.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/search/view_models/search_view_model.dart';
import 'ui/features/weather/view_models/weather_view_model.dart';
import 'ui/features/weather/views/weather_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final weatherApiService = WeatherApiService();
  final geocodingApiService = GeocodingApiService();
  final localStorageService = LocalStorageService();

  final weatherRepository = WeatherRepository(apiService: weatherApiService);
  final locationRepository = LocationRepository(
    geocodingApiService: geocodingApiService,
    localStorageService: localStorageService,
  );

  runApp(
    CuacaKuApp(
      weatherRepository: weatherRepository,
      locationRepository: locationRepository,
    ),
  );
}

/// Root application widget wiring MVVM ViewModels via Provider and Material 3 Theme.
class CuacaKuApp extends StatelessWidget {
  const CuacaKuApp({
    super.key,
    required this.weatherRepository,
    required this.locationRepository,
  });

  final WeatherRepository weatherRepository;
  final LocationRepository locationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            weatherRepository: weatherRepository,
            locationRepository: locationRepository,
          )..initialize(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(
            locationRepository: locationRepository,
          )..loadSavedData(),
        ),
      ],
      child: Consumer<WeatherViewModel>(
        builder: (context, weatherVm, _) {
          return MaterialApp(
            title: 'CuacaKu • Responsi Flutter',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: weatherVm.themeMode,
            home: const WeatherHomeScreen(),
          );
        },
      ),
    );
  }
}
