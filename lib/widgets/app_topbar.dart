import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/data_provider.dart';
import '../providers/locale_provider.dart';
import '../models/patient.dart';
import '../models/analysis.dart';
import '../services/translation_service.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1024;
    final isCompact = screenWidth < 1400;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : AppColors.borderGray)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      child: Row(
        children: [
          if (isMobile) ...[
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.textGray),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.bgLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderGray),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppColors.textGray),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isMobile ? 'search'.tr(context) : 'search_placeholder'.tr(context),
                        hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (query) {
                        _showSearchResults(context, query);
                      },
                    ),
                  ),
                  if (!isMobile)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        border: Border.all(color: isDark ? Colors.white10 : AppColors.borderGray),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('⌘K', style: TextStyle(fontSize: 10, color: AppColors.textGray, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          if (!isMobile) ...[
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: AppColors.textGray,
                size: 20,
              ),
              tooltip: 'Toggle Theme',
              onPressed: () => themeProvider.toggleTheme(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.textGray, size: 20),
              tooltip: 'system_settings'.tr(context),
              onPressed: () => context.go('/settings'),
            ),
            const SizedBox(width: 16),
          ],
          
          ElevatedButton.icon(
            onPressed: () => context.go('/upload'),
            icon: const Icon(Icons.add, size: 18),
            label: Text(isMobile ? 'upload'.tr(context) : 'upload_analyze'.tr(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16, 
                vertical: isMobile ? 8 : 12
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          
          if (!isMobile) ...[
            const SizedBox(width: 24),
            const VerticalDivider(width: 1, indent: 20, endIndent: 20),
            const SizedBox(width: 24),

            if (!isCompact) ...[
              _TopBarPill(
                icon: Icons.local_hospital_outlined,
                label: 'saveetha_medical_center'.tr(context),
                isOutline: true,
                onTap: () => _showOrgInfo(context),
              ),
              const SizedBox(width: 12),
            ],
            _StatusPill(
              label: 'ai_engine_online'.tr(context),
              color: AppColors.normal,
              onTap: () => _showAiStatus(context),
            ),
            const SizedBox(width: 12),
            
            _LanguagePill(label: localeProvider.shortName),
            const SizedBox(width: 12),

            if (!isCompact) ...[
              _TopBarPill(
                icon: Icons.access_time,
                label: DateFormat('EEE, MMM d', localeProvider.locale.toString()).format(DateTime.now()).toUpperCase(),
                onTap: () => _showCalendar(context),
              ),
              const SizedBox(width: 12),
            ],
          ],

          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: AppColors.textGray),
                if (dataProvider.unreadNotificationsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.severe, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '${dataProvider.unreadNotificationsCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
    );
  }

  void _showSearchResults(BuildContext context, String query) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final results = dataProvider.search(query);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search results for "$query"'),
        content: results.isEmpty 
          ? const Text('No matches found.')
          : SizedBox(
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  String title = '';
                  String id = '';
                  if (item is Patient) {
                    title = item.name;
                    id = 'Patient ID: ${item.id}';
                  } else if (item is Analysis) {
                    title = 'Analysis - ${item.patientName}';
                    id = DateFormat('MMM d, yyyy').format(item.dateTime);
                  }

                  IconData leadIcon = Icons.person_outline;
                  if (item is Analysis) leadIcon = Icons.analytics_outlined;

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(leadIcon, size: 20, color: AppColors.primary),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(id),
                    onTap: () {
                      Navigator.pop(context);
                      if (item is Patient) {
                        context.go('/patients/${item.id}');
                      } else {
                        context.go('/analyses');
                      }
                    },
                  );
                },
              ),
            ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(context))),
        ],
      ),
    );
  }

  void _showOrgInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Organization Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('saveetha_medical_center'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Affiliated with Saveetha University'),
            const Text('Location: Chennai, India'),
            const Text('Specialization: Sleep Medicine & Pulmonology'),
            const SizedBox(height: 16),
            const Text('Primary Contact:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Text('admin@saveetha.med', style: TextStyle(color: AppColors.primary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(context))),
        ],
      ),
    );
  }

  void _showAiStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Engine Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.normal),
              title: const Text('Connection Status'),
              trailing: const Text('Connected', style: TextStyle(color: AppColors.normal, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.normal),
              title: const Text('Backend Status'),
              trailing: const Text('Operational', style: TextStyle(color: AppColors.normal, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.bolt, color: AppColors.mild),
              title: const Text('AI Analysis Service'),
              trailing: const Text('Ready', style: TextStyle(color: AppColors.mild, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            const Text('Last connection check: Just now', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(context))),
        ],
      ),
    );
  }

  void _showCalendar(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  void _showNotifications(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final notifications = dataProvider.notifications;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Notifications'),
            if (notifications.isNotEmpty)
              TextButton(
                onPressed: () {
                  dataProvider.clearAllNotifications();
                  Navigator.pop(context);
                },
                child: const Text('Clear All', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        content: notifications.isEmpty
            ? const Text('No new notifications')
            : SizedBox(
                width: 350,
                height: 400,
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    return ListTile(
                      title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(n.body),
                      trailing: Text(DateFormat('HH:mm').format(n.timestamp), style: const TextStyle(fontSize: 10)),
                      onTap: () {
                        dataProvider.markNotificationAsRead(n.id);
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr(context))),
        ],
      ),
    );
  }
}

class _TopBarPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOutline;
  final VoidCallback? onTap;

  const _TopBarPill({required this.icon, required this.label, this.isOutline = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.bgLight),
          border: isOutline ? Border.all(color: AppColors.primary) : Border.all(color: AppColors.borderGray),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isOutline ? AppColors.primary : AppColors.textGray),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isOutline ? AppColors.primary : (isDark ? Colors.white70 : AppColors.textDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatusPill({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.bgLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11, 
                color: isDark ? Colors.white70 : AppColors.textDark, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final String label;

  const _LanguagePill({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => context.go('/settings'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.bgLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textGray, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
