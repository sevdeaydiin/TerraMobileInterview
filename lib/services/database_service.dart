import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants/app_constants.dart';
import '../core/interfaces/i_database_service.dart';
import '../models/location_model.dart';

class DatabaseService implements IDatabaseService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  @override
  Future<void> init() async {
    if (_db != null) return;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.dbName);

    _db = await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE routes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time TEXT NOT NULL,
            end_time TEXT,
            total_distance REAL DEFAULT 0.0,
            duration INTEGER DEFAULT 0,
            average_speed REAL DEFAULT 0.0,
            is_active INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE route_points(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            route_id INTEGER,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (route_id) REFERENCES routes (id) ON DELETE CASCADE
          )
        ''');
      },
    );

    // Veritabanı boşsa mock verileri ekle
    //final routes = 
    await getAllRoutes();
    // if (routes.isEmpty) {
    //   await loadMockRoutes();
    // }
  }

/*   @override
  Future<void> loadMockRoutes() async {
    final db = await database;

    // Konya'da gerçek konumlarla mock rotalar
    final routes = [
      {
        'id': 1,
        'start_time': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'end_time': DateTime.now().subtract(const Duration(days: 1, hours: -1)).toIso8601String(),
        'total_distance': 2.5,
        'duration': 3600,
        'average_speed': 2.5,
        'is_active': 0,
        'points': [
          {'latitude': 37.8716, 'longitude': 32.4846}, // Mevlana Müzesi
          {'latitude': 37.8725, 'longitude': 32.4882}, // Şems-i Tebrizi Camii
          {'latitude': 37.8694, 'longitude': 32.4829}, // Kayalı Park
        ]
      },
      {
        'id': 2,
        'start_time': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'end_time': DateTime.now().subtract(const Duration(days: 2, hours: -1)).toIso8601String(),
        'total_distance': 3.0,
        'duration': 4500,
        'average_speed': 2.4,
        'is_active': 0,
        'points': [
          {'latitude': 37.8735, 'longitude': 32.4867}, // Alaeddin Tepesi
          {'latitude': 37.8719, 'longitude': 32.4842}, // Mevlana Müzesi
          {'latitude': 37.8675, 'longitude': 32.4815}, // Zafer Meydanı
        ]
      },
    ];

    for (final route in routes) {
      final points = route.remove('points') as List;
      final routeId = await db.insert('routes', route);

      // Rotaya ait noktaları ekle
      for (final point in points) {
        await db.insert('route_points', {
          'route_id': routeId,
          'latitude': point['latitude'],
          'longitude': point['longitude'],
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }
  } */

  @override
  Future<List<Map<String, dynamic>>> getAllRoutes() async {
    final db = await database;
    return await db.query(
      'routes',
      where: 'is_active = 0',
      orderBy: 'start_time DESC',
    );
  }

  @override
  Future<List<LocationModel>> getRoutePoints(int routeId) async {
    final db = await database;
    final points = await db.query(
      'route_points',
      where: 'route_id = ?',
      whereArgs: [routeId],
      orderBy: 'timestamp ASC',
    );

    return points.map((point) => LocationModel(
      latitude: point['latitude'] as double,
      longitude: point['longitude'] as double,
      timestamp: DateTime.parse(point['timestamp'] as String),
    )).toList();
  }

  @override
  Future<int> insertRoute(Map<String, dynamic> route) async {
    final db = await database;
    return await db.insert('routes', route);
  }

  @override
  Future<void> insertRoutePoint(int routeId, LocationModel point) async {
    final db = await database;
    await db.insert('route_points', {
      'route_id': routeId,
      'latitude': point.latitude,
      'longitude': point.longitude,
      'timestamp': point.timestamp.toIso8601String(),
    });
  }

  @override
  Future<void> updateRoute(int routeId, Map<String, dynamic> route) async {
    final db = await database;
    await db.update(
      'routes',
      route,
      where: 'id = ?',
      whereArgs: [routeId],
    );
  }

  @override
  Future<void> createRoute() async {
    final db = await database;
    await db.insert('routes', {
      'start_time': DateTime.now().toIso8601String(),
      'is_active': 1,
    });
  }

  @override
  Future<void> addRoutePoint(int routeId, LocationModel location) async {
    final db = await database;
    await db.insert('route_points', {
      'route_id': routeId,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': location.timestamp.toIso8601String(),
    });
  }

  @override
  Future<void> finalizeRoute(int routeId, double totalDistance) async {
    final db = await database;
    await db.update(
      'routes',
      {
        'end_time': DateTime.now().toIso8601String(),
        'total_distance': totalDistance,
        'is_active': 0,
      },
      where: 'id = ?',
      whereArgs: [routeId],
    );
  }
}
