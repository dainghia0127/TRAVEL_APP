import 'package:flutter/material.dart';

/// Hệ thống Design System cao cấp dành riêng cho ứng dụng Outdoor / Survival
/// Lấy cảm hứng từ AllTrails Pro, Garmin Fenix và Apple Watch Ultra
class AppTheme {
  // Bảng màu Obsidian Forest (Rừng sương mù ban đêm)
  static const Color bgDark = Color(0xFF090D0B);        // Nền đen thẳm chống chói ban đêm & tiết kiệm 100% OLED
  static const Color surfaceBase = Color(0xFF111714);    // Card mặt kính mờ
  static const Color surfaceHigh = Color(0xFF19231E);    // Card nổi bật cấp 2
  static const Color surfaceGlass = Color(0x331E2D26);   // Hiệu ứng kính mờ (Frosted glass)
  static const Color borderLight = Color(0x1FFFFFFF);    // Viền mảnh tinh tế

  // Màu sắc Tactical & Outdoor High-Vis
  static const Color emerald = Color(0xFF10B981);       // Xanh ngọc lục bảo dã ngoại
  static const Color neonGreen = Color(0xFF00E676);     // Xanh neon hiển thị mốc quan trọng
  static const Color tacticalOrange = Color(0xFFF59E0B);// Cam dạ quang cảnh báo an toàn
  static const Color emergencyRed = Color(0xFFEF4444);  // Đỏ cứu hộ SOS quân đội
  static const Color alpineCyan = Color(0xFF06B6D4);    // Xanh ngọc hồ băng / nguồn nước

  // Typography Palette
  static const Color textMain = Color(0xFFF9FAFB);
  static const Color textSub = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradient cao cấp
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

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xE6090D0B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get outdoorDarkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: emerald,
      colorScheme: const ColorScheme.dark(
        primary: emerald,
        secondary: tacticalOrange,
        error: emergencyRed,
        surface: surfaceBase,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceBase,
        selectedItemColor: emerald,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
      ),
      cardTheme: CardThemeData(
        color: surfaceBase,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }
}
