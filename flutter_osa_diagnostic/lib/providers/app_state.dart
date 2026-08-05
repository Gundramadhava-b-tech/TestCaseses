import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/scan.dart';
import '../models/analysis.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String? _currentUserEmail = 'doctor@aerodiag.med';
  String? get currentUserEmail => _currentUserEmail;

  List<Patient> _patients = [];
  List<Patient> get patients => _patients;

  List<Scan> _scans = [];
  List<Scan> get scans => _scans;

  List<Analysis> _analyses = [];
  List<Analysis> get analyses => _analyses;

  AppState() {
    loadData();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setCurrentUser(String? email) {
    _currentUserEmail = email;
    notifyListeners();
  }

  void updateApiBaseUrl(String newUrl) {
    ApiService.baseUrl = newUrl;
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _apiService.getPatients();
      _scans = await _apiService.getScans();
      _analyses = await _apiService.getAnalyses();
    } catch (e) {
      debugPrint('Error loading app state data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Patient> addPatient(Patient p) async {
    final created = await _apiService.createPatient(p);
    _patients.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<Analysis> runDiagnosticAnalysis({
    required String patientId,
    required String scanType,
    required String fileName,
    required double minAirwayArea,
    required double airwayVolume,
    required double snoreVolume,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.runDiagnosticAnalysis(
      patientId: patientId,
      scanType: scanType,
      fileName: fileName,
      minAirwayArea: minAirwayArea,
      airwayVolume: airwayVolume,
      snoreVolume: snoreVolume,
    );

    _analyses.insert(0, result);
    _scans = await _apiService.getScans();
    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Dashboard Stats
  int get totalPatients => _patients.length;
  int get totalScans => _scans.length;
  int get totalAnalyses => _analyses.length;

  Map<String, int> get severityDistribution {
    final Map<String, int> counts = {
      'Normal': 0,
      'Mild': 0,
      'Moderate': 0,
      'Severe': 0,
    };
    for (var a in _analyses) {
      counts[a.severity] = (counts[a.severity] ?? 0) + 1;
    }
    return counts;
  }
}
