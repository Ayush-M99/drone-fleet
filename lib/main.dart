import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/drone_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/drone_detail_screen.dart';
import 'screens/add_edit_drone_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/map_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = DroneProvider();
  await provider.init();
  runApp(
    ChangeNotifierProvider<DroneProvider>.value(
      value: provider,
      child: const DroneFleetApp(),
    ),
  );
}

class DroneFleetApp extends StatelessWidget {
  const DroneFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Fleet Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/drone/edit': (context) => const AddEditDroneScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) => const MainNavigation(),
            );
          case '/drone/detail':
            return MaterialPageRoute(
              builder: (_) => const DroneDetailScreen(),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardScreen(),
    MapScreen(),
    AlertsScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Consumer<DroneProvider>(
        builder: (context, provider, _) {
          final alertCount = provider.alerts.length;
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Fleet',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (alertCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.critical,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Alerts',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Analytics',
              ),
            ],
          );
        },
      ),
    );
  }
}
