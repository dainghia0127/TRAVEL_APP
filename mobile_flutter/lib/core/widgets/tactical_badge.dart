import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

class TacticalBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const TacticalBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor ?? AppColors.emerald),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.labelMetric.copyWith(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 9,
            color: AppColors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class TacticalPill extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const TacticalPill({
    super.key,
    this.icon,
    required this.text,
    this.color = AppColors.emerald,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? color.withValues(alpha: 0.15);
    final border = color.withValues(alpha: 0.3);

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.roundedPill,
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.captionBadge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

