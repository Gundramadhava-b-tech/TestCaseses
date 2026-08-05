class Scan {
  final String id;
  final String patientId;
  final String scanType;
  final String fileName;
  final String? fileUrl;
  final String status;
  final DateTime createdAt;

  Scan({
    required this.id,
    required this.patientId,
    required this.scanType,
    required this.fileName,
    this.fileUrl,
    required this.status,
    required this.createdAt,
  });

  factory Scan.fromJson(Map<String, dynamic> json) {
    return Scan(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      scanType: json['scanType'] as String? ?? 'Upper Airway CT',
      fileName: json['fileName'] as String? ?? 'scan.dcm',
      fileUrl: json['fileUrl'] as String?,
      status: json['status'] as String? ?? 'completed',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'scanType': scanType,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
