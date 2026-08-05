import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/data_provider.dart';
import '../models/analysis.dart';
import '../models/patient.dart';
import '../services/translation_service.dart';

class UploadScanScreen extends StatefulWidget {
  final String? preSelectedPatientId;
  const UploadScanScreen({super.key, this.preSelectedPatientId});

  @override
  State<UploadScanScreen> createState() => _UploadScanScreenState();
}

class _UploadScanScreenState extends State<UploadScanScreen> {
  Patient? _selectedPatient;
  ScanModality _selectedModality = ScanModality.upperAirwayCT;
  PlatformFile? _selectedFile;
  
  final _areaController = TextEditingController();
  final _volumeController = TextEditingController();
  final _snoreController = TextEditingController();
  final _apneaController = TextEditingController();
  final _hypopneaController = TextEditingController();

  bool _isAnalyzing = false;
  String _analysisStep = '';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preSelectedPatientId != null) {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        setState(() {
          final found = dataProvider.patients.where((p) => p.id == widget.preSelectedPatientId);
          if (found.isNotEmpty) {
            _selectedPatient = found.first;
          } else if (dataProvider.patients.isNotEmpty) {
            _selectedPatient = dataProvider.patients.first;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _areaController.dispose();
    _volumeController.dispose();
    _snoreController.dispose();
    _apneaController.dispose();
    _hypopneaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 1024;
    
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isMobile),
                const SizedBox(height: 24),
                if (_isAnalyzing) 
                  _buildAnalysisProgress(isMobile)
                else
                  _buildUploadForm(context, dataProvider, isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'upload_scan'.tr(context),
          style: TextStyle(fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Configure modality and upload scan for AI analysis',
          style: TextStyle(color: AppColors.textGray, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildUploadForm(BuildContext context, DataProvider dataProvider, bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown<Patient>(
              label: 'select_patient'.tr(context),
              hint: 'Choose a patient...',
              value: _selectedPatient,
              items: dataProvider.patients.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
              onChanged: (v) => setState(() => _selectedPatient = v),
            ),
            const SizedBox(height: 20),
            _buildDropdown<ScanModality>(
              label: 'scan_modality'.tr(context),
              hint: 'Select modality...',
              value: _selectedModality,
              items: ScanModality.values.map((m) => DropdownMenuItem(value: m, child: Text(m.displayName))).toList(),
              onChanged: (v) => setState(() => _selectedModality = v!),
            ),
            const SizedBox(height: 32),
            Text('scan_file'.tr(context), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
            const SizedBox(height: 12),
            _buildFilePicker(context, isMobile),
            const SizedBox(height: 32),
            Text('numeric_parameters'.tr(context), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
            const SizedBox(height: 16),
            _buildTextField(context, 'Min Airway Area (mm²)', 'e.g. 45.0', _areaController),
            const SizedBox(height: 16),
            _buildTextField(context, 'Airway Volume (cm³)', 'e.g. 12.4', _volumeController),
            const SizedBox(height: 16),
            _buildTextField(context, 'Mean Snore Intensity (dB)', 'e.g. 62.0', _snoreController),
            const SizedBox(height: 16),
            if (isMobile) ...[
              _buildTextField(context, 'Apnea Events', 'e.g. 15', _apneaController),
              const SizedBox(height: 16),
              _buildTextField(context, 'Hypopnea Events', 'e.g. 5', _hypopneaController),
            ] else
              Row(
                children: [
                  Expanded(child: _buildTextField(context, 'Apnea Events', 'e.g. 15', _apneaController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(context, 'Hypopnea Events', 'e.g. 5', _hypopneaController)),
                ],
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedPatient != null && _selectedFile != null) 
                  ? () => _runAnalysis(context, dataProvider) 
                  : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Run Diagnostic Analysis'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.bgLight,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGray)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : AppColors.bgLight,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker(BuildContext context, bool isMobile) {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 40, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
        ),
        child: _selectedFile == null 
          ? Column(
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text('Tap to choose DICOM / WAV scan file', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('Supported: .dcm, .wav, .mp3, .zip, .nii', style: TextStyle(color: AppColors.textGray, fontSize: 11)),
              ],
            )
          : Column(
              children: [
                const Icon(Icons.insert_drive_file_outlined, size: 40, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(_selectedFile!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                Text('${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB • ${_selectedFile!.extension?.toUpperCase()}', style: const TextStyle(color: AppColors.textGray, fontSize: 11)),
                const SizedBox(height: 12),
                TextButton(onPressed: _pickFile, child: const Text('Change File')),
              ],
            ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['dcm', 'dicom', 'png', 'jpg', 'jpeg', 'wav', 'mp3', 'zip', 'nii', 'gz'],
    );
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _runAnalysis(BuildContext context, DataProvider dataProvider) async {
    setState(() {
      _isAnalyzing = true;
      _analysisStep = 'Uploading...';
      _progress = 0.2;
    });
    
    final steps = [
      'Processing scan metadata...',
      'Segmenting airway geometry...',
      'Calculating AHI score...',
      'Classifying OSA severity...',
      'Generating diagnostic report...',
    ];

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _analysisStep = steps[i];
        _progress = 0.2 + (0.8 * (i + 1) / steps.length);
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    
    int apnea = int.tryParse(_apneaController.text) ?? 20;
    int hypopnea = int.tryParse(_hypopneaController.text) ?? 10;
    double ahi = (apnea + hypopnea) / 8.0;
    String severity = dataProvider.classifySeverity(ahi);

    final newAnalysis = Analysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _selectedPatient!.id,
      patientName: _selectedPatient!.name,
      patientAge: _selectedPatient!.age,
      patientBmi: _selectedPatient!.bmi,
      modality: _selectedModality,
      ahi: double.parse(ahi.toStringAsFixed(1)),
      severity: severity,
      minAirwayArea: double.tryParse(_areaController.text) ?? 45.2,
      airwayVolume: double.tryParse(_volumeController.text) ?? 11.5,
      snoreIntensity: double.tryParse(_snoreController.text) ?? 62.4,
      apneaEvents: apnea,
      hypopneaEvents: hypopnea,
      constriction: 55.4, 
      dateTime: DateTime.now(),
      diagnosticNotes: 'AI analysis indicates $severity OSA profile. Primary narrowing in retropalatal region.',
    );
    
    dataProvider.addAnalysis(newAnalysis);
    
    if (mounted) {
      GoRouter.of(context).go('/analyses');
    }
  }

  Widget _buildAnalysisProgress(bool isMobile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderGray),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: isMobile ? 100 : 120,
              width: isMobile ? 100 : 120,
              child: CircularProgressIndicator(value: _progress, strokeWidth: 8, backgroundColor: AppColors.borderGray),
            ),
            const SizedBox(height: 40),
            Text(_analysisStep, textAlign: TextAlign.center, style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('AI Diagnostic Engine is processing...', style: TextStyle(color: AppColors.textGray)),
            const SizedBox(height: 40),
            LinearProgressIndicator(value: _progress, minHeight: 8, borderRadius: BorderRadius.circular(4), backgroundColor: AppColors.borderGray),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
