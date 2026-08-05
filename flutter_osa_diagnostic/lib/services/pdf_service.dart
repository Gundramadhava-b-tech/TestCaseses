import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/patient.dart';
import '../models/analysis.dart';

class PdfReportService {
  static Future<void> generateAndPrintReport(Patient patient, Analysis analysis) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('AeroDiag Medical Report',
                            style: pw.TextStyle(
                                fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text('Obstructive Sleep Apnea (OSA) Diagnostic Assessment',
                            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text('Date: ${analysis.createdAt.toString().split(' ')[0]}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                pw.SizedBox(height: 16),

                // Patient Info Section
                pw.Text('Patient Profile',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Name: ${patient.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Age: ${patient.age} yrs'),
                          pw.Text('Gender: ${patient.gender}'),
                          pw.Text('BMI: ${patient.bmi.toStringAsFixed(1)} kg/m²'),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        children: [
                          pw.Text('Medical History: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Expanded(child: pw.Text(patient.medicalHistory)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Diagnostic Findings Section
                pw.Text('Diagnostic Findings & AHI Assessment',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.SizedBox(height: 8),

                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: analysis.severity == 'Severe'
                              ? PdfColors.red50
                              : analysis.severity == 'Moderate'
                                  ? PdfColors.orange50
                                  : PdfColors.green50,
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(
                            color: analysis.severity == 'Severe'
                                ? PdfColors.red400
                                : analysis.severity == 'Moderate'
                                    ? PdfColors.orange400
                                    : PdfColors.green400,
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('AHI Index Score', style: const pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(height: 4),
                            pw.Text('${analysis.ahiScore}',
                                style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 4),
                            pw.Text('Classification: ${analysis.severity} OSA',
                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Metrics Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Parameter', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Measured Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Normal Reference Range', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Min Airway Area')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${analysis.minAirwayArea} mm²')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('> 60.0 mm²')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Airway Volume')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${analysis.airwayVolume} cm³')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('> 15.0 cm³')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Mean Snore Intensity')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${analysis.meanSnoreVolume} dB')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('< 50.0 dB')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Apnea Events')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${analysis.totalApneaEvents}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('< 5 events/hr')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Hypopnea Events')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${analysis.totalHypopneaEvents}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('< 10 events/hr')),
                    ]),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Clinical Notes
                pw.Text('Clinical Recommendation & Notes',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.SizedBox(height: 6),
                pw.Text(analysis.notes.isNotEmpty ? analysis.notes : 'No additional notes provided.',
                    style: const pw.TextStyle(fontSize: 11)),

                pw.Spacer(),

                // Footer
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('AeroDiag Medical Diagnostic System', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    pw.Text('Page 1 of 1', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'AeroDiag_Report_${patient.name.replaceAll(' ', '_')}.pdf',
    );
  }
}
