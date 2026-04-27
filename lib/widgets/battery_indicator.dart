import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel;
  final double radius;
  final double lineWidth;

  const BatteryIndicator({
    super.key,
    required this.batteryLevel,
    this.radius = 60.0,
    this.lineWidth = 8.0,
  });

  Color _batteryColor(double level) {
    if (level > 50) return AppColors.batteryGreen;
    if (level > 20) return AppColors.batteryOrange;
    return AppColors.critical;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (batteryLevel / 100).clamp(0.0, 1.0);
    final color = _batteryColor(batteryLevel);

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${batteryLevel.toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontSize: radius * 0.35,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.battery_charging_full, color: color, size: radius * 0.25),
        ],
      ),
      progressColor: color,
      backgroundColor: AppColors.cardColor,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 500,
    );
  }
}
