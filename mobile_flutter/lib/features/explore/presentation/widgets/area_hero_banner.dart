import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

/// Banner tạp chí giới thiệu khu vực (Trong nước hoặc Quốc tế)
class AreaHeroBanner extends StatelessWidget {
  final bool isDomestic;
  final int totalCount;
  final VoidCallback? onExploreTap;

  const AreaHeroBanner({
    super.key,
    required this.isDomestic,
    required this.totalCount,
    this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = isDomestic ? 'Việt Nam • Dải Đất Gấm Hoa' : 'Kỳ Quan Thế Giới • 6 Châu Lục';
    final subtitle = isDomestic
        ? 'Khám phá các di sản thế giới UNESCO, những cung đèo ngoạn mục và biển đảo nguyên sơ từ Hà Giang đến Côn Đảo.'
        : 'Thám hiểm những nóc nhà vĩ đại, kỳ quan thiên nhiên kỳ vĩ và những cung đường dã ngoại huyền thoại trên địa cầu.';
    final badgeText = isDomestic ? '$totalCount Địa Điểm Tuyển Chọn' : '$totalCount Kỳ Quan Toàn Cầu';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDomestic
              ? [const Color(0xFF1E3A2B), const Color(0xFF14241B)] // Forest Pine
              : [const Color(0xFF1E293B), const Color(0xFF0F172A)], // Alpine Slate
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic elements
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              isDomestic ? Icons.terrain_rounded : Icons.public_rounded,
              size: 160,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: AppRadius.roundedPill,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDomestic ? Icons.verified : Icons.travel_explore,
                            color: isDomestic ? const Color(0xFF68D391) : const Color(0xFF63B3ED),
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: 16),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

