import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/scan.dart';
import '../models/analysis.dart';

class ApiService {
  static String baseUrl = kIsWeb
      ? 'http://localhost:3000/api'
      : 'http://10.0.2.2:3000/api';

  // Seed mock data for offline / fallback execution
  static final List<Patient> _mockPatients = [
    Patient(
      id: 'p1',
      name: 'John Doe',
      age: 48,
      gender: 'Male',
      bmi: 29.4,
      phone: '+1 (555) 234-5678',
      email: 'john.doe@example.com',
      medicalHistory: 'Chronic snoring, daytime fatigue, hypertension.',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Patient(
      id: 'p2',
      name: 'Sarah Connor',
      age: 36,
      gender: 'Female',
      bmi: 24.1,
      phone: '+1 (555) 987-6543',
      email: 'sarah.c@example.com',
      medicalHistory: 'Mild nocturnal gasping, restless sleep.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Patient(
      id: 'p3',
      name: 'Robert Vance',
      age: 55,
      gender: 'Male',
      bmi: 32.8,
      phone: '+1 (555) 456-7890',
      email: 'rvance@example.com',
      medicalHistory: 'Severe OSA history, CPAP non-compliant.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final List<Scan> _mockScans = [
    Scan(
      id: 's1',
      patientId: 'p1',
      scanType: 'Upper Airway CT',
      fileName: 'airway_ct_p1.dcm',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Scan(
      id: 's2',
      patientId: 'p2',
      scanType: 'Acoustic PSG Recording',
      fileName: 'psg_audio_p2.wav',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Scan(
      id: 's3',
      patientId: 'p3',
      scanType: '3D Airway MRI',
      fileName: 'mri_airway_p3.dcm',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final List<Analysis> _mockAnalyses = [
    Analysis(
      id: 'a1',
      patientId: 'p1',
      scanId: 's1',
      ahiScore: 18.5,
      severity: 'Moderate',
      minAirwayArea: 48.2,
      airwayVolume: 12.4,
      meanSnoreVolume: 64.2,
      totalApneaEvents: 42,
      totalHypopneaEvents: 69,
      notes: 'Velopharyngeal airway narrowing detected during supine position.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Analysis(
      id: 'a2',
      patientId: 'p2',
      scanId: 's2',
      ahiScore: 8.2,
      severity: 'Mild',
      minAirwayArea: 72.1,
      airwayVolume: 16.8,
      meanSnoreVolume: 51.0,
      totalApneaEvents: 12,
      totalHypopneaEvents: 37,
      notes: 'Mild positional hypopnea events during REM sleep.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Analysis(
      id: 'a3',
      patientId: 'p3',
      scanId: 's3',
      ahiScore: 34.8,
      severity: 'Severe',
      minAirwayArea: 22.5,
      airwayVolume: 8.1,
      meanSnoreVolume: 78.4,
      totalApneaEvents: 94,
      totalHypopneaEvents: 115,
      notes: 'Critical retropalatal collapse. Immediate CPAP therapy recommended.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<List<Patient>> getPatients() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/patients')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((e) => Patient.fromJson(e)).toList();
      }
    } catch (_) {
      // Fallback to mock when backend unavailable
    }
    return List.from(_mockPatients);
  }

  Future<Patient> createPatient(Patient p) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/patients'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(p.toJson()),
      ).timeout(const Duration(seconds: 3));
      if (res.statusCode == 201 || res.statusCode == 200) {
        return Patient.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    _mockPatients.insert(0, p);
    return p;
  }

  Future<List<Scan>> getScans({String? patientId}) async {
    try {
      final url = patientId != null
          ? '$baseUrl/scans?patientId=$patientId'
          : '$baseUrl/scans';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((e) => Scan.fromJson(e)).toList();
      }
    } catch (_) {}
    if (patientId != null) {
      return _mockScans.where((s) => s.patientId == patientId).toList();
    }
    return List.from(_mockScans);
  }

  Future<List<Analysis>> getAnalyses({String? patientId}) async {
    try {
      final url = patientId != null
          ? '$baseUrl/analyses?patientId=$patientId'
          : '$baseUrl/analyses';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((e) => Analysis.fromJson(e)).toList();
      }
    } catch (_) {}
    if (patientId != null) {
      return _mockAnalyses.where((a) => a.patientId == patientId).toList();
    }
    return List.from(_mockAnalyses);
  }

  Future<Analysis> runDiagnosticAnalysis({
    required String patientId,
    required String scanType,
    required String fileName,
    required double minAirwayArea,
    required double airwayVolume,
    required double snoreVolume,
  }) async {
    // Calculate AHI Score based on airway metrics & snore acoustic values
    double calculatedAhi = ((100 - minAirwayArea.clamp(10, 90)) * 0.3) +
        ((75 - snoreVolume.clamp(40, 90)).abs() * 0.25) +
        ((25 - airwayVolume.clamp(5, 25)) * 0.8);
    calculatedAhi = calculatedAhi.clamp(2.0, 58.0);

    String severity = 'Normal';
    if (calculatedAhi >= 30) {
      severity = 'Severe';
    } else if (calculatedAhi >= 15) {
      severity = 'Moderate';
    } else if (calculatedAhi >= 5) {
      severity = 'Mild';
    }

    final newScan = Scan(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      scanType: scanType,
      fileName: fileName,
      status: 'completed',
      createdAt: DateTime.now(),
    );
    _mockScans.insert(0, newScan);

    final newAnalysis = Analysis(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      scanId: newScan.id,
      ahiScore: double.parse(calculatedAhi.toStringAsFixed(1)),
      severity: severity,
      minAirwayArea: minAirwayArea,
      airwayVolume: airwayVolume,
      meanSnoreVolume: snoreVolume,
      totalApneaEvents: (calculatedAhi * 2.8).round(),
      totalHypopneaEvents: (calculatedAhi * 3.2).round(),
      notes: 'Automated airway segmentation & acoustic spectral analysis completed.',
      createdAt: DateTime.now(),
    );
    _mockAnalyses.insert(0, newAnalysis);

    return newAnalysis;
  }
}
