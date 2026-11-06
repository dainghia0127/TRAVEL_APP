import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Button wrapper mang lại phản hồi xúc giác (Haptic) và hiệu ứng nảy (Spring scale)
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleLower;
  final Duration duration;

  const BouncingButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleLower = 0.96,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleLower,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerTap() {
    if (widget.onTap == null) return;
    _controller.forward().then((_) {
      if (mounted) _controller.reverse();
    });
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _triggerTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

