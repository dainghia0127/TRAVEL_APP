import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Kích hoạt cây Semantics trên Web để Safari iOS (đặc biệt là PWA Standalone)
    // ánh xạ chính xác các nút bấm thành các Clickable Elements có thể chạm được!
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const TravelOutdoorApp());
}

class TravelOutdoorApp extends StatelessWidget {
  const TravelOutdoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRAVEL_APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.outdoorDarkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
