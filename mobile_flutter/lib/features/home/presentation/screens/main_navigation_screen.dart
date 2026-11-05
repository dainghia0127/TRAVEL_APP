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

  /// Cho phép các màn hình con (như Chi tiết địa điểm, Lịch trình, v.v.)
  /// chuyển đổi tab một cách đồng bộ và tức thì.
  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(0);

  /// Cờ báo cho tab Bản đồ biết cần mở ngay chế độ Lộ trình A-B
  static bool openCustomRouteOnMap = false;

  static void switchToTab(int index) {
    activeTabNotifier.value = index;
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = MainNavigationScreen.activeTabNotifier.value;
    MainNavigationScreen.activeTabNotifier.addListener(_handleExternalTabChange);
  }

  @override
  void dispose() {
    MainNavigationScreen.activeTabNotifier.removeListener(_handleExternalTabChange);
    super.dispose();
  }

  void _handleExternalTabChange() {
    final newIndex = MainNavigationScreen.activeTabNotifier.value;
    if (_currentIndex != newIndex && mounted) {
      setState(() => _currentIndex = newIndex);
    }
  }

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

  bool get _isEditorialMode => _currentIndex == 0 || _currentIndex == 2 || _currentIndex == 3;

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      MainNavigationScreen.activeTabNotifier.value = index;
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditorial = _isEditorialMode;
    final navBg = isEditorial ? AppColors.editorialSurface : AppColors.surfaceBase;
    final navBorder = isEditorial ? AppColors.editorialBorder : AppColors.borderSubtle;
    final primaryActiveColor = isEditorial ? AppColors.editorialPine : AppColors.emerald;
    final unselectedColor = isEditorial ? AppColors.editorialMuted : AppColors.textMuted;

    return Scaffold(
      backgroundColor: isEditorial ? AppColors.editorialBg : AppColors.bgDark,
      // Smooth Material Motion Transition between Tabs
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            fillColor: isEditorial ? AppColors.editorialBg : AppColors.bgDark,
            child: child,
          );
        },
        child: _screens[_currentIndex],
      ),

      // Adaptive Two-Mode Navigation Bar
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: navBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isEditorial ? 0.05 : 0.6),
              blurRadius: 16,
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

              final activeColor = isEmergency ? AppColors.emergencyRed : primaryActiveColor;
              final inactiveColor = isEmergency ? Colors.red[400]! : unselectedColor;

              return Expanded(
                child: BouncingButton(
                  onTap: () => _onTabSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: AppRadius.roundedMd,
                      border: isSelected
                          ? Border.all(
                              color: activeColor.withValues(alpha: 0.35),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item['activeIcon'] as IconData : item['icon'] as IconData,
                          color: isSelected ? activeColor : inactiveColor,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
