import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_state.dart';
import '../models/patient.dart';

class UploadScanScreen extends StatefulWidget {
  final String? preselectedPatientId;

  const UploadScanScreen({super.key, this.preselectedPatientId});

  @override
  State<UploadScanScreen> createState() => _UploadScanScreenState();
}

class _UploadScanScreenState extends State<UploadScanScreen> {
  String? _selectedPatientId;
  String _scanType = 'Upper Airway CT Scan';
  String? _pickedFileName;

  final _minAreaCtrl = TextEditingController(text: '45.0');
  final _volumeCtrl = TextEditingController(text: '11.5');
  final _snoreCtrl = TextEditingController(text: '62.0');

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.preselectedPatientId;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['dcm', 'wav', 'mp3', 'zip', 'png', 'jpg'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFileName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (_selectedPatientId == null && appState.patients.isNotEmpty) {
      _selectedPatientId = appState.patients.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Scan & Run Diagnostic')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Patient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPatientId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: appState.patients.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.id,
                      child: Text('${p.name} (${p.age} yrs, BMI: ${p.bmi})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedPatientId = val),
                ),
                const SizedBox(height: 20),

                const Text('Diagnostic Scan Modality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _scanType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Upper Airway CT Scan', child: Text('Upper Airway CT Scan')),
                    DropdownMenuItem(value: 'Acoustic PSG Sound Recording', child: Text('Acoustic PSG Sound Recording')),
                    DropdownMenuItem(value: '3D Airway MRI', child: Text('3D Airway MRI')),
                  ],
                  onChanged: (val) => setState(() => _scanType = val ?? 'Upper Airway CT Scan'),
                ),
                const SizedBox(height: 20),

                // File Upload Picker Zone
                const Text('Upload Medical File (DICOM / WAV / ZIP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300, style: BorderStyle.solid),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          _pickedFileName != null ? Icons.insert_drive_file : Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _pickedFileName ?? 'Click or tap to choose scan file',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _pickedFileName != null ? 'File attached successfully' : 'Supports .dcm, .wav, .mp3, .zip files',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Acoustic & Anatomical Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minAreaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Min Airway Area (mm²)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _volumeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Airway Volume (cm³)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _snoreCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mean Snore Sound Intensity (dB)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.analytics_outlined),
                    label: Text(
                      _isProcessing ? 'Calculating AHI & Severity...' : 'Run Diagnostic Analysis',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (_selectedPatientId == null) return;
                            setState(() => _isProcessing = true);

                            final minArea = double.tryParse(_minAreaCtrl.text) ?? 45.0;
                            final volume = double.tryParse(_volumeCtrl.text) ?? 11.5;
                            final snore = double.tryParse(_snoreCtrl.text) ?? 62.0;

                            await context.read<AppState>().runDiagnosticAnalysis(
                                  patientId: _selectedPatientId!,
                                  scanType: _scanType,
                                  fileName: _pickedFileName ?? 'upper_airway_scan.dcm',
                                  minAirwayArea: minArea,
                                  airwayVolume: volume,
                                  snoreVolume: snore,
                                );

                            if (mounted) {
                              setState(() => _isProcessing = false);
                              Navigator.pushReplacementNamed(context, '/analyses');
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
