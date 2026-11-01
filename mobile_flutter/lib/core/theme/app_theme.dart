import 'package:flutter/material.dart';

/// Design Tokens chuẩn mực cho hệ thống Outdoor Travel Experience
/// Lấy cảm hứng từ AllTrails Pro, Airbnb và Apple Watch Ultra
class AppColors {
  // Tầng Nền & Bề mặt (60%)
  static const Color bgDark = Color(0xFF090D0B);          // Nền đen thẳm chống chói, tiết kiệm 100% pin OLED
  static const Color surfaceBase = Color(0xFF121915);      // Thẻ mặt phẳng cấp 1
  static const Color surfaceHigh = Color(0xFF1A241F);      // Thẻ nổi bật / Header cấp 2
  static const Color surfaceElevated = Color(0xFF222F29);  // Dialog / Floating Sheets
  static const Color surfaceGlass = Color(0x331E2D26);     // Kính mờ (Frosted glass)

  // Phân hệ Modern Outdoor Editorial (Khám phá, Chi tiết & Lịch trình)
  static const Color editorialBg = Color(0xFFEFECE4);           // Nền giấy mộc dã ngoại ấm áp, tương phản rõ nét với khung
  static const Color editorialSurface = Color(0xFFFFFFFF);      // Thẻ trắng tinh khôi nổi bật trên nền giấy
  static const Color editorialSurfaceSubtle = Color(0xFFE5E0D5);// Khung thông tin phụ / chip / search bar
  static const Color editorialSurfaceAlt = Color(0xFFFAF7F0);   // Nền thẻ biến thể ấm cúng
  static const Color editorialInk = Color(0xFF17221B);          // Chữ mực rừng sâu, độ tương phản cao
  static const Color editorialMuted = Color(0xFF5A685F);        // Chữ phụ, mô tả, chú thích
  static const Color editorialBorder = Color(0xFFD5CEC0);       // Viền rõ nét, định hình khung phân cách
  static const Color editorialBorderSubtle = Color(0xFFE2DDD2); // Viền mảnh ngăn chia nội bộ
  static const Color editorialPine = Color(0xFF1E3A2B);         // Xanh lá thông dã ngoại (primary)
  static const Color editorialTerracotta = Color(0xFFC26D38);   // Đất nung / Cam ấm hoàng hôn

  // Đường viền (Borders)
  static const Color borderSubtle = Color(0x14FFFFFF);     // Viền mờ 8%
  static const Color borderMedium = Color(0x24FFFFFF);     // Viền rõ 14%
  static const Color borderActive = Color(0xFF10B981);     // Viền khi được chọn

  // Điểm nhấn sinh tồn & Dã ngoại (10%)
  static const Color emerald = Color(0xFF10B981);         // Xanh ngọc lục bảo dã ngoại
  static const Color emeraldDark = Color(0xFF059669);     // Nút hành động, gradient
  static const Color neonGreen = Color(0xFF00E676);       // Xanh neon hiển thị mốc quan trọng
  static const Color tacticalOrange = Color(0xFFF59E0B);  // Cam dạ quang cảnh báo an toàn
  static const Color emergencyRed = Color(0xFFEF4444);    // Đỏ cứu hộ SOS quân đội
  static const Color alpineCyan = Color(0xFF06B6D4);      // Xanh ngọc hồ băng / nguồn nước
  static const Color summitGold = Color(0xFFFBBF24);      // Đánh giá 5 sao, mốc thành tích

  // Văn bản & Tương phản (30%)
  static const Color textPrimary = Color(0xFFF9FAFB);     // Tiêu đề chính, số liệu lớn
  static const Color textSecondary = Color(0xFF9CA3AF);   // Phụ đề, mô tả
  static const Color textMuted = Color(0xFF6B7280);       // Chú thích, đơn vị đo

  // Gradients
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sosGradient = LinearGradient(
    colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient imageOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x33090D0B),
      Color(0xCC090D0B),
      Color(0xF5090D0B),
    ],
    stops: [0.0, 0.4, 0.75, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [
      Color(0x20000000),
      Colors.transparent,
      Color(0x80090D0B),
      Color(0xF5090D0B),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppSpacing {
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  static const double pill = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(pill));
}

class AppTypography {
  static const TextStyle displayHero = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelMetric = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle captionBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // Phân hệ Editorial Typography
  static const TextStyle editorialHero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.editorialInk,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static const TextStyle editorialHeadline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.editorialInk,
    letterSpacing: -0.4,
  );

  static const TextStyle editorialSubhead = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.editorialPine,
    letterSpacing: 0.1,
  );

  static const TextStyle editorialBody = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.editorialInk,
    height: 1.5,
  );

  static const TextStyle editorialCaption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.editorialMuted,
    letterSpacing: 0.2,
  );
}

/// Giữ tính tương thích ngược hoàn hảo với các màn hình hiện hữu
class AppTheme {
  // Alias backward compatibility
  static const Color bgDark = AppColors.bgDark;
  static const Color surfaceBase = AppColors.surfaceBase;
  static const Color surfaceHigh = AppColors.surfaceHigh;
  static const Color surfaceGlass = AppColors.surfaceGlass;
  static const Color borderLight = AppColors.borderSubtle;
  static const Color emerald = AppColors.emerald;
  static const Color neonGreen = AppColors.neonGreen;
  static const Color tacticalOrange = AppColors.tacticalOrange;
  static const Color emergencyRed = AppColors.emergencyRed;
  static const Color alpineCyan = AppColors.alpineCyan;
  static const Color textMain = AppColors.textPrimary;
  static const Color textSub = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;

  static const LinearGradient emeraldGradient = AppColors.emeraldGradient;
  static const LinearGradient amberGradient = AppColors.amberGradient;
  static const LinearGradient sosGradient = AppColors.sosGradient;
  static const LinearGradient cardOverlayGradient = AppColors.imageOverlayGradient;

  static ThemeData get outdoorDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.emerald,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emerald,
        secondary: AppColors.tacticalOrange,
        error: AppColors.emergencyRed,
        surface: AppColors.surfaceBase,
        surfaceContainerHighest: AppColors.surfaceHigh,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineLarge,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedLg,
          side: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceBase,
        selectedItemColor: AppColors.emerald,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
      ),
    );
  }
}
