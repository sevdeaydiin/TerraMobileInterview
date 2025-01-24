import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/database_service.dart';
import '../../viewmodel/map_view_model.dart';
import '../../viewmodel/route_history_view_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/location_formatter.dart';
import '../widgets/map_widget.dart';
import 'route_history_screen.dart';

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
        title: const Text('Terra Mobile'),
        actions: [
          Consumer<MapViewModel>(
            builder: (context, viewModel, _) {
              return IconButton(
                icon: Icon(
                  viewModel.isTracking ? Icons.wifi : Icons.wifi_off,
                  color: viewModel.isTracking ? Colors.green : Colors.red,
                ),
                onPressed: null,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
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
