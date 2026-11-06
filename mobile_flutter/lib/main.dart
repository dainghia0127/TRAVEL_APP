import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
