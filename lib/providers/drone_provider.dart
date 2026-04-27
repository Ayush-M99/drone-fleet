import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/drone.dart';
import '../models/alert.dart';
import '../database/database_helper.dart';

class DroneProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Random _random = Random();

  List<Drone> drones = [];
  List<DroneAlert> alerts = [];
  List<double> altitudeHistory = [];
  Timer? _timer;
  bool isSimulationRunning = false;

  Future<void> init() async {
    await _seedIfEmpty();
    await loadDrones();
    await loadAlerts();
    startSimulation();
  }

  Future<void> _seedIfEmpty() async {
    final count = await _db.getDroneCount();
    if (count > 0) return;

    final now = DateTime.now().toIso8601String();
    final seedDrones = [
      Drone(
        name: 'Alpha-01',
        droneType: 'Surveillance',
        batteryLevel: 85.0,
        signalStrength: 80,
        latitude: 12.9716,
        longitude: 77.5946,
        altitude: 85.0,
        status: 'Active',
        missionStatus: 'Patrolling',
        createdAt: now,
      ),
      Drone(
        name: 'Beta-02',
        droneType: 'Cargo',
        batteryLevel: 62.0,
        signalStrength: 65,
        latitude: 12.9720,
        longitude: 77.5950,
        altitude: 60.0,
        status: 'Active',
        missionStatus: 'Returning',
        createdAt: now,
      ),
      Drone(
        name: 'Gamma-03',
        droneType: 'Mapping',
        batteryLevel: 23.0,
        signalStrength: 45,
        latitude: 12.9730,
        longitude: 77.5960,
        altitude: 40.0,
        status: 'Critical',
        missionStatus: 'Standby',
        createdAt: now,
        alertFired: true,
      ),
      Drone(
        name: 'Delta-04',
        droneType: 'Rescue',
        batteryLevel: 91.0,
        signalStrength: 90,
        latitude: 12.9700,
        longitude: 77.5930,
        altitude: 20.0,
        status: 'Idle',
        missionStatus: 'Charging',
        createdAt: now,
      ),
      Drone(
        name: 'Echo-05',
        droneType: 'Surveillance',
        batteryLevel: 45.0,
        signalStrength: 70,
        latitude: 12.9710,
        longitude: 77.5940,
        altitude: 75.0,
        status: 'Active',
        missionStatus: 'Patrolling',
        createdAt: now,
      ),
    ];

    for (final drone in seedDrones) {
      await _db.insertDrone(drone);
    }
  }

  Future<void> loadDrones() async {
    drones = await _db.getDrones();
    // Mark Gamma-03 alert as already fired (battery was seeded at 23%)
    for (final d in drones) {
      if (d.batteryLevel < 20) d.alertFired = true;
    }
    notifyListeners();
  }

  Future<void> loadAlerts() async {
    alerts = await _db.getAlerts();
    notifyListeners();
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
    isSimulationRunning = false;
    notifyListeners();
  }

  void startSimulation() {
    _timer?.cancel();
    isSimulationRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      for (final d in drones) {
        await _tick(d);
      }
      // Track altitude history of first active drone
      final activeDrone = drones.firstWhere(
        (d) => d.status == 'Active',
        orElse: () => drones.first,
      );
      altitudeHistory.add(activeDrone.altitude);
      if (altitudeHistory.length > 10) altitudeHistory.removeAt(0);
      notifyListeners();
    });
  }

  Future<void> _tick(Drone d) async {
    // Charge when Charging, otherwise drain 0.3–0.8% per tick
    if (d.missionStatus == 'Charging') {
      final charge = 0.5 + _random.nextDouble() * 0.5;
      d.batteryLevel = (d.batteryLevel + charge).clamp(0.0, 100.0);
      // Reset alert flag so it can fire again if battery drops later
      if (d.batteryLevel >= 20.0) d.alertFired = false;
    } else {
      final drain = 0.3 + _random.nextDouble() * 0.5;
      d.batteryLevel = (d.batteryLevel - drain).clamp(0.0, 100.0);
    }

    // GPS drift ±0.0001 degrees
    d.latitude += (_random.nextDouble() - 0.5) * 0.0002;
    d.longitude += (_random.nextDouble() - 0.5) * 0.0002;

    // Altitude ±2m clamped 10–150
    d.altitude = (d.altitude + (_random.nextDouble() - 0.5) * 4).clamp(10.0, 150.0);

    // Signal ±3 clamped 20–100
    d.signalStrength = (d.signalStrength + (_random.nextInt(7) - 3)).clamp(20, 100);

    // Status transitions
    if (d.missionStatus == 'Charging' && d.batteryLevel >= 20.0) {
      d.status = 'Active';
    } else if (d.batteryLevel < 5.0) {
      d.status = 'Offline';
    } else if (d.batteryLevel < 20.0) {
      d.status = 'Critical';
      // Fire LOW_BATTERY alert only once per threshold crossing
      if (!d.alertFired) {
        d.alertFired = true;
        final alert = DroneAlert(
          droneId: d.id!,
          alertType: 'LOW_BATTERY',
          message: '${d.name} battery critically low: ${d.batteryLevel.toStringAsFixed(1)}%',
          timestamp: DateTime.now().toIso8601String(),
        );
        await _db.insertAlert(alert);
        alerts.insert(0, alert);
      }
    }

    // Persist updated telemetry
    await _db.updateDrone(d);
  }

  Future<void> addDrone(Drone drone) async {
    final id = await _db.insertDrone(drone);
    drones.add(drone.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateDrone(Drone drone) async {
    await _db.updateDrone(drone);
    final idx = drones.indexWhere((d) => d.id == drone.id);
    if (idx != -1) drones[idx] = drone;
    notifyListeners();
  }

  Future<void> deleteDrone(int id) async {
    await _db.deleteDrone(id);
    drones.removeWhere((d) => d.id == id);
    alerts.removeWhere((a) => a.droneId == id);
    notifyListeners();
  }

  String getDroneName(int droneId) {
    final drone = drones.firstWhere((d) => d.id == droneId, orElse: () => drones.first);
    return drone.name;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
