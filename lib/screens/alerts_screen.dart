import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert.dart';
import '../providers/drone_provider.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'LOW_BATTERY': return Icons.battery_alert;
      case 'SIGNAL_LOST': return Icons.signal_wifi_off;
      case 'MISSION_DONE': return Icons.check_circle;
      default: return Icons.warning;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'LOW_BATTERY': return AppColors.batteryOrange;
      case 'SIGNAL_LOST': return AppColors.critical;
      case 'MISSION_DONE': return AppColors.batteryGreen;
      default: return AppColors.textSecondary;
    }
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<DroneProvider>(
            builder: (_, provider, __) => Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.critical.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.critical),
                  ),
                  child: Text(
                    '${provider.alerts.length}',
                    style: const TextStyle(
                      color: AppColors.critical,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<DroneProvider>(
        builder: (context, provider, _) {
          final alerts = provider.alerts;
          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.batteryGreen, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'No alerts — all drones nominal',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final color = _colorForType(alert.alertType);
              final droneName = provider.getDroneName(alert.droneId);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconForType(alert.alertType), color: color, size: 22),
                  ),
                  title: Text(
                    alert.message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.flight, color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        droneName,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(alert.timestamp),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alert.alertType.replaceAll('_', ' '),
                      style: TextStyle(color: color, fontSize: 10),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
