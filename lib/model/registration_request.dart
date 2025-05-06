import 'package:doctors_app/model/child.dart';

class RegistrationRequest {
  String uid;
  String doctorId;
  String patientId;
  DateTime createdAt;
  DateTime updatedAt;
  String status;

  RegistrationRequest({
    required this.uid,
    required this.doctorId,
    required this.patientId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory RegistrationRequest.fromMap(Map<dynamic, dynamic> map, [String id = '']) {
    return RegistrationRequest(
      uid: id,
      doctorId: map['doctorId'],
      patientId: map['patientId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
    };
  }
}