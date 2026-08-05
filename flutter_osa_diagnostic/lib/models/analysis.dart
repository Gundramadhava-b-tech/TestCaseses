class Analysis {
  final String id;
  final String patientId;
  final String scanId;
  final double ahiScore;
  final String severity; // Normal, Mild, Moderate, Severe
  final double minAirwayArea; // mm²
  final double airwayVolume; // cm³
  final double meanSnoreVolume; // dB
  final int totalApneaEvents;
  final int totalHypopneaEvents;
  final String notes;
  final DateTime createdAt;

  Analysis({
    required this.id,
    required this.patientId,
    required this.scanId,
    required this.ahiScore,
    required this.severity,
    required this.minAirwayArea,
    required this.airwayVolume,
    required this.meanSnoreVolume,
    required this.totalApneaEvents,
    required this.totalHypopneaEvents,
    required this.notes,
    required this.createdAt,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      scanId: json['scanId'] as String? ?? '',
      ahiScore: (json['ahiScore'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity'] as String? ?? 'Normal',
      minAirwayArea: (json['minAirwayArea'] as num?)?.toDouble() ?? 0.0,
      airwayVolume: (json['airwayVolume'] as num?)?.toDouble() ?? 0.0,
      meanSnoreVolume: (json['meanSnoreVolume'] as num?)?.toDouble() ?? 0.0,
      totalApneaEvents: json['totalApneaEvents'] as int? ?? 0,
      totalHypopneaEvents: json['totalHypopneaEvents'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'scanId': scanId,
      'ahiScore': ahiScore,
      'severity': severity,
      'minAirwayArea': minAirwayArea,
      'airwayVolume': airwayVolume,
      'meanSnoreVolume': meanSnoreVolume,
      'totalApneaEvents': totalApneaEvents,
      'totalHypopneaEvents': totalHypopneaEvents,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
