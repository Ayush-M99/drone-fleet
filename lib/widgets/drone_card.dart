import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drone.dart';
import '../providers/drone_provider.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class DroneCard extends StatelessWidget {
  final Drone drone;

  const DroneCard({super.key, required this.drone});

  IconData _iconForType(String type) {
    switch (type) {
      case 'Cargo':
        return Icons.inventory_2;
      case 'Mapping':
        return Icons.map;
      case 'Rescue':
        return Icons.local_hospital;
      default:
        return Icons.videocam;
    }
  }

  Color _batteryColor(double level) {
    if (level > 50) return AppColors.batteryGreen;
    if (level > 20) return AppColors.batteryOrange;
    return AppColors.critical;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (context, provider, _) {
        final d = provider.drones.firstWhere(
          (x) => x.id == drone.id,
          orElse: () => drone,
        );
        final batteryColor = _batteryColor(d.batteryLevel);

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/drone/detail', arguments: d.id);
          },
          child: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: d.status == 'Critical'
                    ? AppColors.critical.withOpacity(0.6)
                    : AppColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Drone icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconForType(d.droneType),
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                  // Name
                  Text(
                    d.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Type
                  Text(
                    d.droneType,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  // Status
                  StatusBadge(status: d.status),
                  // Battery bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.battery_charging_full,
                              color: AppColors.textSecondary, size: 14),
                          Text(
                            '${d.batteryLevel.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: batteryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: d.batteryLevel / 100,
                          backgroundColor: AppColors.background,
                          valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                  // Signal row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        d.signalStrength > 60
                            ? Icons.signal_wifi_4_bar
                            : d.signalStrength > 30
                                ? Icons.network_wifi_3_bar
                                : Icons.signal_wifi_bad,
                        color: d.signalStrength > 60
                            ? AppColors.batteryGreen
                            : d.signalStrength > 30
                                ? AppColors.batteryOrange
                                : AppColors.critical,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${d.signalStrength}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
