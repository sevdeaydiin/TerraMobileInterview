import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/location_formatter.dart';
import '../../models/location_model.dart';
import '../../viewmodel/map_view_model.dart';

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
        CameraUpdate.newLatLngBounds(bounds, 50), // 50 piksel padding
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
          markers: _createMarkers(),
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
                  widget.currentDistance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        // Rota gösterme butonu
        if (widget.viewModel.canShowRoute)
          Positioned(
            top: MediaQuery.of(context).padding.top + 152,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: widget.viewModel.showSelectedRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Rotayı Göster'),
            ),
          ),
        // Zoom butonları
        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 100,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: "btn_zoom_in",
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {
                  if (_mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  }
                },
                child: const Icon(
                  Icons.add,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "btn_zoom_out",
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {
                  if (_mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  }
                },
                child: const Icon(
                  Icons.remove,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // Konum butonu
        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: FloatingActionButton(
            heroTag: 'my_location',
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.my_location,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Set<Marker> _createMarkers() {
    final markers = <Marker>{};
    if (widget.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            widget.currentLocation!.latitude,
            widget.currentLocation!.longitude,
          ),
        ),
      );
    }
    return markers;
  }
}
