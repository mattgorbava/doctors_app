class MedicalHistory {
  String id;
  String doctorId;
  String patientId;
  String date;
  String reason;
  String results;
  String recommendations;
  String checkUpType; //routine (control normal), emergency (pacientul raporteaza probleme), tests (analize de laborator)

  MedicalHistory({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.reason,
    required this.date,
    required this.results,
    required this.recommendations,
    required this.checkUpType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'reason': reason,
      'date': date,
      'results': results,
      'recommendations': recommendations,
      'checkUpType': checkUpType,
    };
  }

  factory MedicalHistory.fromMap(Map<String, dynamic> json, [String id = '']) {
    return MedicalHistory(
      id: id,
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      reason: json['reason'],
      date: json['date'],
      results: json['results'],
      recommendations: json['recommendations'],
      checkUpType: json['checkUpType'],
    );
  }
}