class Doctor {
  final String uid;
  final String city;
  final String email;
  final String firstName;
  final String lastName;
  final String profileImageUrl;
  final String cvUrl;
  final String university;
  final String phoneNumber;
  final String legitimationNumber;

  Doctor({
    required this.uid,
    required this.city,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
    required this.cvUrl,
    required this.university,
    required this.phoneNumber,
    required this.legitimationNumber,
  });

  factory Doctor.fromMap(Map<dynamic, dynamic> map, [String id = '']) {
    return Doctor(
      uid: id,
      city: map['city'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      profileImageUrl: map['profileImageUrl'],
      cvUrl: map['cvUrl'],
      university: map['university'],
      phoneNumber: map['phoneNumber'],
      legitimationNumber: map['legitimationNumber'],
    );
  }
}