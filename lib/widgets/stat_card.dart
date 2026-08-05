import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final Color iconColor;
  final String label;
  final String value;
  final IconData icon;
  final String trendText;
  final bool isTrendPositive;

  const StatCard({
    super.key,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.icon,
    required this.trendText,
    this.isTrendPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.borderGray.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (trendText.contains('↗') || trendText.contains('↘'))
                  Icon(
                    trendText.contains('↗') ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isTrendPositive ? AppColors.normal : AppColors.severe,
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trendText,
                    style: TextStyle(
                      color: trendText.contains('↗') || trendText.contains('↘') 
                          ? (isTrendPositive ? AppColors.normal : AppColors.severe)
                          : AppColors.textGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
