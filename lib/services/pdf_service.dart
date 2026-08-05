import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/analysis.dart';
import '../models/patient.dart';

class PdfService {
  static Future<Uint8List> generateMedicalReport(Analysis analysis, Patient patient) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('AeroDiag OSA Diagnostic Report',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Clinical Airway Analysis & AHI Scoring',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${DateFormat('MMM d, yyyy').format(analysis.dateTime)}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('ID: ${analysis.id}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 20),

              // Patient Information Section
              pw.Text('PATIENT INFORMATION', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _infoBox('FULL NAME', patient.name),
                  _infoBox('PATIENT ID', patient.id),
                  _infoBox('AGE / GENDER', '${patient.age} yrs / ${patient.gender}'),
                  _infoBox('BMI', '${patient.bmi} kg/m2'),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _infoBox('CONTACT', '${patient.email}\n${patient.phone}'),
                  pw.Expanded(flex: 2, child: _infoBox('MEDICAL HISTORY', patient.medicalHistory.isNotEmpty ? patient.medicalHistory : 'None recorded')),
                ],
              ),
              pw.SizedBox(height: 30),

              // Executive Summary
              pw.Text('EXECUTIVE SUMMARY', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _metricBox('AHI SCORE', analysis.ahi.toString(), _getSeverityColor(analysis.severity)),
                    _metricBox('SEVERITY', analysis.severity.toUpperCase(), _getSeverityColor(analysis.severity)),
                    _metricBox('CONSTRICTION', '${analysis.constriction}%', _getSeverityColor(analysis.severity)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Clinical Data Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('AIRWAY METRICS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        _dataRow('Min Airway Area', '${analysis.minAirwayArea} mm2'),
                        _dataRow('Total Airway Volume', '${analysis.airwayVolume} cm3'),
                        _dataRow('Scan Modality', analysis.modality.displayName),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EVENT ANALYSIS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        _dataRow('Apnea Events', '${analysis.apneaEvents}'),
                        _dataRow('Hypopnea Events', '${analysis.hypopneaEvents}'),
                        _dataRow('Mean Snore', '${analysis.snoreIntensity} dB'),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // AI Notes
              pw.Text('AI DIAGNOSTIC INTERPRETATION', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(analysis.diagnosticNotes ?? 'The AI engine indicates signs consistent with ${analysis.severity.toLowerCase()} OSA.',
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.2)),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Saveetha Medical Center · AeroDiag AI V2.5', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('__________________________', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Reviewing Physician Signature', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _infoBox(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _metricBox(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  static pw.Widget _dataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static PdfColor _getSeverityColor(String severity) {
    switch (severity) {
      case 'Normal': return PdfColors.green600;
      case 'Mild': return PdfColors.orange400;
      case 'Moderate': return PdfColors.orange700;
      case 'Severe': return PdfColors.red600;
      default: return PdfColors.black;
    }
  }
}
