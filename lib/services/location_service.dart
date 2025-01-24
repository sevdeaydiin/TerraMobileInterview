import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../core/interfaces/i_location_service.dart';
import '../models/location_model.dart';

/// Geolocator kullanarak konum servisi implementasyonu
/// Single Responsibility: Sadece konum işlemlerinden sorumlu
/// Open/Closed: Yeni konum sağlayıcıları eklenebilir
/// Liskov Substitution: ILocationService interface'ini tam olarak implemente eder
class LocationService implements ILocationService {
  StreamController<LocationModel>? _locationController;
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;

  /// Singleton pattern - Dependency Inversion için factory constructor kullanılabilir
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  @override
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Future<LocationModel?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<LocationModel> getLocationStream() {
    _locationController ??= StreamController<LocationModel>.broadcast();
    return _locationController!.stream;
  }

  @override
  Future<void> startLocationUpdates() async {
    if (_isTracking) return;
    _isTracking = true;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10 metrede bir güncelle
      ),
    ).listen((Position position) {
      if (_locationController != null && !_locationController!.isClosed) {
        _locationController!.add(
          LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  Future<void> stopLocationUpdates() async {
    _isTracking = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    stopLocationUpdates();
    _locationController?.close();
    _locationController = null;
  }
}

/// Konum servisi ile ilgili özel hata sınıfı
class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  
  @override
  String toString() => message;
}
