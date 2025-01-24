import '../../models/location_model.dart';

/// Location servisi için interface
/// Single Responsibility: Sadece konum işlemlerinden sorumlu
/// Interface Segregation: Sadece gerekli metodları içerir
abstract class ILocationService {
  /// İzin isteği gönderir
  Future<bool> requestPermission();

  /// Mevcut konumu döndürür
  Future<LocationModel?> getCurrentLocation();

  /// Konum güncellemelerini dinlemek için stream
  Stream<LocationModel> getLocationStream();

  /// Konum güncellemelerini başlatır
  Future<void> startLocationUpdates();

  /// Konum güncellemelerini durdurur
  Future<void> stopLocationUpdates();
}
