import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drone_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<DroneProvider>(
        builder: (context, provider, _) {
          final drones = provider.drones;
          if (drones.isEmpty) {
            return const Center(
              child: Text('No data yet', style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          final total = drones.length;
          final active = drones.where((d) => d.status == 'Active').length;
          final critical = drones.where((d) => d.status == 'Critical').length;
          final avgBattery = drones.isEmpty
              ? 0.0
              : drones.fold(0.0, (sum, d) => sum + d.batteryLevel) / drones.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards
              Row(
                children: [
                  _summaryCard('Total', '$total', Icons.flight, AppColors.primary),
                  const SizedBox(width: 10),
                  _summaryCard('Active', '$active', Icons.check_circle, AppColors.accent),
                  const SizedBox(width: 10),
                  _summaryCard('Critical', '$critical', Icons.warning, AppColors.critical),
                  const SizedBox(width: 10),
                  _summaryCard('Avg Batt', '${avgBattery.toStringAsFixed(0)}%',
                      Icons.battery_charging_full, AppColors.batteryOrange),
                ],
              ),
              const SizedBox(height: 24),

              // Battery Bar Chart
              _sectionTitle('Battery Levels'),
              const SizedBox(height: 12),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.cardColor,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${drones[groupIndex].name}\n${rod.toY.toStringAsFixed(0)}%',
                            const TextStyle(color: AppColors.textPrimary, fontSize: 11),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 25,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          reservedSize: 36,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= drones.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                drones[idx].name.split('-').first,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: Color(0x1AFFFFFF),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(drones.length, (i) {
                      final d = drones[i];
                      final color = d.batteryLevel > 50
                          ? AppColors.batteryGreen
                          : d.batteryLevel > 20
                              ? AppColors.batteryOrange
                              : AppColors.critical;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: d.batteryLevel,
                            color: color,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 100,
                              color: AppColors.background,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Altitude Line Chart
              _sectionTitle('Altitude History (Lead Drone)'),
              const SizedBox(height: 12),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: _buildLineChart(provider.altitudeHistory),
              ),
              const SizedBox(height: 24),

              // Drone type distribution
              _sectionTitle('Fleet Composition'),
              const SizedBox(height: 12),
              ...['Surveillance', 'Cargo', 'Mapping', 'Rescue'].map((type) {
                final count = drones.where((d) => d.droneType == type).length;
                final fraction = total > 0 ? count / total : 0.0;
                return _typeRow(type, count, fraction);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLineChart(List<double> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Accumulating data...',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    final spots = List.generate(
      history.length,
      (i) => FlSpot(i.toDouble(), history[i]),
    );
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 160,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.cardColor,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toStringAsFixed(1)}m',
                      const TextStyle(color: AppColors.accent, fontSize: 11),
                    ))
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 40,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}m',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
              reservedSize: 36,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0x1AFFFFFF),
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accent,
            barWidth: 2.5,
            dotData: FlDotData(
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.accent,
                strokeWidth: 0,
                strokeColor: Colors.transparent,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _typeRow(String type, int count, double fraction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(type, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              Text('$count', style: const TextStyle(color: AppColors.accent, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.cardColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
