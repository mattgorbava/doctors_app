class Patient {
  final String uid;
  final String email;
  final String profileImageUrl;
  final String city;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  //final String userId;
  final String cabinetId;
  final DateTime birthDate;
  final String insureeCode;
  final String cnp;

  Patient({
    required this.uid,
    required this.email,
    required this.profileImageUrl,
    required this.city,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    //required this.userId,
    required this.cabinetId,
    required this.birthDate,
    required this.insureeCode,
    required this.cnp,
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
      //userId: data['userId'] ?? '',
      cabinetId: data['cabinetId'] ?? '',
      birthDate: DateTime.parse(data['birthDate']),
      insureeCode: data['insureeCode'] ?? '',
      cnp: data['cnp'] ?? '',
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
      //'userId': userId,
      'cabinetId': cabinetId,
      'birthDate': birthDate.toIso8601String(),
      'insureeCode': insureeCode,
      'cnp': cnp,
    };
  }
}