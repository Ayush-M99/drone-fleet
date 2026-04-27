import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drone_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/drone_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DroneProvider>(
        builder: (context, provider, _) {
          final drones = provider.drones;
          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.cardColor,
            onRefresh: () => provider.loadDrones(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 140,
                  floating: true,
                  snap: true,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  title: const Text(
                    'Drone Fleet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  actions: [
                    Consumer<DroneProvider>(
                      builder: (_, p, __) => IconButton(
                        icon: Icon(
                          p.isSimulationRunning
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: p.isSimulationRunning
                              ? AppColors.accent
                              : AppColors.batteryGreen,
                          size: 28,
                        ),
                        tooltip: p.isSimulationRunning
                            ? 'Stop Simulation'
                            : 'Start Simulation',
                        onPressed: () => p.isSimulationRunning
                            ? p.stopSimulation()
                            : p.startSimulation(),
                      ),
                    ),
                  ],
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.4),
                          AppColors.background,
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flight, color: AppColors.accent, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              '${drones.length} Drones · '
                              '${drones.where((d) => d.status == "Active").length} Active · '
                              '${drones.where((d) => d.status == "Critical").length} Critical',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (drones.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flight_land, color: AppColors.textSecondary, size: 60),
                          SizedBox(height: 16),
                          Text(
                            'No drones in fleet.\nTap + to add one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => DroneCard(drone: drones[index]),
                        childCount: drones.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/drone/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
