import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/severity_badge.dart';
import '../widgets/patient_avatar.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/analysis.dart';
import '../services/translation_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final analyses = dataProvider.analyses;
    final patients = dataProvider.patients;
    final severeCount = analyses.where((a) => a.severity == 'Severe').length;
    final isMobile = MediaQuery.of(context).size.width < 1024;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildStatCards(context, patients.length, analyses.length, severeCount),
            const SizedBox(height: 32),
            _buildDataVisualizationRow(context, analyses),
            const SizedBox(height: 32),
            _buildRecentScansSection(context, analyses),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userEmail?.split('@')[0] ?? 'Doctor';
    
    return isMobile 
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'diagnostic_overview'.tr(context),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back, $userName',
              style: const TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/upload'),
                icon: const Icon(Icons.add, size: 18),
                label: Text('new_diagnostic_scan'.tr(context)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ],
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'diagnostic_overview'.tr(context),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back, $userName',
                  style: const TextStyle(color: AppColors.textGray, fontSize: 14),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => context.go('/upload'),
              icon: const Icon(Icons.add, size: 18),
              label: Text('new_diagnostic_scan'.tr(context)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        );
  }

  Widget _buildStatCards(BuildContext context, int totalPatients, int totalScans, int severeCases) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmall = constraints.maxWidth < 600;
        int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : (isSmall ? 1 : 2));
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isSmall ? 1.8 : 1.6,
          children: [
            InkWell(
              onTap: () => context.go('/patients'),
              child: StatCard(
                iconColor: AppColors.primary,
                label: 'total_patients'.tr(context),
                value: '$totalPatients',
                icon: Icons.people_outline,
                trendText: '↗ +12% this month',
              ),
            ),
            InkWell(
              onTap: () => context.go('/analyses'),
              child: StatCard(
                iconColor: Colors.teal,
                label: 'diagnostic_scans'.tr(context),
                value: '$totalScans',
                icon: Icons.description_outlined,
                trendText: '↗ +8% this month',
              ),
            ),
            InkWell(
              onTap: () => context.go('/analyses'),
              child: StatCard(
                iconColor: Colors.indigo,
                label: 'analyses_run'.tr(context),
                value: '$totalScans',
                icon: Icons.analytics_outlined,
                trendText: 'stable_workflow'.tr(context),
              ),
            ),
            InkWell(
              onTap: () => context.go('/analyses?filter=Severe'),
              child: StatCard(
                iconColor: AppColors.severe,
                label: 'severe_osa_cases'.tr(context),
                value: '$severeCases',
                icon: Icons.error_outline,
                trendText: 'needs_follow_up'.tr(context),
                isTrendPositive: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataVisualizationRow(BuildContext context, List<Analysis> analyses) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Column(
            children: [
              _buildDoughnutChart(context, analyses),
              const SizedBox(height: 32),
              _buildSummaryCard(context, analyses),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _buildDoughnutChart(context, analyses)),
            const SizedBox(width: 32),
            Expanded(flex: 6, child: _buildSummaryCard(context, analyses)),
          ],
        );
      },
    );
  }

  Widget _buildDoughnutChart(BuildContext context, List<Analysis> analyses) {
    int normal = analyses.where((a) => a.severity == 'Normal').length;
    int mild = analyses.where((a) => a.severity == 'Mild').length;
    int moderate = analyses.where((a) => a.severity == 'Moderate').length;
    int severe = analyses.where((a) => a.severity == 'Severe').length;
    int total = analyses.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('osa_risk_distribution'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('ahi_classification'.tr(context), style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: total == 0 
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pie_chart_outline, size: 48, color: AppColors.textGray.withValues(alpha: 0.2)),
                        const SizedBox(height: 8),
                        const Text('No data available', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 65,
                          sections: [
                            _buildPieSection(context, AppColors.normal, normal.toDouble(), 'Normal'),
                            _buildPieSection(context, AppColors.mild, mild.toDouble(), 'Mild'),
                            _buildPieSection(context, AppColors.moderate, moderate.toDouble(), 'Moderate'),
                            _buildPieSection(context, AppColors.severe, severe.toDouble(), 'Severe'),
                          ],
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (event is FlTapUpEvent && response != null && response.touchedSection != null) {
                                final index = response.touchedSection!.touchedSectionIndex;
                                final labels = ['Normal', 'Mild', 'Moderate', 'Severe'];
                                if (index >= 0 && index < labels.length) {
                                  context.go('/analyses?filter=${labels[index]}');
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$total', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                            Text('total'.tr(context), style: const TextStyle(fontSize: 10, color: AppColors.textGray, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
            const SizedBox(height: 24),
            _buildLegendItem(context, AppColors.normal, 'Normal', normal),
            _buildLegendItem(context, AppColors.mild, 'Mild', mild),
            _buildLegendItem(context, AppColors.moderate, 'Moderate', moderate),
            _buildLegendItem(context, AppColors.severe, 'Severe', severe),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(BuildContext context, Color color, double value, String title) {
    return PieChartSectionData(
      color: color,
      value: value,
      radius: 20,
      showTitle: false,
      title: title,
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label, int count) {
    return InkWell(
      onTap: () => context.go('/analyses?filter=$label'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<Analysis> analyses) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('clinical_performance'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('System metrics and AI status', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
            const SizedBox(height: 48),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, size: 48, color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Neural Engine V2.5 Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('99.8% Analysis Accuracy', style: TextStyle(color: AppColors.normal, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickMetric('AVG AHI', '18.4'),
                _buildQuickMetric('AVG AREA', '72.2 mm²'),
                _buildQuickMetric('UPTIME', '100%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentScansSection(BuildContext context, List<Analysis> analyses) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'recent_diagnostic_scans'.tr(context),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Latest automated airway assessments',
                        style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => context.go('/analyses'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text('view_all'.tr(context)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width < 1024 ? 800 : 0),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderGray))),
                      children: [
                        _buildTableHeader('patient_name'.tr(context)),
                        _buildTableHeader('ahi_score'.tr(context)),
                        _buildTableHeader('min_area'.tr(context)),
                        _buildTableHeader('snore_db'.tr(context)),
                        _buildTableHeader('severity'.tr(context)),
                      ],
                    ),
                    ...analyses.take(5).map((a) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: InkWell(
                            onTap: () => context.go('/patients/${a.patientId}'),
                            child: Row(
                              children: [
                                PatientAvatar(initials: a.patientName.split(' ').map((n) => n[0]).join().toUpperCase()),
                                const SizedBox(width: 12),
                                Text(a.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('AHI ${a.ahi}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('${a.minAirwayArea}', style: const TextStyle(fontSize: 13)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('${a.snoreIntensity}', style: const TextStyle(fontSize: 13)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: SeverityBadge(severity: a.severity),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
