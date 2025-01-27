## WebSocket Adresi
**WebSocket Bağlantısı**

Uygulama, gerçek zamanlı konum güncellemeleri almak için WebSocket kullanmaktadır. WebSocket, sürekli bir bağlantı sağlayarak sunucu ile istemci arasında veri alışverişi yapar.

**WebSocket Adresi**

WebSocket bağlantısı için kullanılan adres aşağıdaki gibidir:
ws://your-websocket-server-address:port

**Kullanım**

WebSocket bağlantısı, uygulama başlatıldığında location_service.dart dosyasında yapılandırılır. Aşağıda örnek bir bağlantı kodu verilmiştir:

```bash
import 'package:web_socket_channel/web_socket_channel.dart';

class LocationService {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://your-websocket-server-address:port'),
  );

  // Konum güncellemelerini dinleme
  void listenToLocationUpdates() {
    channel.stream.listen((data) {
      // Gelen veriyi işleme
    });
  }
}
```

## SQLite Yapılandırması

**SQLite Veritabanı**

Uygulama, kullanıcıların geçmiş rotalarını saklamak için SQLite veritabanını kullanmaktadır. SQLite, hafif ve yerel bir veritabanı çözümüdür.

**Veritabanı Yapılandırması**

SQLite veritabanı, database_service.dart dosyasında yapılandırılır. Aşağıda örnek bir veritabanı yapılandırma kodu verilmiştir:

```bash

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'routes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE routes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time TEXT,
            end_time TEXT,
            total_distance REAL,
            duration INTEGER,
            average_speed REAL,
            is_active INTEGER
          )
        ''');
      },
    );
  }

  // Rota ekleme
  Future<void> insertRoute(Map<String, dynamic> route) async {
    final db = await database;
    await db.insert('routes', route);
  }

  // Tüm rotaları alma
  Future<List<Map<String, dynamic>>> getAllRoutes() async {
    final db = await database;
    return await db.query('routes');
  }
}

```

**Veritabanı Tabloları**

Uygulama, aşağıdaki tabloyu kullanmaktadır:
- routes: Kullanıcıların geçmiş rotalarını saklamak için.
- id: Rota kimliği (otomatik artan).
- start_time: Rota başlangıç zamanı.
- end_time: Rota bitiş zamanı.
- total_distance: Toplam mesafe.
- duration: Rota süresi (saniye cinsinden).
- average_speed: Ortalama hız (km/saat cinsinden).
- is_active: Rota aktif mi (0 veya 1).

**Kullanım**

Veritabanı işlemleri, DatabaseService sınıfı aracılığıyla gerçekleştirilir. Rota eklemek veya almak için ilgili metodları çağırabilirsiniz.