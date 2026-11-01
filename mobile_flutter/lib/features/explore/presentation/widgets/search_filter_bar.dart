import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int? selectedDifficulty;
  final ValueChanged<int?> onSelectDifficulty;

  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.selectedDifficulty,
    required this.onSelectDifficulty,
  });

  void _showFilterModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.editorialSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.editorialBorder,
                        borderRadius: AppRadius.roundedPill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ Lọc Độ Khó & Địa Hình',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
                      ),
                      if (selectedDifficulty != null)
                        TextButton(
                          onPressed: () {
                            onSelectDifficulty(null);
                            setModalState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text('Đặt lại', style: TextStyle(color: AppColors.editorialPine, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Mức độ thách thức thể lực:', style: TextStyle(color: AppColors.editorialMuted, fontSize: 13)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildDifficultyChip(null, 'Tất cả', setModalState, context),
                      _buildDifficultyChip(1, 'Dễ (Dưới 15km)', setModalState, context),
                      _buildDifficultyChip(2, 'Vừa (15 - 35km)', setModalState, context),
                      _buildDifficultyChip(3, 'Khó (>35km)', setModalState, context),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDifficultyChip(int? level, String label, StateSetter setModalState, BuildContext context) {
    final isSelected = selectedDifficulty == level;
    return BouncingButton(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelectDifficulty(level);
        setModalState(() {});
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.editorialPine : AppColors.editorialSurfaceSubtle,
          borderRadius: AppRadius.roundedPill,
          border: Border.all(
            color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.editorialInk,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = selectedDifficulty != null;

    return Row(
      children: [
        // Search Input Field
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.editorialSurface,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: AppColors.editorialBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search, size: 20, color: AppColors.editorialPine),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(color: AppColors.editorialInk, fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm cung đường, đỉnh núi, thác nước...',
                      hintStyle: TextStyle(color: AppColors.editorialMuted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.editorialMuted),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Filter Button
        BouncingButton(
          onTap: () => _showFilterModal(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasFilter ? AppColors.editorialPine : AppColors.editorialSurface,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(
                color: hasFilter ? AppColors.editorialPine : AppColors.editorialBorder,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune,
                  size: 20,
                  color: hasFilter ? Colors.white : AppColors.editorialPine,
                ),
                if (hasFilter)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.editorialTerracotta,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
