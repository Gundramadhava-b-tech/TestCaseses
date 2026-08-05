import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';
import '../models/analysis.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Patients ---

  Stream<List<Patient>> getPatients() {
    return _db.collection('patients').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => _mapDocToPatient(doc)).toList());
  }

  Future<void> addPatient(Patient patient) {
    return _db.collection('patients').doc(patient.id).set(_mapPatientToMap(patient));
  }

  Future<void> updatePatient(Patient patient) {
    return _db.collection('patients').doc(patient.id).update(_mapPatientToMap(patient));
  }

  // --- Analyses ---

  Stream<List<Analysis>> getAnalyses() {
    return _db.collection('analyses').orderBy('dateTime', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => _mapDocToAnalysis(doc)).toList());
  }

  Future<void> addAnalysis(Analysis analysis) {
    return _db.collection('analyses').doc(analysis.id).set(_mapAnalysisToMap(analysis));
  }

  // --- Helpers ---

  Patient _mapDocToPatient(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      bmi: (data['bmi'] ?? 0).toDouble(),
      medicalHistory: data['medicalHistory'] ?? '',
      scanCount: data['scanCount'] ?? 0,
      latestStatus: data['latestStatus'] ?? 'Normal',
      registeredDate: (data['registeredDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _mapPatientToMap(Patient p) {
    return {
      'name': p.name,
      'age': p.age,
      'gender': p.gender,
      'email': p.email,
      'phone': p.phone,
      'bmi': p.bmi,
      'medicalHistory': p.medicalHistory,
      'scanCount': p.scanCount,
      'latestStatus': p.latestStatus,
      'registeredDate': Timestamp.fromDate(p.registeredDate),
    };
  }

  Analysis _mapDocToAnalysis(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Analysis(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientAge: data['patientAge'] ?? 0,
      patientBmi: (data['patientBmi'] ?? 0).toDouble(),
      modality: ScanModality.values.firstWhere((m) => m.toString() == data['modality'], orElse: () => ScanModality.upperAirwayCT),
      ahi: (data['ahi'] ?? 0).toDouble(),
      severity: data['severity'] ?? 'Normal',
      minAirwayArea: (data['minAirwayArea'] ?? 0).toDouble(),
      airwayVolume: (data['airwayVolume'] ?? 0).toDouble(),
      snoreIntensity: (data['snoreIntensity'] ?? 0).toDouble(),
      apneaEvents: data['apneaEvents'] ?? 0,
      hypopneaEvents: data['hypopneaEvents'] ?? 0,
      constriction: (data['constriction'] ?? 0).toDouble(),
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      diagnosticNotes: data['diagnosticNotes'],
      reportUrl: data['reportUrl'],
    );
  }

  Map<String, dynamic> _mapAnalysisToMap(Analysis a) {
    return {
      'patientId': a.patientId,
      'patientName': a.patientName,
      'patientAge': a.patientAge,
      'patientBmi': a.patientBmi,
      'modality': a.modality.toString(),
      'ahi': a.ahi,
      'severity': a.severity,
      'minAirwayArea': a.minAirwayArea,
      'airwayVolume': a.airwayVolume,
      'snoreIntensity': a.snoreIntensity,
      'apneaEvents': a.apneaEvents,
      'hypopneaEvents': a.hypopneaEvents,
      'constriction': a.constriction,
      'dateTime': Timestamp.fromDate(a.dateTime),
      'diagnosticNotes': a.diagnosticNotes,
      'reportUrl': a.reportUrl,
    };
  }
}
