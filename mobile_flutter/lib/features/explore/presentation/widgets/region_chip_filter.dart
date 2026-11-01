import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/features/explore/presentation/controllers/explore_controller.dart';

class RegionChipFilter extends StatelessWidget {
  final List<RegionItem> regions;
  final String selectedRegion;
  final ValueChanged<String> onSelectRegion;

  const RegionChipFilter({
    super.key,
    required this.regions,
    required this.selectedRegion,
    required this.onSelectRegion,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: regions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = regions[index];
          final isSelected = item.id == selectedRegion;

          return BouncingButton(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelectRegion(item.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.editorialPine : AppColors.editorialSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.editorialPine.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.editorialInk,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
