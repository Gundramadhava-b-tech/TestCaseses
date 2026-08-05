import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    // Extract main severity string if it contains extra info like AHI
    String mainSeverity = severity;
    if (severity.contains('(')) {
      mainSeverity = severity.split('(')[0].trim();
    }

    final (bgColor, textColor, icon) = _getSeverityData(mainSeverity);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            severity,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _getSeverityData(String sev) {
    switch (sev) {
      case 'Normal':
        return (AppColors.normal.withValues(alpha: 0.1), AppColors.normal, Icons.check_circle_outline);
      case 'Mild':
        return (AppColors.mild.withValues(alpha: 0.1), AppColors.mild, Icons.info_outline);
      case 'Moderate':
        return (AppColors.moderate.withValues(alpha: 0.1), AppColors.moderate, Icons.warning_amber_rounded);
      case 'Severe':
        return (AppColors.severe.withValues(alpha: 0.1), AppColors.severe, Icons.error_outline);
      default:
        return (Colors.grey[200]!, Colors.grey[700]!, Icons.help_outline);
    }
  }
}
