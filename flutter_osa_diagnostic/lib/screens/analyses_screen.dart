import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/patient.dart';
import '../services/pdf_service.dart';

class AnalysesScreen extends StatefulWidget {
  const AnalysesScreen({super.key});

  @override
  State<AnalysesScreen> createState() => _AnalysesScreenState();
}

class _AnalysesScreenState extends State<AnalysesScreen> {
  String _selectedSeverityFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final filteredAnalyses = appState.analyses.where((a) {
      if (_selectedSeverityFilter == 'All') return true;
      return a.severity.toLowerCase() == _selectedSeverityFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Analyses & Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () => Navigator.pushNamed(context, '/upload'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Normal', 'Mild', 'Moderate', 'Severe'].map((sev) {
                  final isSelected = _selectedSeverityFilter == sev;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(sev),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedSeverityFilter = sev),
                      selectedColor: Colors.blue.shade700,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Analyses Cards List
            Expanded(
              child: filteredAnalyses.isEmpty
                  ? const Center(child: Text('No diagnostic analyses found matching filter.'))
                  : ListView.builder(
                      itemCount: filteredAnalyses.length,
                      itemBuilder: (context, idx) {
                        final analysis = filteredAnalyses[idx];
                        final patient = appState.patients.firstWhere(
                          (p) => p.id == analysis.patientId,
                          orElse: () => Patient(
                            id: analysis.patientId,
                            name: 'Patient ${analysis.patientId}',
                            age: 0,
                            gender: '',
                            bmi: 0,
                            medicalHistory: '',
                            createdAt: DateTime.now(),
                          ),
                        );

                        Color badgeColor = analysis.severity == 'Severe'
                            ? Colors.red
                            : analysis.severity == 'Moderate'
                                ? Colors.orange
                                : analysis.severity == 'Mild'
                                    ? Colors.amber
                                    : Colors.green;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(patient.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text('${patient.age} yrs • BMI ${patient.bmi.toStringAsFixed(1)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${analysis.severity} (AHI: ${analysis.ahiScore})',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: _buildMetricTile('Min Airway Area', '${analysis.minAirwayArea} mm²')),
                                    Expanded(child: _buildMetricTile('Airway Volume', '${analysis.airwayVolume} cm³')),
                                    Expanded(child: _buildMetricTile('Snore Level', '${analysis.meanSnoreVolume} dB')),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (analysis.notes.isNotEmpty) ...[
                                  Text('Diagnostic Notes: ${analysis.notes}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                  const SizedBox(height: 12),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Date: ${analysis.createdAt.toString().split(' ')[0]}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                                      label: const Text('Export Medical PDF'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
                                      onPressed: () {
                                        PdfReportService.generateAndPrintReport(patient, analysis);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
