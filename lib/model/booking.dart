class Booking {
  String date;
  String description;
  String id;
  String doctorId;
  String patientId;
  String status;
  String time;
  bool isMandatory;

  Booking({
    required this.date,
    required this.description,
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.time,
    required this.isMandatory,
  });

  factory Booking.fromMap(Map<String, dynamic> data, [String id = '']) {
    return Booking(
      id: id,
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      status: data['status'] ?? 'pending',
      time: data['time'] ?? '',
      isMandatory: data['isMandatory'] ?? false,
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
    };
  }
}