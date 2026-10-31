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
      backgroundColor: AppColors.surfaceElevated,
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
                        color: Colors.white24,
                        borderRadius: AppRadius.roundedPill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bộ Lọc Địa Hình & Độ Khó',
                        style: AppTypography.headlineMedium.copyWith(fontSize: 18),
                      ),
                      if (selectedDifficulty != null)
                        TextButton(
                          onPressed: () {
                            onSelectDifficulty(null);
                            setModalState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text('Đặt lại', style: TextStyle(color: AppColors.emerald)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Mức độ thách thức thể lực:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildDifficultyChip(null, 'Tất cả', setModalState, context),
                      _buildDifficultyChip(1, 'Dễ (Dưới 15km)', setModalState, context),
                      _buildDifficultyChip(2, 'Vừa (15 - 35km)', setModalState, context),
                      _buildDifficultyChip(3, 'Khó / Thách thức (>35km)', setModalState, context),
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.emerald,
      backgroundColor: AppColors.surfaceHigh,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.roundedPill,
        side: BorderSide(
          color: isSelected ? AppColors.emerald : AppColors.borderSubtle,
        ),
      ),
      onSelected: (_) {
        onSelectDifficulty(level);
        setModalState(() {});
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = selectedDifficulty != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Tìm đỉnh núi, đại thác, bãi cắm trại, đèo...',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.emerald, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                  onPressed: onClear,
                ),
              BouncingButton(
                onTap: () => _showFilterModal(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: hasFilter ? AppColors.emerald : AppColors.surfaceHigh,
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Icon(
                    Icons.tune,
                    color: hasFilter ? Colors.black : AppColors.textSecondary,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

