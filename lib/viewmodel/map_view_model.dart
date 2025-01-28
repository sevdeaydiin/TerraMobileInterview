import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/interfaces/i_database_service.dart';
import '../core/interfaces/i_location_service.dart';
import '../models/location_model.dart';
import '../core/constants/filter_constants.dart';
import 'dart:math';

class MapViewModel extends ChangeNotifier {
  final ILocationService _locationService;
  final IDatabaseService _databaseService;
  
  bool _isTracking = false;
  bool get isTracking => _isTracking;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  int? _activeRouteId;
  int? _selectedRouteId;
  List<LocationModel> _routePoints = [];
  Set<Polyline> _polylines = {};
  Set<Polyline> _routePolylines = {};
  Set<Marker> _markers = {};
  LocationModel? _currentLocation;
  List<Map<String, dynamic>> _historicalRoutes = [];
  String _selectedFilter = FilterConstants.dateDesc;
  DateTime? _startDate;
  DateTime? _endDate;
  MapType _mapType = MapType.normal;
  final int _maxVisiblePoints = 1000;

  double _selectedRouteDistance = 0;
  double get selectedRouteDistance => _selectedRouteDistance;

  Set<Polyline> get polylines => _polylines;
  Set<Polyline> get routePolylines => _routePolylines;
  Set<Marker> get markers => _markers;
  LocationModel? get currentLocation => _currentLocation;
  List<LocationModel> get currentRoutePoints => _routePoints;
  double get currentDistance => _calculateTotalDistance();
  List<Map<String, dynamic>> get historicalRoutes => _getFilteredRoutes();
  String get selectedFilter => _selectedFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get canShowRoute => _selectedRouteId != null;
  MapType get mapType => _mapType;
  int? get selectedRouteId => _selectedRouteId;
  
  Function(LatLngBounds)? onCameraMove;
  
  GoogleMapController? _mapController;
  
  MapViewModel({
    required ILocationService locationService,
    required IDatabaseService databaseService,
  })  : _locationService = locationService,
        _databaseService = databaseService {
    _init();
  }
  
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  Future<void> init() async {
    await _init();
  }

  Future<void> _init() async {
    try {
      _setLoading(true);
      await _databaseService.init();
      await _locationService.requestPermission();
      
      _currentLocation = await _locationService.getCurrentLocation();
      notifyListeners();
      
      _locationService.getLocationStream().listen((location) {
        _currentLocation = location;
        if (_isTracking) {
          _routePoints.add(location);
          _updatePolylines();
        }
        notifyListeners();
      });
      
      await _loadHistoricalRoutes();
    } catch (e) {
      _setError('Error initializing MapViewModel: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadHistoricalRoutes() async {
    try {
      _setLoading(true);
      _historicalRoutes = await _databaseService.getAllRoutes();
      notifyListeners();
    } catch (e) {
      _setError('Error loading historical routes: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectRoute(int? routeId) {
    _selectedRouteId = routeId;
    if (routeId == null) {
      _routePolylines.clear();
      _markers.clear();
      _selectedRouteDistance = 0;
    }
    notifyListeners();
  }

  Future<void> showSelectedRoute() async {
    if (_selectedRouteId == null) return;

    try {
      _setLoading(true);
      
      final points = await _databaseService.getRoutePoints(_selectedRouteId!);
      
      if (points.isEmpty) {
        _setError('No points found for selected route');
        return;
      }

      _selectedRouteDistance = 0;
      for (int i = 0; i < points.length - 1; i++) {
        _selectedRouteDistance += _calculateDistance(
          points[i].latitude,
          points[i].longitude,
          points[i + 1].latitude,
          points[i + 1].longitude,
        );
      }

      if (points.length == 1) {
        _routePolylines.clear();
        _markers = {
          Marker(
            markerId: const MarkerId('single_point'),
            position: LatLng(points.first.latitude, points.first.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'Rota Noktası'),
          ),
        };
        notifyListeners();
        return;
      }

      _routePolylines = {
        Polyline(
          polylineId: PolylineId('route_$_selectedRouteId'),
          points: points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(),
          color: Colors.blue,
          width: 5,
        ),
      };

      _markers = {
        Marker(
          markerId: const MarkerId('start'),
          position: LatLng(points.first.latitude, points.first.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Başlangıç'),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: LatLng(points.last.latitude, points.last.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Bitiş'),
        ),
      };

      if (onCameraMove != null && points.length > 1) {
        final routePoints = points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        final bounds = LatLngBounds(
          southwest: LatLng(
            routePoints.map((p) => p.latitude).reduce(min),
            routePoints.map((p) => p.longitude).reduce(min),
          ),
          northeast: LatLng(
            routePoints.map((p) => p.latitude).reduce(max),
            routePoints.map((p) => p.longitude).reduce(max),
          ),
        );
        onCameraMove!(bounds);
      }

      notifyListeners();
    } catch (e) {
      _setError('Error showing selected route: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Future<void> startTracking() async {
    if (!_isTracking) {
      try {
        _setLoading(true);
        
        // Önce mevcut konumu al
        final currentLocation = await _locationService.getCurrentLocation();
        if (currentLocation == null) {
          _setError('Konum alınamadı. Lütfen konum ayarlarınızı kontrol edin.');
          return;
        }

        // Konumu aldıktan sonra kamerayı ayarla
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(currentLocation.latitude, currentLocation.longitude),
                zoom: 17.0,
              ),
            ),
          );
        }

        // Konum alındı ve kamera ayarlandı, şimdi kaydı başlat
        _isTracking = true;
        _routePoints = [currentLocation];
        _polylines.clear();
        
        final routeId = await _databaseService.insertRoute({
          'start_time': DateTime.now().toIso8601String(),
          'is_active': 1,
        });
        _activeRouteId = routeId;
        
        await _databaseService.insertRoutePoint(routeId, currentLocation);
        
        await _locationService.startLocationUpdates();
        
        _locationService.getLocationStream().listen((location) async {
          if (_isTracking && _activeRouteId != null) {
            _routePoints.add(location);
            await _databaseService.insertRoutePoint(_activeRouteId!, location);
            _updatePolylines();
            notifyListeners();
          }
        });
        
        notifyListeners();
      } catch (e) {
        _setError('Rota başlatılırken hata oluştu: $e');
        _isTracking = false;
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<void> stopTracking() async {
    if (_isTracking) {
      _isTracking = false;
      await _locationService.stopLocationUpdates();
      
      try {
        _setLoading(true);
        if (_activeRouteId != null && _routePoints.length >= 2) {
          double totalDistance = 0;
          for (int i = 0; i < _routePoints.length - 1; i++) {
            totalDistance += _calculateDistance(
              _routePoints[i].latitude,
              _routePoints[i].longitude,
              _routePoints[i + 1].latitude,
              _routePoints[i + 1].longitude,
            );
          }
          
          final duration = _routePoints.last.timestamp.difference(_routePoints.first.timestamp).inSeconds;
          
          final averageSpeed = duration > 0 ? (totalDistance / 1000) / (duration / 3600) : 0;
          
          await _databaseService.updateRoute(_activeRouteId!, {
            'end_time': DateTime.now().toIso8601String(),
            'total_distance': totalDistance,
            'duration': duration,
            'average_speed': averageSpeed,
            'is_active': 0,
          });
          
          _activeRouteId = null;
          await _loadHistoricalRoutes();

          _routePoints.clear();
          _polylines.clear();
          _routePolylines.clear();
          _markers.clear();
        }
      } catch (e) {
        _setError('Error stopping tracking: $e');
      } finally {
        _setLoading(false);
      }
      notifyListeners();
    }
  }
  
  void _updatePolylines() {
    if (_routePoints.isEmpty) return;

    final points = _optimizeRoutePoints(_routePoints);
    final List<LatLng> polylinePoints = points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    _polylines = {
      Polyline(
        polylineId: const PolylineId('current_route'),
        points: polylinePoints,
        color: Colors.blue,
        width: 3,
      ),
    };
    notifyListeners();
  }

  List<LocationModel> _optimizeRoutePoints(List<LocationModel> points) {
    if (points.length <= _maxVisiblePoints) return points;

    const tolerance = 0.00001;
    final optimizedPoints = _douglasPeucker(points, tolerance);

    if (optimizedPoints.length > _maxVisiblePoints) {
      final step = optimizedPoints.length ~/ _maxVisiblePoints;
      return List.generate(
        _maxVisiblePoints,
        (i) => optimizedPoints[i * step],
      );
    }

    return optimizedPoints;
  }

  List<LocationModel> _douglasPeucker(List<LocationModel> points, double tolerance) {
    if (points.isEmpty || points.length <= 2) return points;

    double maxDistance = 0;
    int maxIndex = 0;

    final start = points.first;
    final end = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(points[i], start, end);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    if (maxDistance > tolerance) {
      final List<LocationModel> firstHalf = _douglasPeucker(
        points.sublist(0, maxIndex + 1),
        tolerance,
      );
      final List<LocationModel> secondHalf = _douglasPeucker(
        points.sublist(maxIndex),
        tolerance,
      );
      return [...firstHalf.take(firstHalf.length - 1), ...secondHalf];
    }

    return [points.first, points.last];
  }

  double _perpendicularDistance(
    LocationModel point,
    LocationModel lineStart,
    LocationModel lineEnd,
  ) {
    final double area = ((lineEnd.latitude - lineStart.latitude) *
            (point.longitude - lineStart.longitude) -
        (lineEnd.longitude - lineStart.longitude) *
            (point.latitude - lineStart.latitude))
        .abs();
    final double bottom = sqrt(
      pow(lineEnd.latitude - lineStart.latitude, 2) +
          pow(lineEnd.longitude - lineStart.longitude, 2),
    );
    return area / bottom;
  }

  double _calculateTotalDistance() {
    if (_routePoints.length < 2) return 0;
    
    double totalDistance = 0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        _routePoints[i].latitude,
        _routePoints[i].longitude,
        _routePoints[i + 1].latitude,
        _routePoints[i + 1].longitude,
      );
    }
    return totalDistance;
  }
  
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  
  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  List<Map<String, dynamic>> _getFilteredRoutes() {
    var filteredRoutes = List<Map<String, dynamic>>.from(_historicalRoutes);

    if (_startDate != null || _endDate != null) {
      filteredRoutes = filteredRoutes.where((route) {
        final routeDate = DateTime.parse(route['start_time'] as String);
        if (_startDate != null && routeDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && routeDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }
        return true;
      }).toList();
    }

    switch (_selectedFilter) {
      case FilterConstants.dateAsc:
        filteredRoutes.sort((a, b) => DateTime.parse(b['start_time'] as String)
            .compareTo(DateTime.parse(a['start_time'] as String)));
        break;
      case FilterConstants.dateDesc:
        filteredRoutes.sort((a, b) => DateTime.parse(a['start_time'] as String)
            .compareTo(DateTime.parse(b['start_time'] as String)));
        break;
      case FilterConstants.distanceAsc:
        filteredRoutes.sort((a, b) => ((a['total_distance'] as num?)?.toDouble() ?? 0.0)
            .compareTo((b['total_distance'] as num?)?.toDouble() ?? 0.0));
        break;
      case FilterConstants.distanceDesc:
        filteredRoutes.sort((a, b) => ((b['total_distance'] as num?)?.toDouble() ?? 0.0)
            .compareTo((a['total_distance'] as num?)?.toDouble() ?? 0.0));
        break;
      case FilterConstants.durationAsc:
        filteredRoutes.sort((a, b) => (a['duration'] as int? ?? 0)
            .compareTo(b['duration'] as int? ?? 0));
        break;
      case FilterConstants.durationDesc:
        filteredRoutes.sort((a, b) => (b['duration'] as int? ?? 0)
            .compareTo(a['duration'] as int? ?? 0));
        break;
    }

    return filteredRoutes;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    debugPrint(_errorMessage);
    notifyListeners();
  }

  void changeMapType() {
    switch (_mapType) {
      case MapType.normal:
        _mapType = MapType.satellite;
        break;
      case MapType.satellite:
        _mapType = MapType.hybrid;
        break;
      case MapType.hybrid:
        _mapType = MapType.normal;
        break;
      default:
        _mapType = MapType.normal;
    }
    notifyListeners();
  }

  Future<List<LatLng>?> getDirections(LatLng origin, LatLng destination, List<LocationModel> waypoints) async {
    try {
      final url = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'waypoints': waypoints.map((p) => '${p.latitude},${p.longitude}').join('|'),
          'mode': 'walking',
          'key': 'AIzaSyCY5fBwejF-Qv0h93Ii7doiWgRxqJ1hB_Y',
        },
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
          return points;
        }
      }
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

}