import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/map_view_model.dart';
import '../../core/utils/location_formatter.dart';
import '../widgets/map_widget.dart';
import '../../core/providers/theme_provider.dart';

class MapScreen extends StatelessWidget {
  final MapViewModel viewModel;

  const MapScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.selectedRouteId != null ? 'Geçmiş Rota' : 'Terra Mobile'),
        leading: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            if (viewModel.selectedRouteId != null) {
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  viewModel.selectRoute(null);
                  Navigator.pushNamed(context, '/history');
                },
              );
            }
            return IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: themeProvider.toggleTheme,
            );
          },
        ),
        actions: viewModel.selectedRouteId == null
            ? [
                Consumer<MapViewModel>(
                  builder: (context, viewModel, _) {
                    return IconButton(
                      icon: Icon(
                        viewModel.isTracking ? Icons.location_on : Icons.location_off,
                        color: viewModel.isTracking ? Colors.green : Colors.red,
                      ),
                      onPressed: () => viewModel.toggleTracking(),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                ),
              ]
            : null,
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hata: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.init(),
                    child: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              MapWidget(
                currentLocation: viewModel.currentLocation,
                routePoints: viewModel.currentRoutePoints,
                currentDistance: LocationFormatter.formatDistance(viewModel.currentDistance),
                viewModel: viewModel,
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: viewModel.isTracking
                        ? () => viewModel.stopTracking()
                        : () => viewModel.startTracking(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: viewModel.isTracking ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                      viewModel.isTracking
                          ? 'Rotayı Bitir'
                          : 'Rotayı Başlat',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
