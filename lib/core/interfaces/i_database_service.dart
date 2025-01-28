import '../../models/location_model.dart';

abstract class IDatabaseService {
  /// Veritabanını başlatır
  Future<void> init();

  /// Mock rotaları yükler
  //Future<void> loadMockRoutes();

  /// Tüm rotaları getirir
  Future<List<Map<String, dynamic>>> getAllRoutes();

  /// Rotanın tüm noktalarını getirir
  Future<List<LocationModel>> getRoutePoints(int routeId);

  /// Yeni bir rota ekler
  Future<int> insertRoute(Map<String, dynamic> route);

  /// Rotaya yeni bir nokta ekler
  Future<void> insertRoutePoint(int routeId, LocationModel point);

  /// Rota bilgilerini günceller
  Future<void> updateRoute(int routeId, Map<String, dynamic> route);

  /// Yeni bir rota oluşturur ve ID'sini döndürür
  Future<void> createRoute();

  /// Rotaya yeni bir nokta ekler
  Future<void> addRoutePoint(int routeId, LocationModel location);

  /// Rotayı sonlandırır ve toplam mesafeyi kaydeder
  Future<void> finalizeRoute(int routeId, double totalDistance);
}
