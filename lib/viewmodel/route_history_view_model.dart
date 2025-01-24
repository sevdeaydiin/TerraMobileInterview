import 'package:flutter/material.dart';
import '../core/base/base_view_model.dart';
import '../services/database_service.dart';
import '../view/screens/route_details_screen.dart';

class RouteHistoryViewModel extends BaseViewModel {
  final DatabaseService _databaseService;
  List<Map<String, dynamic>> _routes = [];

  RouteHistoryViewModel({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  List<Map<String, dynamic>> get routes => _routes;

  @override
  void init() {
    loadRoutes();
  }

  Future<void> loadRoutes() async {
    try {
      setLoading(true);
      _routes = await _databaseService.getAllRoutes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading routes: $e');
    } finally {
      setLoading(false);
    }
  }

  void showRouteDetails(BuildContext context, int routeId) async {
    final points = await _databaseService.getRoutePoints(routeId);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteDetailsScreen(
            routeId: routeId,
            routePoints: points,
          ),
        ),
      );
    }
  }
}
