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
                color: AppColors.editorialSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.editorialBorder),
              ),
              child: const Icon(Icons.explore_off_outlined, size: 36, color: AppColors.editorialMuted),
            ),
            const SizedBox(height: AppSpacing.space16),
            const Text(
              'Không tìm thấy cung đường',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.editorialInk,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Không có địa điểm nào khớp với từ khóa hoặc bộ lọc độ khó bạn vừa chọn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.editorialMuted, height: 1.4),
            ),
            const SizedBox(height: AppSpacing.space20),
            BouncingButton(
              onTap: onReset,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.editorialPine,
                  borderRadius: AppRadius.roundedPill,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Đặt lại bộ lọc tìm kiếm',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
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
