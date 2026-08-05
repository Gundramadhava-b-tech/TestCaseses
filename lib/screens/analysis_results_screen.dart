import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/severity_badge.dart';
import '../providers/data_provider.dart';
import '../models/analysis.dart';
import '../services/translation_service.dart';
import 'pdf_preview_screen.dart';

class AnalysisResultsScreen extends StatefulWidget {
  final String? initialFilter;
  const AnalysisResultsScreen({super.key, this.initialFilter});

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 1024;
    
    final analyses = dataProvider.analyses.where((a) {
      if (_selectedFilter == 'All') return true;
      return a.severity == _selectedFilter;
    }).toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isMobile),
            const SizedBox(height: 24),
            _buildFilterChips(context),
            const SizedBox(height: 24),
            _buildResultsList(context, analyses, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'analysis_results'.tr(context),
          style: TextStyle(fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Review and export patient OSA analysis results',
          style: TextStyle(color: AppColors.textGray, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['All', 'Normal', 'Mild', 'Moderate', 'Severe'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          bool isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = f),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              backgroundColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.borderGray),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<Analysis> analyses, bool isMobile) {
    if (analyses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            children: [
              Icon(Icons.analytics_outlined, size: 64, color: AppColors.textGray.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              const Text('No reports found for the selected filter.', style: TextStyle(color: AppColors.textGray)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: analyses.map((a) => _buildAnalysisCard(context, a, isMobile)).toList(),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, Analysis a, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.patientName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${a.patientAge} yrs • ${a.patientBmi} kg/m²', style: const TextStyle(color: AppColors.textGray, fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(DateFormat('MMM d, yyyy • h:mm a').format(a.dateTime), style: const TextStyle(color: AppColors.textGray, fontSize: 10)),
                    ],
                  ),
                ),
                SeverityBadge(severity: isMobile ? a.severity : '${a.severity} (AHI: ${a.ahi})'),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricItem('modality'.tr(context).toUpperCase(), a.modality.displayName),
                  const SizedBox(width: 32),
                  _buildMetricItem('ahi'.tr(context).toUpperCase(), '${a.ahi}'),
                  const SizedBox(width: 32),
                  _buildMetricItem('min_area'.tr(context).toUpperCase(), '${a.minAirwayArea} mm²'),
                  const SizedBox(width: 32),
                  _buildMetricItem('volume'.tr(context).toUpperCase(), '${a.airwayVolume} cm³'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('diagnostic_notes'.tr(context).toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textGray)),
                const SizedBox(height: 8),
                Text(
                  a.diagnosticNotes ?? 'No clinical notes provided by AI engine.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _exportPdf(context, a),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('Export Medical PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _exportPdf(BuildContext context, Analysis analysis) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final patient = dataProvider.patients.firstWhere((p) => p.id == analysis.patientId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(
          analysis: analysis,
          patient: patient,
        ),
      ),
    );
  }
}
