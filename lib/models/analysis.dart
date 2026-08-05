enum ScanModality {
  upperAirwayCT,
  acousticPSG,
  airwayMRI,
}

extension ScanModalityExtension on ScanModality {
  String get displayName {
    switch (this) {
      case ScanModality.upperAirwayCT:
        return 'Upper Airway CT';
      case ScanModality.acousticPSG:
        return 'Acoustic PSG';
      case ScanModality.airwayMRI:
        return '3D Airway MRI';
    }
  }
}

class Analysis {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final double patientBmi;
  final ScanModality modality;
  final double ahi;
  final String severity; // Normal, Mild, Moderate, Severe
  final double minAirwayArea; // mm2
  final double airwayVolume; // cm3
  final double snoreIntensity; // dB
  final int apneaEvents;
  final int hypopneaEvents;
  final double constriction; // percentage
  final DateTime dateTime;
  final String? diagnosticNotes;
  final String? reportUrl;

  Analysis({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientBmi,
    required this.modality,
    required this.ahi,
    required this.severity,
    required this.minAirwayArea,
    required this.airwayVolume,
    required this.snoreIntensity,
    required this.apneaEvents,
    required this.hypopneaEvents,
    required this.constriction,
    required this.dateTime,
    this.diagnosticNotes,
    this.reportUrl,
  });
}
