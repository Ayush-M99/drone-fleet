import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/drone.dart';
import '../models/alert.dart';

// In-memory store used on Web (sqflite is not supported on web)
class _MemStore {
  final List<Map<String, dynamic>> drones = [];
  final List<Map<String, dynamic>> alerts = [];
  int _droneSeq = 1;
  int _alertSeq = 1;

  int insertDrone(Map<String, dynamic> m) {
    final id = _droneSeq++;
    drones.add({...m, 'id': id});
    return id;
  }

  List<Map<String, dynamic>> getDrones() => List.unmodifiable(drones);

  void updateDrone(Map<String, dynamic> m) {
    final idx = drones.indexWhere((d) => d['id'] == m['id']);
    if (idx != -1) drones[idx] = m;
  }

  void deleteDrone(int id) {
    drones.removeWhere((d) => d['id'] == id);
    alerts.removeWhere((a) => a['droneId'] == id);
  }

  int insertAlert(Map<String, dynamic> m) {
    final id = _alertSeq++;
    alerts.insert(0, {...m, 'id': id});
    return id;
  }

  List<Map<String, dynamic>> getAlerts() => List.unmodifiable(alerts);
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;
  static final _mem = _MemStore();

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'drone_fleet.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE drones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        droneType TEXT NOT NULL,
        batteryLevel REAL NOT NULL,
        signalStrength INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL NOT NULL,
        status TEXT NOT NULL,
        missionStatus TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        droneId INTEGER NOT NULL,
        alertType TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (droneId) REFERENCES drones(id)
      )
    ''');
  }

  // --- Drone CRUD ---

  Future<int> insertDrone(Drone drone) async {
    if (kIsWeb) return _mem.insertDrone(drone.toMap());
    final db = await database;
    return await db.insert('drones', drone.toMap());
  }

  Future<List<Drone>> getDrones() async {
    if (kIsWeb) {
      return _mem.getDrones().map((m) => Drone.fromMap(m)).toList();
    }
    final db = await database;
    final maps = await db.query('drones', orderBy: 'id ASC');
    return maps.map((m) => Drone.fromMap(m)).toList();
  }

  Future<Drone?> getDroneById(int id) async {
    if (kIsWeb) {
      final m = _mem.getDrones().firstWhere(
            (d) => d['id'] == id,
            orElse: () => {},
          );
      return m.isEmpty ? null : Drone.fromMap(m);
    }
    final db = await database;
    final maps = await db.query('drones', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Drone.fromMap(maps.first);
  }

  Future<int> updateDrone(Drone drone) async {
    if (kIsWeb) {
      _mem.updateDrone(drone.toMap()..['id'] = drone.id);
      return 1;
    }
    final db = await database;
    return await db.update(
      'drones',
      drone.toMap(),
      where: 'id = ?',
      whereArgs: [drone.id],
    );
  }

  Future<int> deleteDrone(int id) async {
    if (kIsWeb) {
      _mem.deleteDrone(id);
      return 1;
    }
    final db = await database;
    await db.delete('alerts', where: 'droneId = ?', whereArgs: [id]);
    return await db.delete('drones', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getDroneCount() async {
    if (kIsWeb) return _mem.getDrones().length;
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM drones');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // --- Alert CRUD ---

  Future<int> insertAlert(DroneAlert alert) async {
    if (kIsWeb) return _mem.insertAlert(alert.toMap());
    final db = await database;
    return await db.insert('alerts', alert.toMap());
  }

  Future<List<DroneAlert>> getAlerts() async {
    if (kIsWeb) {
      return _mem.getAlerts().map((m) => DroneAlert.fromMap(m)).toList();
    }
    final db = await database;
    final maps = await db.query('alerts', orderBy: 'timestamp DESC');
    return maps.map((m) => DroneAlert.fromMap(m)).toList();
  }

  Future<List<DroneAlert>> getAlertsForDrone(int droneId) async {
    if (kIsWeb) {
      return _mem
          .getAlerts()
          .where((m) => m['droneId'] == droneId)
          .map((m) => DroneAlert.fromMap(m))
          .toList();
    }
    final db = await database;
    final maps = await db.query(
      'alerts',
      where: 'droneId = ?',
      whereArgs: [droneId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => DroneAlert.fromMap(m)).toList();
  }
}
