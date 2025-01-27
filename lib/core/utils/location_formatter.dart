class LocationFormatter {
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Hızı formatlar (km/h)
  static String formatSpeed(double speedInKmh) {
    return '${speedInKmh.toStringAsFixed(1)} km/h';
  }
}