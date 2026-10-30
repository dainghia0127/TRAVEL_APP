import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/features/explore/presentation/screens/explore_screen.dart';
import 'package:mobile_flutter/features/offline_map/presentation/screens/offline_map_screen.dart';
import 'package:mobile_flutter/features/safety/presentation/screens/safety_sos_screen.dart';
import 'package:mobile_flutter/features/outdoor_skills/presentation/screens/outdoor_skills_screen.dart';
import 'package:mobile_flutter/features/trip_planner/presentation/screens/trip_planner_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ExploreScreen(),
    OfflineMapScreen(),
    TripPlannerScreen(),
    OutdoorSkillsScreen(),
    SafetySosScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {
      'label': 'Khám phá',
      'icon': Icons.explore_outlined,
      'activeIcon': Icons.explore,
    },
    {
      'label': 'Bản đồ',
      'icon': Icons.map_outlined,
      'activeIcon': Icons.map,
    },
    {
      'label': 'Lịch trình',
      'icon': Icons.route_outlined,
      'activeIcon': Icons.route,
    },
    {
      'label': 'Cẩm nang',
      'icon': Icons.menu_book_outlined,
      'activeIcon': Icons.menu_book,
    },
    {
      'label': 'SOS / An toàn',
      'icon': Icons.emergency_outlined,
      'activeIcon': Icons.emergency,
      'isEmergency': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceBase,
          border: const Border(
            top: BorderSide(color: AppTheme.borderLight, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;
              final isEmergency = item['isEmergency'] == true;

              return InkWell(
                onTap: () => setState(() => _currentIndex = index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isEmergency
                            ? AppTheme.emergencyRed.withValues(alpha: 0.15)
                            : AppTheme.emerald.withValues(alpha: 0.15))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: isEmergency
                                ? AppTheme.emergencyRed.withValues(alpha: 0.3)
                                : AppTheme.emerald.withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item['activeIcon'] as IconData : item['icon'] as IconData,
                        color: isSelected
                            ? (isEmergency ? AppTheme.emergencyRed : AppTheme.emerald)
                            : (isEmergency ? Colors.red[300] : AppTheme.textMuted),
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isEmergency ? AppTheme.emergencyRed : AppTheme.emerald)
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
