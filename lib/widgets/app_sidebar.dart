import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/translation_service.dart';

class AppSidebar extends StatelessWidget {
  final String activeRoute;

  const AppSidebar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isMobile = MediaQuery.of(context).size.width < 1024;

    Widget content = Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: isMobile ? null : Border(right: BorderSide(color: isDark ? Colors.white10 : AppColors.borderGray)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.masks, size: 24, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AeroDiag',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    if (isMobile) ...[
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'OSA DIAGNOSTIC',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Text(
              'main_navigation'.tr(context),
              style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'dashboard'.tr(context),
            isActive: activeRoute == '/dashboard',
            onTap: () {
              context.go('/dashboard');
              if (isMobile) Navigator.pop(context);
            },
          ),
          _NavItem(
            icon: Icons.people_outline,
            label: 'patients'.tr(context),
            isActive: activeRoute == '/patients',
            onTap: () {
              context.go('/patients');
              if (isMobile) Navigator.pop(context);
            },
          ),
          _NavItem(
            icon: Icons.cloud_upload_outlined,
            label: 'upload_scan'.tr(context),
            isActive: activeRoute == '/upload',
            onTap: () {
              context.go('/upload');
              if (isMobile) Navigator.pop(context);
            },
          ),
          _NavItem(
            icon: Icons.analytics_outlined,
            label: 'analysis_results'.tr(context),
            isActive: activeRoute == '/analyses',
            onTap: () {
              context.go('/analyses');
              if (isMobile) Navigator.pop(context);
            },
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'system_settings'.tr(context),
            isActive: activeRoute == '/settings',
            onTap: () {
              context.go('/settings');
              if (isMobile) Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: ListTile(
              onTap: () => _showUserProfile(context, authProvider),
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              leading: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Text('DR', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              title: Text(
                authProvider.userEmail?.split('@')[0].toUpperCase() ?? 'DOCTOR',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text('Active Portal', style: TextStyle(fontSize: 9, color: AppColors.textGray)),
              trailing: IconButton(
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.severe),
                tooltip: 'logout'.tr(context),
                onPressed: () => _showLogoutConfirmation(context, authProvider),
              ),
            ),
          ),
        ],
      ),
    );

    return isMobile ? Drawer(width: 260, child: content) : content;
  }

  void _showUserProfile(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Physician Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryLight,
              child: Text('DR', style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text(authProvider.userEmail ?? 'doctor@aerodiag.med', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Lead Sleep Specialist', style: TextStyle(color: AppColors.textGray)),
            const SizedBox(height: 16),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.badge_outlined),
              title: Text('Medical License'),
              trailing: Text('MC-12345'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(context))),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.severe, size: 20),
            const SizedBox(width: 12),
            const Text('Confirm Logout'),
          ],
        ),
        content: const Text('You are about to end your clinical workspace session. Ensure all analysis reports are exported if needed.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(context))),
          ElevatedButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(context);
              // Sign out - this will trigger the GoRouter redirect automatically
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.severe,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: isActive
              ? BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                )
              : null,
          child: Row(
            children: [
              Icon(icon, size: 20, color: isActive ? AppColors.primary : AppColors.textGray),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textDark,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
