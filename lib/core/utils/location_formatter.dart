/// Konum ile ilgili formatlama işlemlerini yapan yardımcı sınıf
/// Single Responsibility: Sadece formatlama işlemlerinden sorumlu
class LocationFormatter {
  /// Mesafeyi okunabilir formata çevirir
  static String formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }
}
