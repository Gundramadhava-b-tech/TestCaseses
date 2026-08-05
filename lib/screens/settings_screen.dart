import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../services/translation_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 1024;

    return DefaultTabController(
      length: 5,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isMobile),
            _buildTabBar(context, isMobile),
            Expanded(
              child: TabBarView(
                children: [
                  _AppearanceTab(themeProvider: themeProvider, isMobile: isMobile),
                  _LanguageTab(localeProvider: localeProvider, isMobile: isMobile),
                  _DiagnosticUnitsTab(isMobile: isMobile),
                  _ApiConnectionTab(isMobile: isMobile),
                  _AlertsTab(isMobile: isMobile),
                ],
              ),
            ),
            _buildFooterActions(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, isMobile ? 16 : 32, isMobile ? 16 : 32, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(10)
            ),
            child: const Icon(Icons.settings_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('system_settings'.tr(context), style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text('Configure clinical environment and AI sensitivity', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderGray))),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textGray,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: [
          Tab(text: 'appearance'.tr(context)),
          Tab(text: 'language'.tr(context)),
          Tab(text: 'units'.tr(context)),
          Tab(text: 'api'.tr(context)),
          Tab(text: 'alerts'.tr(context)),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: const Border(top: BorderSide(color: AppColors.borderGray))
      ),
      child: Row(
        mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text('discard'.tr(context)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16)
              ),
              child: Text('save'.tr(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceTab extends StatelessWidget {
  final ThemeProvider themeProvider;
  final bool isMobile;
  const _AppearanceTab({required this.themeProvider, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    bool isDark = themeProvider.themeMode == ThemeMode.dark;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THEME MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
          const SizedBox(height: 20),
          if (isMobile) ...[
            _buildSelectableCard(context, Icons.wb_sunny_outlined, 'light_mode'.tr(context), 'Clean clinical canvas', !isDark, () => themeProvider.toggleTheme()),
            const SizedBox(height: 16),
            _buildSelectableCard(context, Icons.nightlight_outlined, 'dark_mode'.tr(context), 'Eye-safe medical dark theme', isDark, () => themeProvider.toggleTheme()),
          ] else
            Row(
              children: [
                Expanded(child: _buildSelectableCard(context, Icons.wb_sunny_outlined, 'light_mode'.tr(context), 'Clean clinical canvas', !isDark, () => themeProvider.toggleTheme())),
                const SizedBox(width: 20),
                Expanded(child: _buildSelectableCard(context, Icons.nightlight_outlined, 'dark_mode'.tr(context), 'Eye-safe medical dark theme', isDark, () => themeProvider.toggleTheme())),
              ],
            ),
        ],
      ),
    );
  }
}

class _LanguageTab extends StatelessWidget {
  final LocaleProvider localeProvider;
  final bool isMobile;
  const _LanguageTab({required this.localeProvider, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SELECT PREFERRED LANGUAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 4.5 : 3.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLanguageCard(context, 'US', 'English (US)', 'English', localeProvider.locale.languageCode == 'en', () => localeProvider.setLocale(const Locale('en', 'US'))),
              _buildLanguageCard(context, 'IN', 'తెలుగు', 'Telugu', localeProvider.locale.languageCode == 'te', () => localeProvider.setLocale(const Locale('te', 'IN'))),
              _buildLanguageCard(context, 'IN', 'தமிழ்', 'Tamil', localeProvider.locale.languageCode == 'ta', () => localeProvider.setLocale(const Locale('ta', 'IN'))),
              _buildLanguageCard(context, 'IN', 'हिन्दी', 'Hindi', localeProvider.locale.languageCode == 'hi', () => localeProvider.setLocale(const Locale('hi', 'IN'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiagnosticUnitsTab extends StatefulWidget {
  final bool isMobile;
  const _DiagnosticUnitsTab({required this.isMobile});

  @override
  State<_DiagnosticUnitsTab> createState() => _DiagnosticUnitsTabState();
}

class _DiagnosticUnitsTabState extends State<_DiagnosticUnitsTab> {
  String _unit = 'Square Millimeters (mm²)';
  String _sensitivity = 'Standard';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AIRWAY MEASUREMENT UNIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
          const SizedBox(height: 20),
          if (widget.isMobile) ...[
            _buildSelectableCard(context, Icons.square_foot, 'Square Millimeters (mm²)', 'Standard clinical area metric', _unit == 'Square Millimeters (mm²)', () => setState(() => _unit = 'Square Millimeters (mm²)')),
            const SizedBox(height: 16),
            _buildSelectableCard(context, Icons.square_foot, 'Square Centimeters (cm²)', 'Scaled radiological metric', _unit == 'Square Centimeters (cm²)', () => setState(() => _unit = 'Square Centimeters (cm²)')),
          ] else
            Row(
              children: [
                Expanded(child: _buildSelectableCard(context, Icons.square_foot, 'Square Millimeters (mm²)', 'Standard clinical area metric', _unit == 'Square Millimeters (mm²)', () => setState(() => _unit = 'Square Millimeters (mm²)'))),
                const SizedBox(width: 20),
                Expanded(child: _buildSelectableCard(context, Icons.square_foot, 'Square Centimeters (cm²)', 'Scaled radiological metric', _unit == 'Square Centimeters (cm²)', () => setState(() => _unit = 'Square Centimeters (cm²)'))),
              ],
            ),
          const SizedBox(height: 32),
          const Text('AI SENSITIVITY THRESHOLD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
          const SizedBox(height: 20),
          if (widget.isMobile) ...[
            _buildSelectableCard(context, Icons.balance, 'Standard', 'Balanced classification', _sensitivity == 'Standard', () => setState(() => _sensitivity = 'Standard')),
            const SizedBox(height: 16),
            _buildSelectableCard(context, Icons.speed, 'High Sensitivity', 'Early narrowing detection', _sensitivity == 'High Sensitivity', () => setState(() => _sensitivity = 'High Sensitivity')),
          ] else
            Row(
              children: [
                Expanded(child: _buildSelectableCard(context, Icons.balance, 'Standard', 'Balanced classification', _sensitivity == 'Standard', () => setState(() => _sensitivity = 'Standard'))),
                const SizedBox(width: 20),
                Expanded(child: _buildSelectableCard(context, Icons.speed, 'High Sensitivity', 'Early narrowing detection', _sensitivity == 'High Sensitivity', () => setState(() => _sensitivity = 'High Sensitivity'))),
              ],
            ),
        ],
      ),
    );
  }
}

class _ApiConnectionTab extends StatelessWidget {
  final bool isMobile;
  const _ApiConnectionTab({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BACKEND API CONFIGURATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('API Host Base URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'https://api.aerodiag.med/v2',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.link, size: 18),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Save & Reconnect API'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  final bool isMobile;
  const _AlertsTab({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        children: [
          _buildAlertOption(context, 'Push Notifications', 'Severe OSA detection alerts', true),
          const SizedBox(height: 12),
          _buildAlertOption(context, 'Email Digests', 'Daily summary of results', true),
        ],
      ),
    );
  }

  Widget _buildAlertOption(BuildContext context, String title, String subtitle, bool value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: (v) {}, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}

Widget _buildSelectableCard(BuildContext context, IconData icon, String title, String subtitle, bool selected, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppColors.primary : AppColors.borderGray, width: selected ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: selected ? AppColors.primary : AppColors.textGray, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: const TextStyle(color: AppColors.textGray, fontSize: 11)),
        ],
      ),
    ),
  );
}

Widget _buildLanguageCard(BuildContext context, String code, String title, String native, bool selected, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppColors.primary : AppColors.borderGray, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textGray)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(native, style: const TextStyle(color: AppColors.textGray, fontSize: 11)),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
        ],
      ),
    ),
  );
}
