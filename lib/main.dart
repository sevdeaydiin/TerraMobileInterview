import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/location_service.dart';
import 'viewmodel/map_view_model.dart';
import 'view/screens/map_screen.dart';
import 'view/screens/route_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await sp.SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
        ChangeNotifierProvider<MapViewModel>(
          create: (context) => MapViewModel(
            locationService: context.read<LocationService>(),
            databaseService: context.read<DatabaseService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Terra Mobile',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (context) => Consumer<MapViewModel>(
              builder: (context, viewModel, child) => MapScreen(
                viewModel: viewModel,
              ),
            ),
            '/history': (context) => Consumer<MapViewModel>(
              builder: (context, viewModel, child) => RouteHistoryScreen(
                viewModel: viewModel,
              ),
            ),
          },
        );
      },
    );
  }
}
