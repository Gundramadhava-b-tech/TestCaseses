import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../providers/app_state.dart';
import '../services/pdf_service.dart';
import 'upload_scan_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final patientAnalyses = appState.analyses.where((a) => a.patientId == patient.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Run New Scan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadScanScreen(preselectedPatientId: patient.id),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Profile Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(patient.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${patient.age} years old • ${patient.gender} • BMI: ${patient.bmi.toStringAsFixed(1)} kg/m²'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        if (patient.email != null && patient.email!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(patient.email!),
                            ],
                          ),
                        if (patient.phone != null && patient.phone!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(patient.phone!),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Medical History / Symptoms:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      patient.medicalHistory.isNotEmpty ? patient.medicalHistory : 'No detailed medical history provided.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Diagnostic History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Diagnostic Scans & AHI History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Analysis'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UploadScanScreen(preselectedPatientId: patient.id),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (patientAnalyses.isEmpty)
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.medical_information_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No diagnostic scans recorded for this patient yet.'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadScanScreen(preselectedPatientId: patient.id),
                              ),
                            );
                          },
                          child: const Text('Upload & Run Airway Scan'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: patientAnalyses.length,
                itemBuilder: (context, idx) {
                  final analysis = patientAnalyses[idx];
                  Color badgeColor = analysis.severity == 'Severe'
                      ? Colors.red
                      : analysis.severity == 'Moderate'
                          ? Colors.orange
                          : analysis.severity == 'Mild'
                              ? Colors.amber
                              : Colors.green;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AHI Score: ${analysis.ahiScore}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Chip(
                                label: Text(
                                  analysis.severity,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: badgeColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Airway Area: ${analysis.minAirwayArea} mm² • Volume: ${analysis.airwayVolume} cm³'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Snore Intensity: ${analysis.meanSnoreVolume} dB • Apnea Events: ${analysis.totalApneaEvents}'),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tested on: ${analysis.createdAt.toString().split(' ')[0]}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf, size: 16),
                                label: const Text('Export PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                  foregroundColor: Colors.white,
                                ),
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
          ],
        ),
      ),
    );
  }
}
