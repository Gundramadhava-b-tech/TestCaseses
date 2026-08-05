import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/analysis.dart';
import '../models/patient.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Analysis analysis;
  final Patient patient;

  const PdfPreviewScreen({
    super.key,
    required this.analysis,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMobile ? 'Preview' : 'Report Preview - ${patient.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              children: [
                CircleAvatar(
                  radius: isMobile ? 18 : 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(patient.initials, style: TextStyle(color: AppColors.primary, fontSize: isMobile ? 10 : 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16), overflow: TextOverflow.ellipsis),
                      Text(
                        isMobile ? 'ID: ${patient.id} • ${patient.age} yrs' : 'ID: ${patient.id} • ${patient.age} yrs • ${patient.gender} • BMI: ${patient.bmi}', 
                        style: const TextStyle(color: AppColors.textGray, fontSize: 11)
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('AHI', style: TextStyle(color: AppColors.textGray, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text('${analysis.ahi}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 16 : 18, color: _getSeverityColor(analysis.severity))),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PdfPreview(
              build: (format) => PdfService.generateMedicalReport(analysis, patient),
              canDebug: false,
              onPrinted: (context) => _showSnackBar(context, 'Report sent to printer'),
              onShared: (context) => _showSnackBar(context, 'Report shared successfully'),
              padding: isMobile ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    if (severity.contains('Normal')) return AppColors.normal;
    if (severity.contains('Mild')) return AppColors.mild;
    if (severity.contains('Moderate')) return AppColors.moderate;
    if (severity.contains('Severe')) return AppColors.severe;
    return AppColors.textDark;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
