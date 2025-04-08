class Booking {
  final String date;
  final String description;
  final String id;
  final String doctorId;
  final String patientId;
  final String status;
  final String time;

  Booking({
    required this.date,
    required this.description,
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.time,
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
    };
  }
}