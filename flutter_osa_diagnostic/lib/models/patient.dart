class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double bmi;
  final String? phone;
  final String? email;
  final String medicalHistory;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bmi,
    this.phone,
    this.email,
    required this.medicalHistory,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? 'Other',
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      medicalHistory: json['medicalHistory'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'bmi': bmi,
      'phone': phone,
      'email': email,
      'medicalHistory': medicalHistory,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
