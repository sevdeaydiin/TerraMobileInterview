import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/location_service.dart';
import 'viewmodel/map_view_model.dart';
import 'view/screens/map_screen.dart';
import 'view/screens/route_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
      child: MaterialApp(
        title: 'Terra Mobile',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
      ),
    );
  }
}
