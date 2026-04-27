import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/drone_provider.dart';
import '../models/drone.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Drone? _selectedDrone;

  Color _statusColor(String status) {
    switch (status) {
      case 'Active': return AppColors.accent;
      case 'Critical': return AppColors.critical;
      case 'Offline': return AppColors.offline;
      default: return AppColors.idle;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Cargo': return Icons.inventory_2;
      case 'Mapping': return Icons.map;
      case 'Rescue': return Icons.local_hospital;
      default: return Icons.videocam;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Map'),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<DroneProvider>(
            builder: (_, provider, __) => IconButton(
              icon: Icon(
                provider.isSimulationRunning
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: provider.isSimulationRunning
                    ? AppColors.accent
                    : AppColors.batteryGreen,
                size: 28,
              ),
              tooltip: provider.isSimulationRunning
                  ? 'Stop Simulation'
                  : 'Start Simulation',
              onPressed: () {
                if (provider.isSimulationRunning) {
                  provider.stopSimulation();
                } else {
                  provider.startSimulation();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<DroneProvider>(
        builder: (context, provider, _) {
          final drones = provider.drones;
          if (drones.isEmpty) {
            return const Center(
              child: Text('No drones', style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          // Center on first drone
          final center = LatLng(drones.first.latitude, drones.first.longitude);

          final markers = drones.map((drone) {
            final color = _statusColor(drone.status);
            final isSelected = _selectedDrone?.id == drone.id;
            return Marker(
              point: LatLng(drone.latitude, drone.longitude),
              width: isSelected ? 60 : 44,
              height: isSelected ? 60 : 44,
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedDrone = isSelected ? null : drone;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : color.withOpacity(0.4),
                      width: isSelected ? 3 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: isSelected ? 12 : 6,
                        spreadRadius: isSelected ? 3 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    _iconForType(drone.droneType),
                    color: Colors.white,
                    size: isSelected ? 28 : 20,
                  ),
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 15.0,
                  onTap: (_, __) => setState(() => _selectedDrone = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.drone_fleet_dashboard',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),

              // Legend
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _legendItem(AppColors.accent, 'Active'),
                      const SizedBox(height: 4),
                      _legendItem(AppColors.critical, 'Critical'),
                      const SizedBox(height: 4),
                      _legendItem(AppColors.idle, 'Idle'),
                      const SizedBox(height: 4),
                      _legendItem(AppColors.offline, 'Offline'),
                    ],
                  ),
                ),
              ),

              // Simulation status badge
              Positioned(
                top: 12,
                right: 12,
                child: Consumer<DroneProvider>(
                  builder: (_, provider, __) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: provider.isSimulationRunning
                            ? AppColors.accent
                            : AppColors.idle,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: provider.isSimulationRunning
                                ? AppColors.accent
                                : AppColors.idle,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          provider.isSimulationRunning
                              ? 'LIVE'
                              : 'PAUSED',
                          style: TextStyle(
                            color: provider.isSimulationRunning
                                ? AppColors.accent
                                : AppColors.idle,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Selected drone info card
              if (_selectedDrone != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Builder(
                    builder: (_) {
                      final d = provider.drones.firstWhere(
                        (x) => x.id == _selectedDrone!.id,
                        orElse: () => _selectedDrone!,
                      );
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _statusColor(d.status).withOpacity(0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(_iconForType(d.droneType),
                                    color: AppColors.accent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  d.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(d.status)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: _statusColor(d.status)),
                                  ),
                                  child: Text(
                                    d.status,
                                    style: TextStyle(
                                        color: _statusColor(d.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/drone/detail',
                                      arguments: d.id),
                                  child: const Icon(Icons.open_in_new,
                                      color: AppColors.accent, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoChip(Icons.battery_charging_full,
                                    '${d.batteryLevel.toStringAsFixed(0)}%'),
                                _infoChip(Icons.height,
                                    '${d.altitude.toStringAsFixed(0)}m'),
                                _infoChip(Icons.signal_cellular_alt,
                                    '${d.signalStrength}'),
                                _infoChip(Icons.flag, d.missionStatus),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'GPS: ${d.latitude.toStringAsFixed(5)}, ${d.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // Center-on-fleet button
              Positioned(
                bottom: _selectedDrone != null ? 200 : 16,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: 'center',
                  backgroundColor: AppColors.cardColor,
                  onPressed: () {
                    if (drones.isNotEmpty) {
                      _mapController.move(
                        LatLng(drones.first.latitude, drones.first.longitude),
                        15,
                      );
                    }
                  },
                  child: const Icon(Icons.my_location,
                      color: AppColors.accent, size: 18),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _infoChip(IconData icon, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accent, size: 14),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
