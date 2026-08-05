import 'dart:async';
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/analysis.dart';
import '../models/app_notification.dart';
import '../services/firestore_service.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Patient> _patients = [];
  List<Analysis> _analyses = [];
  List<AppNotification> _notifications = [];
  
  StreamSubscription? _patientsSub;
  StreamSubscription? _analysesSub;

  DataProvider() {
    _init();
  }

  void _init() {
    // Listen to real-time updates from Firestore
    _patientsSub = _firestoreService.getPatients().listen((patients) {
      _patients = patients;
      notifyListeners();
    });

    _analysesSub = _firestoreService.getAnalyses().listen((analyses) {
      _analyses = analyses;
      notifyListeners();
    });

    // Mock notifications for now as they are usually ephemeral or local
    _notifications = [
      AppNotification(id: '1', title: 'Clinical Alert', body: 'Severe OSA detected for patient', timestamp: DateTime.now()),
    ];
  }

  @override
  void dispose() {
    _patientsSub?.cancel();
    _analysesSub?.cancel();
    super.dispose();
  }

  List<Patient> get patients => _patients;
  List<Analysis> get analyses => _analyses;
  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  Future<void> addPatient(Patient patient) async {
    await _firestoreService.addPatient(patient);
  }

  Future<void> addAnalysis(Analysis analysis) async {
    await _firestoreService.addAnalysis(analysis);
    
    // Update patient's latest status and scan count in Firestore
    int pIndex = _patients.indexWhere((p) => p.id == analysis.patientId);
    if (pIndex != -1) {
      Patient p = _patients[pIndex];
      final updatedPatient = Patient(
        id: p.id,
        name: p.name,
        age: p.age,
        gender: p.gender,
        email: p.email,
        phone: p.phone,
        bmi: p.bmi,
        medicalHistory: p.medicalHistory,
        scanCount: p.scanCount + 1,
        latestStatus: analysis.severity,
        registeredDate: p.registeredDate,
      );
      await _firestoreService.updatePatient(updatedPatient);
    }
  }

  String classifySeverity(double ahi) {
    if (ahi < 5) return 'Normal';
    if (ahi < 15) return 'Mild';
    if (ahi < 30) return 'Moderate';
    return 'Severe';
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  List<dynamic> search(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    
    final matchedPatients = _patients.where((p) => 
      p.name.toLowerCase().contains(lowerQuery) || 
      p.id.toLowerCase().contains(lowerQuery)
    ).toList();
    
    final matchedAnalyses = _analyses.where((a) => 
      a.patientName.toLowerCase().contains(lowerQuery) || 
      a.id.toLowerCase().contains(lowerQuery)
    ).toList();
    
    return [...matchedPatients, ...matchedAnalyses];
  }
}
