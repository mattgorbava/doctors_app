import 'package:firebase_database/firebase_database.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() {
    return _instance;
  }
  AdminService._internal();

  final _db = FirebaseDatabase.instance.ref();

  Future<bool> isAdmin(String email) async {
    try {
      final snapshot = await _db.child('Admins').child(email).once();
      return snapshot.snapshot.exists;
    } catch (e) {
      return false;
    }
  }
}