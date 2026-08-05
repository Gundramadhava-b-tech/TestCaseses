import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../widgets/severity_badge.dart';
import '../models/analysis.dart';
import '../models/patient.dart';
import '../services/translation_service.dart';
import 'pdf_preview_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 1024;
    late final Patient patient;
    try {
      patient = dataProvider.patients.firstWhere((p) => p.id == patientId);
    } catch (e) {
      return const Scaffold(body: Center(child: Text('Patient not found.')));
    }

    final analyses = dataProvider.analyses.where((a) => a.patientId == patientId).toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, patient),
            const SizedBox(height: 32),
            _buildPatientProfile(context, patient),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'scan_history'.tr(context),
                    style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _generateHistoryPdf(context, patient),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: Text(isMobile ? 'export'.tr(context) : 'export_history_pdf'.tr(context)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAnalysesTimeline(context, analyses, patient),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Patient patient) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return isMobile
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/patients'),
                ),
                Text('patients'.tr(context).toUpperCase(), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text('/', style: TextStyle(color: AppColors.textGray, fontSize: 10)),
                ),
                Expanded(child: Text(patient.name.toUpperCase(), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 16),
            Text(patient.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/upload?patientId=${patient.id}'),
                icon: const Icon(Icons.add_chart_outlined),
                label: Text('run_new_analysis'.tr(context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ],
        )
      : Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/patients'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('patients'.tr(context).toUpperCase(), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('/', style: TextStyle(color: AppColors.textGray, fontSize: 10)),
                    ),
                    Text(patient.name.toUpperCase(), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(patient.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => context.go('/upload?patientId=${patient.id}'),
              icon: const Icon(Icons.add_chart_outlined),
              label: Text('run_new_analysis'.tr(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        );
  }

  Widget _buildPatientProfile(BuildContext context, Patient patient) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: isMobile
            ? Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(patient.initials, style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('ID: ${patient.id}', style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text('${patient.scanCount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const Text('SCANS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textGray)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      _buildInfoItem(context, 'age_gender'.tr(context), '${patient.age} yrs • ${patient.gender}'),
                      _buildInfoItem(context, 'bmi'.tr(context), '${patient.bmi} kg/m²'),
                      _buildStatusItem(context, 'latest_status'.tr(context), patient.latestStatus),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoItem(context, 'contact'.tr(context), '${patient.email} • ${patient.phone}'),
                  const SizedBox(height: 16),
                  _buildInfoItem(context, 'medical_history'.tr(context), patient.medicalHistory),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(patient.initials, style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(context, 'patient_id'.tr(context), patient.id),
                            _buildInfoItem(context, 'age_gender'.tr(context), '${patient.age} yrs • ${patient.gender}'),
                            _buildInfoItem(context, 'bmi'.tr(context), '${patient.bmi} kg/m²'),
                            _buildStatusItem(context, 'latest_status'.tr(context), patient.latestStatus),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildInfoItem(context, 'contact'.tr(context), '${patient.email}\n${patient.phone}'),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildInfoItem(context, 'medical_history'.tr(context), patient.medicalHistory),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('${patient.scanCount}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Text('total_scans'.tr(context), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGray)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, String severity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SeverityBadge(severity: severity),
      ],
    );
  }

  Widget _buildAnalysesTimeline(BuildContext context, List<Analysis> analyses, Patient patient) {
    if (analyses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              Icon(Icons.history_toggle_off, size: 48, color: AppColors.textGray.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text('No scan history available for this patient.'.tr(context), style: const TextStyle(color: AppColors.textGray)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: analyses.map((a) => _buildTimelineCard(context, a, patient)).toList(),
    );
  }

  Widget _buildTimelineCard(BuildContext context, Analysis a, Patient patient) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isMobile
          ? Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.history, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat('MMM d, yyyy').format(a.dateTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(a.modality.displayName, style: const TextStyle(color: AppColors.textGray, fontSize: 11)),
                        ],
                      ),
                    ),
                    SeverityBadge(severity: a.severity),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    _buildTimelineMetric(context, 'AHI', '${a.ahi}'),
                    _buildTimelineMetric(context, 'MIN AREA', '${a.minAirwayArea} mm²'),
                    _buildTimelineMetric(context, 'VOLUME', '${a.airwayVolume} cm³'),
                    _buildTimelineMetric(context, 'EVENTS', '${a.apneaEvents}A / ${a.hypopneaEvents}H'),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPreviewScreen(
                              analysis: a,
                              patient: patient,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('View PDF', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        context.go('/analyses?filter=${a.severity}');
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 18),
                      label: const Text('Details', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history, color: AppColors.primary),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('MMM d, yyyy').format(a.dateTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(a.modality.displayName, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                _buildTimelineMetric(context, 'AHI', '${a.ahi}'),
                const SizedBox(width: 24),
                _buildTimelineMetric(context, 'MIN AREA', '${a.minAirwayArea} mm²'),
                const SizedBox(width: 24),
                _buildTimelineMetric(context, 'VOLUME', '${a.airwayVolume} cm³'),
                const SizedBox(width: 24),
                _buildTimelineMetric(context, 'EVENTS', '${a.apneaEvents}A / ${a.hypopneaEvents}H'),
                const SizedBox(width: 32),
                SeverityBadge(severity: a.severity),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfPreviewScreen(
                          analysis: a,
                          patient: patient,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    context.go('/analyses?filter=${a.severity}');
                  },
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildTimelineMetric(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label.tr(context), style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _generateHistoryPdf(BuildContext context, Patient patient) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final patientAnalyses = dataProvider.analyses.where((a) => a.patientId == patient.id).toList();
    
    if (patientAnalyses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scans available to export.')),
      );
      return;
    }

    // Sort by date to get the latest
    patientAnalyses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final latestAnalysis = patientAnalyses.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(
          analysis: latestAnalysis,
          patient: patient,
        ),
      ),
    );
  }
}
