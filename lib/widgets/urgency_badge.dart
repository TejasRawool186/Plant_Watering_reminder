import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/plant.dart';

class UrgencyBadge extends StatelessWidget {
  final Plant plant;
  final bool compact;

  const UrgencyBadge({
    super.key,
    required this.plant,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final String label;
    final IconData icon;

    if (plant.isOverdue) {
      bgColor = AppTheme.overdueColor.withValues(alpha: 0.12);
      textColor = AppTheme.overdueColor;
      label = compact ? '${plant.daysOverdue}d late' : '${plant.daysOverdue} days overdue';
      icon = Icons.warning_rounded;
    } else if (plant.isDueToday) {
      bgColor = AppTheme.dueTodayColor.withValues(alpha: 0.12);
      textColor = AppTheme.dueTodayColor;
      label = 'Due today';
      icon = Icons.schedule_rounded;
    } else {
      bgColor = AppTheme.upcomingColor.withValues(alpha: 0.12);
      textColor = AppTheme.upcomingColor;
      final days = plant.daysUntilWatering;
      label = compact
          ? '${days}d left'
          : days == 1
              ? 'Tomorrow'
              : 'In $days days';
      icon = Icons.eco_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
