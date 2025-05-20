class Booking {
  String date;
  String description;
  String id;
  String doctorId;
  String patientId;
  String status;
  String time;
  bool isMandatory;
  String analysisResultsPdf;
  String recommendations;
  String results;

  Booking({
    required this.date,
    required this.description,
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.time,
    required this.isMandatory,
    this.analysisResultsPdf = '',
    this.recommendations = '',
    this.results = '',
  });

  factory Booking.fromMap(Map<String, dynamic> data, [String id = '']) {
    return Booking(
      id: id,
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      status: data['status'] ?? '',
      time: data['time'] ?? '',
      isMandatory: data['isMandatory'] ?? false,
      analysisResultsPdf: data['analysisResultsPdf'] ?? '',
      recommendations: data['recommendations'] ?? '',
      results: data['results'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'status': status,
      'time': time,
      'isMandatory': isMandatory,
      'analysisResultsPdf': analysisResultsPdf,
      'recommendations': recommendations,
      'results': results,
    };
  }
}