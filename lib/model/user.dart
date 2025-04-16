class User {
  final String uid;
  final String email;
  final String profileImageUrl;
  final String userType;

  User({
    required this.uid,
    required this.email,
    required this.profileImageUrl,
    required this.userType,
  });

  factory User.fromMap(Map<String, dynamic> map, [String id = '']) {
    return User(
      uid: id,
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      userType: map['userType'],
    );
  }
}

