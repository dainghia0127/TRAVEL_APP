import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

class SkeletonShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.roundedMd,
  });

  @override
  Widget build(BuildContext context) {
    final base = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.editorialBorder.withValues(alpha: 0.5),
        borderRadius: borderRadius,
      ),
    );

    // Không kích hoạt timer vô hạn trong automated widget test để tránh pending timer invariant
    final isTesting = WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding') ||
        WidgetsBinding.instance.runtimeType.toString().contains('AutomatedTestWidgetsFlutterBinding');

    if (isTesting) {
      return base;
    }

    return base
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.2),
        );
  }
}
