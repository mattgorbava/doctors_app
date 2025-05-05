class Child {
  String uid;
  String firstName;
  String lastName;
  String parentId;
  String cabinetId;
  String cnp;
  DateTime birthDate;

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

  bool get isEmpty {
    return 
    uid.isEmpty &&
    firstName.isEmpty && 
    lastName.isEmpty && 
    parentId.isEmpty && 
    cnp.isEmpty && 
    cabinetId.isEmpty;
  }

  factory Child.empty() {
    return Child(
      uid: '',
      firstName: '',
      lastName: '',
      parentId: '',
      cabinetId: '',
      cnp: '',
      birthDate: DateTime.now(),
    );
  }
}