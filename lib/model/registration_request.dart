class RegistrationRequest {
  String? uid;
  String? doctorId;
  String? patientId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? status;

  RegistrationRequest({
    this.uid,
    this.doctorId,
    this.patientId,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  RegistrationRequest.fromMap(Map<String, dynamic> map, [String id = '']) {
    uid = id;
    doctorId = map['doctorId'];
    patientId = map['patientId'];
    createdAt = DateTime.parse(map['createdAt']);
    updatedAt = DateTime.parse(map['updatedAt']);
    status = map['status'];
  }
}