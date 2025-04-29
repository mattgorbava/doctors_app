class Doctor {
  final String uid;
  final String email;
  final String profileImageUrl;
  final String city;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String cvUrl;
  final String legitimationNumber;
  final String? cabinetId;

  Doctor({
    required this.uid,
    required this.email,
    required this.profileImageUrl,
    required this.city,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.cvUrl,
    required this.legitimationNumber,
    this.cabinetId,
  });

  factory Doctor.fromMap(Map<dynamic, dynamic> map, [String id = '']) {
    return Doctor(
      uid: id,
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      city: map['city'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      cvUrl: map['cvUrl'],
      legitimationNumber: map['legitimationNumber'],
      cabinetId: map['cabinetId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'profileImageUrl': profileImageUrl,
      'city': city,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'cvUrl': cvUrl,
      'legitimationNumber': legitimationNumber,
      'cabinetId': cabinetId,
    };
  }
}