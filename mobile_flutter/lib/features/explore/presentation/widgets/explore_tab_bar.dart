import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';

class ExploreTabBar extends StatelessWidget {
  final bool isDomestic;
  final ValueChanged<bool> onTabChanged;

  const ExploreTabBar({
    super.key,
    required this.isDomestic,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.editorialSurfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.editorialBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: 'TRONG NƯỚC',
              subtitle: 'Việt Nam',
              icon: Icons.flag_outlined,
              isSelected: isDomestic,
              onTap: () {
                if (!isDomestic) {
                  HapticFeedback.selectionClick();
                  onTabChanged(true);
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabItem(
              title: 'QUỐC TẾ',
              subtitle: 'Thế Giới',
              icon: Icons.public,
              isSelected: !isDomestic,
              onTap: () {
                if (isDomestic) {
                  HapticFeedback.selectionClick();
                  onTabChanged(false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return BouncingButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.editorialSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.editorialPine, width: 1.2)
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.editorialPine : AppColors.editorialMuted,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.editorialInk : AppColors.editorialMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.editorialPine : AppColors.editorialMuted.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

