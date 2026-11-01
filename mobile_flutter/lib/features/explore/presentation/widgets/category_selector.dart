import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';

class CategoryItem {
  final String title;
  final IconData icon;

  const CategoryItem({required this.title, required this.icon});
}

class CategorySelector extends StatelessWidget {
  final List<CategoryItem> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.title == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BouncingButton(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelectCategory(cat.title);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.editorialPine : AppColors.editorialSurface,
                  borderRadius: AppRadius.roundedPill,
                  border: Border.all(
                    color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 15,
                      color: isSelected ? Colors.white : AppColors.editorialPine,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.editorialInk,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
