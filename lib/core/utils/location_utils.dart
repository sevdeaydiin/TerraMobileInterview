import 'dart:math' as math;
import '../../models/location_model.dart';

class LocationUtils {
  static double calculateDistance(LocationModel point1, LocationModel point2) {
    const double earthRadius = 6371000;
    
    final lat1 = _degreesToRadians(point1.latitude);
    final lat2 = _degreesToRadians(point2.latitude);
    final lon1 = _degreesToRadians(point1.longitude);
    final lon2 = _degreesToRadians(point2.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  static double calculateTotalDistance(List<LocationModel> route) {
    if (route.length < 2) return 0;
    
    double totalDistance = 0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(route[i], route[i + 1]);
    }
    
    return totalDistance;
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
