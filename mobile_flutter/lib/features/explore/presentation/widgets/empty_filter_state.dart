import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';

class EmptyFilterState extends StatelessWidget {
  final VoidCallback onReset;

  const EmptyFilterState({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space32, vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(Icons.explore_off_outlined, size: 36, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Không tìm thấy địa điểm',
              style: AppTypography.headlineMedium.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              'Không có cung đường nào khớp với từ khóa hoặc bộ lọc độ khó bạn đã chọn.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.space20),
            BouncingButton(
              onTap: onReset,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: AppRadius.roundedPill,
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 16, color: AppColors.emerald),
                    const SizedBox(width: 6),
                    Text(
                      'Đặt lại bộ lọc tìm kiếm',
                      style: AppTypography.captionBadge.copyWith(color: AppColors.emerald),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

