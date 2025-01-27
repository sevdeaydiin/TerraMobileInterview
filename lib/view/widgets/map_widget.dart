import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../models/location_model.dart';
import '../../viewmodel/map_view_model.dart';
import '../../core/utils/location_formatter.dart';

class MapWidget extends StatefulWidget {
  final LocationModel? currentLocation;
  final List<LocationModel> routePoints;
  final String currentDistance;
  final MapViewModel viewModel;

  const MapWidget({
    super.key,
    this.currentLocation,
    required this.routePoints,
    required this.currentDistance,
    required this.viewModel,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    widget.viewModel.onCameraMove = _moveCamera;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.viewModel.onMapCreated(controller);
  }

  void _moveCamera(LatLngBounds bounds) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  void _goToCurrentLocation() {
    if (_mapController != null && widget.currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            widget.currentLocation!.latitude,
            widget.currentLocation!.longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              AppConstants.konyaLatitude,
              AppConstants.konyaLongitude,
            ),
            zoom: 13,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          polylines: widget.viewModel.routePolylines,
          markers: widget.viewModel.markers,
          mapType: widget.viewModel.mapType,
        ),
        // Mesafe göstergesi
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_walk,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.viewModel.selectedRouteId != null
                      ? LocationFormatter.formatDistance(widget.viewModel.selectedRouteDistance)
                      : widget.currentDistance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.viewModel.canShowRoute) ...[
                FloatingActionButton(
                  heroTag: 'showRouteButton',
                  onPressed: widget.viewModel.showSelectedRoute,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.route, size: 28),
                ),
                const SizedBox(height: 8),
              ],
              FloatingActionButton.small(
                heroTag: 'zoomInButton',
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.zoomIn(),
                  );
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              // Zoom Out butonu
              FloatingActionButton.small(
                heroTag: 'zoomOutButton',
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.zoomOut(),
                  );
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'mapTypeButton',
                onPressed: widget.viewModel.changeMapType,
                child: Icon(_getMapTypeIcon(), size: 28),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'currentLocationButton',
                onPressed: _goToCurrentLocation,
                child: const Icon(Icons.my_location, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getMapTypeIcon() {
    switch (widget.viewModel.mapType) {
      case MapType.satellite:
        return Icons.satellite_alt;
      case MapType.hybrid:
        return Icons.layers;
      case MapType.normal:
      default:
        return Icons.map;
    }
  }
}