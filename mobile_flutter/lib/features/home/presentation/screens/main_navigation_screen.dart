import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
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
      'label': 'SOS Cứu hộ',
      'icon': Icons.emergency_outlined,
      'activeIcon': Icons.emergency,
      'isEmergency': true,
    },
  ];

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      // Smooth Material Motion Transition between Tabs
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            fillColor: AppColors.bgDark,
            child: child,
          );
        },
        child: _screens[_currentIndex],
      ),

      // Premium Frosted Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceBase,
          border: const Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;
              final isEmergency = item['isEmergency'] == true;

              return Expanded(
                child: BouncingButton(
                  onTap: () => _onTabSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isEmergency
                              ? AppColors.emergencyRed.withValues(alpha: 0.15)
                              : AppColors.emerald.withValues(alpha: 0.15))
                          : Colors.transparent,
                      borderRadius: AppRadius.roundedMd,
                      border: isSelected
                          ? Border.all(
                              color: isEmergency
                                  ? AppColors.emergencyRed.withValues(alpha: 0.4)
                                  : AppColors.emerald.withValues(alpha: 0.4),
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
                              ? (isEmergency ? AppColors.emergencyRed : AppColors.emerald)
                              : (isEmergency ? Colors.red[300] : AppColors.textMuted),
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected
                                ? (isEmergency ? AppColors.emergencyRed : AppColors.emerald)
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
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
