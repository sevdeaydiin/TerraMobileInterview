import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/location_model.dart';
import '../../core/utils/location_utils.dart';

class RouteDetailsScreen extends StatefulWidget {
  final int routeId;
  final List<LocationModel> routePoints;

  const RouteDetailsScreen({
    super.key,
    required this.routeId,
    required this.routePoints,
  });

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  void _initializeMapData() {
    if (widget.routePoints.isEmpty) return;

    // Başlangıç ve bitiş noktaları için marker'lar
    _markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(
          widget.routePoints.first.latitude,
          widget.routePoints.first.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Başlangıç'),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: LatLng(
          widget.routePoints.last.latitude,
          widget.routePoints.last.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Bitiş'),
      ),
    };

    // Rota çizgisi
    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: widget.routePoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
        color: Colors.blue,
        width: 5,
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (widget.routePoints.isNotEmpty) {
      _fitMapToRoute();
    }
  }

  void _fitMapToRoute() {
    if (widget.routePoints.isEmpty) return;

    double minLat = widget.routePoints.first.latitude;
    double maxLat = widget.routePoints.first.latitude;
    double minLng = widget.routePoints.first.longitude;
    double maxLng = widget.routePoints.first.longitude;

    for (var point in widget.routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalDistance = LocationUtils.calculateTotalDistance(widget.routePoints);
    final duration = widget.routePoints.isEmpty
        ? Duration.zero
        : widget.routePoints.last.timestamp
            .difference(widget.routePoints.first.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota Detayları'),
      ),
      body: Column(
        children: [
          // Rota bilgileri
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.route),
                    const SizedBox(height: 4),
                    Text(
                      LocationUtils.formatDistance(totalDistance),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Mesafe',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.timer),
                    const SizedBox(height: 4),
                    Text(
                      '${duration.inMinutes} dk',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Süre',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.routePoints.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Nokta',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Harita
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.routePoints.isEmpty
                    ? const LatLng(0, 0)
                    : LatLng(
                        widget.routePoints.first.latitude,
                        widget.routePoints.first.longitude,
                      ),
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
