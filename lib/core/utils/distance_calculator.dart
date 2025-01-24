import 'dart:math' as math;

/// Mesafe hesaplama yardımcı sınıfı
/// Single Responsibility: Sadece mesafe hesaplama işlemlerinden sorumlu
class DistanceCalculator {
  /// İki nokta arasındaki mesafeyi metre cinsinden hesaplar
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // metre cinsinden dünya yarıçapı
    
    // Radyana çevir
    final double phi1 = _degreesToRadians(lat1);
    final double phi2 = _degreesToRadians(lat2);
    final double deltaPhi = _degreesToRadians(lat2 - lat1);
    final double deltaLambda = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) * 
        math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Dereceyi radyana çevirir
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
