import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drone.dart';
import '../providers/drone_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/battery_indicator.dart';
import '../widgets/status_badge.dart';
import '../widgets/telemetry_chip.dart';

class DroneDetailScreen extends StatelessWidget {
  const DroneDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final droneId = ModalRoute.of(context)!.settings.arguments as int;

    return Consumer<DroneProvider>(
      builder: (context, provider, _) {
        final drone = provider.drones.firstWhere(
          (d) => d.id == droneId,
          orElse: () => Drone(
            id: droneId,
            name: 'Unknown',
            droneType: 'Surveillance',
            batteryLevel: 0,
            signalStrength: 0,
            latitude: 0,
            longitude: 0,
            altitude: 0,
            status: 'Offline',
            missionStatus: 'Standby',
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final missionSteps = _buildMissionSteps(drone);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: AppColors.background,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.accent),
                    onPressed: () {
                      Navigator.pushNamed(context, '/drone/edit', arguments: drone.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.critical),
                    onPressed: () => _confirmDelete(context, provider, drone),
                  ),
                ],
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.5),
                        AppColors.background,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _iconForType(drone.droneType),
                      color: AppColors.accent.withOpacity(0.3),
                      size: 80,
                    ),
                  ),
                ),
                title: Text(
                  drone.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map + Battery Stack
                      Stack(
                        children: [
                          // Map placeholder background
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1B2A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.map,
                                    color: AppColors.primary,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'GPS: ${drone.latitude.toStringAsFixed(4)}, '
                                    '${drone.longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Battery overlay
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: BatteryIndicator(
                                batteryLevel: drone.batteryLevel,
                                radius: 40,
                                lineWidth: 6,
                              ),
                            ),
                          ),
                          // Status badge overlay
                          Positioned(
                            top: 12,
                            left: 12,
                            child: StatusBadge(status: drone.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Telemetry chips row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TelemetryChip(
                              icon: Icons.height,
                              label: 'Altitude',
                              value: '${drone.altitude.toStringAsFixed(1)}m',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TelemetryChip(
                              icon: Icons.location_on,
                              label: 'Latitude',
                              value: drone.latitude.toStringAsFixed(4),
                              iconColor: AppColors.batteryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TelemetryChip(
                              icon: Icons.location_on,
                              label: 'Longitude',
                              value: drone.longitude.toStringAsFixed(4),
                              iconColor: AppColors.batteryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TelemetryChip(
                              icon: Icons.signal_cellular_alt,
                              label: 'Signal',
                              value: '${drone.signalStrength}',
                              iconColor: drone.signalStrength > 60
                                  ? AppColors.batteryGreen
                                  : AppColors.batteryOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Mission info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flag, color: AppColors.accent, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Mission',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    drone.missionStatus,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.category,
                                    color: AppColors.textSecondary, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Type: ${drone.droneType}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Mission timeline
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mission Timeline',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.accent, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showMissionPicker(context, provider, drone),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: missionSteps.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final step = missionSteps[i];
                            final isActive = step['active'] as bool;
                            return Container(
                              width: 110,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary.withOpacity(0.3)
                                    : AppColors.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.accent
                                      : AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    step['icon'] as IconData,
                                    color: isActive
                                        ? AppColors.accent
                                        : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step['label'] as String,
                                    style: TextStyle(
                                      color: isActive
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMissionPicker(BuildContext context, DroneProvider provider, Drone drone) {
    final options = [
      {'label': 'Patrolling', 'icon': Icons.radar},
      {'label': 'Returning', 'icon': Icons.undo},
      {'label': 'Standby', 'icon': Icons.pause_circle},
      {'label': 'Charging', 'icon': Icons.battery_charging_full},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Mission Status',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((opt) {
              final isSelected = drone.missionStatus == opt['label'];
              return ListTile(
                leading: Icon(
                  opt['icon'] as IconData,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                ),
                title: Text(
                  opt['label'] as String,
                  style: TextStyle(
                    color: isSelected ? AppColors.accent : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () {
                  provider.updateDrone(
                    drone.copyWith(missionStatus: opt['label'] as String),
                  );
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildMissionSteps(Drone drone) {
    final all = [
      {'label': 'Launch', 'icon': Icons.rocket_launch, 'statuses': <String>['Patrolling', 'Returning', 'Standby', 'Charging']},
      {'label': 'Patrolling', 'icon': Icons.radar, 'statuses': <String>['Patrolling']},
      {'label': 'Returning', 'icon': Icons.undo, 'statuses': <String>['Returning']},
      {'label': 'Standby', 'icon': Icons.pause_circle, 'statuses': <String>['Standby']},
      {'label': 'Charging', 'icon': Icons.battery_charging_full, 'statuses': <String>['Charging']},
    ];
    return all.map((s) => {
      'label': s['label'],
      'icon': s['icon'],
      'active': (s['statuses'] as List<String>).contains(drone.missionStatus) &&
          s['label'] == drone.missionStatus,
    }).toList();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Cargo': return Icons.inventory_2;
      case 'Mapping': return Icons.map;
      case 'Rescue': return Icons.local_hospital;
      default: return Icons.videocam;
    }
  }

  void _confirmDelete(BuildContext context, DroneProvider provider, Drone drone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text('Delete Drone', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Remove "${drone.name}" from the fleet?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteDrone(drone.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.critical)),
          ),
        ],
      ),
    );
  }
}
