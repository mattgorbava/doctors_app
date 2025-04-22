class Child {
  final String uid;
  final String firstName;
  final String lastName;
  final String parentId;
  final String cabinetId;
  final String cnp;
  final DateTime birthDate;

  Child({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.parentId,
    required this.cabinetId,
    required this.cnp,
    required this.birthDate,
  });

  factory Child.fromMap(Map<String, dynamic> data, [String id = '']) {
    return Child(
      uid: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      parentId: data['parentId'] ?? '',
      cabinetId: data['cabinetId'] ?? '',
      cnp: data['cnp'] ?? '',
      birthDate: DateTime.parse(data['birthDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'parentId': parentId,
      'cabinetId': cabinetId,
      'cnp': cnp,
      'birthDate': birthDate.toIso8601String(),
    };
  }
}