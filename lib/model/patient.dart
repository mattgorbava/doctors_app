class Patient {
  String uid;
  String email;
  String profileImageUrl;
  String city;
  String firstName;
  String lastName;
  String phoneNumber;
  String cabinetId;
  DateTime birthDate;
  String cnp;
  String parentId;
  bool hasEmergency;
  String? emergencySymptoms;

  Patient({
    required this.uid,
    this.email = '',
    this.profileImageUrl = '',
    this.city = '',
    required this.firstName,
    required this.lastName,
    this.phoneNumber = '',
    required this.cabinetId,
    required this.birthDate,
    required this.cnp,
    this.parentId = '',
    this.hasEmergency = false,
    this.emergencySymptoms,
  });

  factory Patient.fromMap(Map<String, dynamic> data, [String id = '']) {
    return Patient(
      uid: id,
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      city: data['city'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      cabinetId: data['cabinetId'] ?? '',
      birthDate: DateTime.parse(data['birthDate']),
      cnp: data['cnp'] ?? '',
      parentId: data['parentId'] ?? '',
      hasEmergency: data['hasEmergency'] ?? false,
      emergencySymptoms: data['emergencySymptoms'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'city': city,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'cabinetId': cabinetId,
      'birthDate': birthDate.toIso8601String(),
      'cnp': cnp,
      'parentId': parentId,
      'hasEmergency': hasEmergency,
      'emergencySymptoms': emergencySymptoms,
    };
  }

  factory Patient.empty() {
    return Patient(
      uid: '',
      email: '',
      profileImageUrl: '',
      city: '',
      firstName: '',
      lastName: '',
      phoneNumber: '',
      cabinetId: '',
      birthDate: DateTime.now(),
      cnp: '',
      parentId: '',
      hasEmergency: false,
      emergencySymptoms: '',
    );
  }

  bool get isEmpty {
    return uid.isEmpty &&
        email.isEmpty &&
        profileImageUrl.isEmpty &&
        city.isEmpty &&
        firstName.isEmpty &&
        lastName.isEmpty &&
        phoneNumber.isEmpty &&
        cabinetId.isEmpty &&
        cnp.isEmpty &&
        parentId.isEmpty &&
        !hasEmergency &&
        (emergencySymptoms == null || emergencySymptoms!.isEmpty);
  }

  bool get isNotEmpty {
    return !isEmpty;
  }
}