class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final double bmi;
  final String medicalHistory;
  final int scanCount;
  final String latestStatus;
  final DateTime registeredDate;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.bmi,
    required this.medicalHistory,
    required this.scanCount,
    required this.latestStatus,
    required this.registeredDate,
  });

  String get initials {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'P';
  }
}
