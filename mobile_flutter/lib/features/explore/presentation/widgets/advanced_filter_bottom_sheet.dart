import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';

class FilterCriteria {
  final int? difficulty;
  final int? durationDays;
  final String? categoryId;

  const FilterCriteria({
    this.difficulty,
    this.durationDays,
    this.categoryId,
  });

  bool get isActive => difficulty != null || durationDays != null || (categoryId != null && categoryId != 'all');
}

class AdvancedFilterBottomSheet extends StatefulWidget {
  final FilterCriteria initialCriteria;
  final ValueChanged<FilterCriteria> onApply;

  const AdvancedFilterBottomSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  static Future<FilterCriteria?> show(BuildContext context, FilterCriteria current) {
    return showModalBottomSheet<FilterCriteria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.editorialSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AdvancedFilterBottomSheet(
        initialCriteria: current,
        onApply: (criteria) => Navigator.pop(ctx, criteria),
      ),
    );
  }

  @override
  State<AdvancedFilterBottomSheet> createState() => _AdvancedFilterBottomSheetState();
}

class _AdvancedFilterBottomSheetState extends State<AdvancedFilterBottomSheet> {
  late int? _selectedDifficulty;
  late int? _selectedDuration;
  late String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialCriteria.difficulty;
    _selectedDuration = widget.initialCriteria.durationDays;
    _selectedCategory = widget.initialCriteria.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ Lọc Khám Phá Nâng Cao',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.editorialInk),
              ),
              BouncingButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedDifficulty = null;
                    _selectedDuration = null;
                    _selectedCategory = 'all';
                  });
                },
                child: const Text(
                  'Đặt lại',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.editorialTerracotta),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Độ khó cung đường
          const Text(
            'Độ Khó Cung Đường',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('Tất cả', _selectedDifficulty == null, () => setState(() => _selectedDifficulty = null)),
              _buildFilterChip('Dễ (Cấp 1)', _selectedDifficulty == 1, () => setState(() => _selectedDifficulty = 1)),
              _buildFilterChip('Trung bình (Cấp 2)', _selectedDifficulty == 2, () => setState(() => _selectedDifficulty = 2)),
              _buildFilterChip('Thử thách (Cấp 3+)', _selectedDifficulty == 3, () => setState(() => _selectedDifficulty = 3)),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Thời lượng chuyến đi
          const Text(
            'Thời Lượng Chuyến Đi',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.editorialInk),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('Tất cả', _selectedDuration == null, () => setState(() => _selectedDuration = null)),
              _buildFilterChip('Trong ngày (1N)', _selectedDuration == 1, () => setState(() => _selectedDuration = 1)),
              _buildFilterChip('Cuối tuần (2-3N)', _selectedDuration == 2, () => setState(() => _selectedDuration = 2)),
              _buildFilterChip('Dài ngày (4N+)', _selectedDuration == 4, () => setState(() => _selectedDuration = 4)),
            ],
          ),
          const SizedBox(height: 24),

          // Nút áp dụng
          SizedBox(
            width: double.infinity,
            height: 48,
            child: BouncingButton(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onApply(FilterCriteria(
                  difficulty: _selectedDifficulty,
                  durationDays: _selectedDuration,
                  categoryId: _selectedCategory,
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.editorialPine,
                  borderRadius: AppRadius.roundedMd,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.editorialPine.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Áp Dụng Bộ Lọc',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return BouncingButton(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.editorialPine : AppColors.editorialSurface,
          borderRadius: AppRadius.roundedPill,
          border: Border.all(
            color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
            width: 1,
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
}

