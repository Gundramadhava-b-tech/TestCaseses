import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PatientAvatar extends StatelessWidget {
  final String initials;
  final Color? backgroundColor;

  const PatientAvatar({
    super.key,
    required this.initials,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: backgroundColor ?? AppColors.primaryLight,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
