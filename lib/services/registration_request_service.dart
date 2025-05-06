import 'package:doctors_app/model/registration_request.dart';
import 'package:firebase_database/firebase_database.dart';

class RegistrationRequestService {
  static final RegistrationRequestService _instance = RegistrationRequestService._internal();
  factory RegistrationRequestService() {
    return _instance;
  }
  RegistrationRequestService._internal();

  final DatabaseReference _registrationRequestRef = FirebaseDatabase.instance.ref().child('RegistrationRequests');

  Future<List<RegistrationRequest>> getAllRequestsByDoctorId(String doctorId) async {
    List<RegistrationRequest> requests = [];
    try {
      final snapshot = await _registrationRequestRef.orderByChild('doctorId').equalTo(doctorId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          requests.add(RegistrationRequest.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      print('Error fetching registration requests: $e');
    }
    return requests;
  }

  Future<void> addRequest(RegistrationRequest request) async {
    try {
      await _registrationRequestRef.push().set(request.toMap());
    } catch (e) {
      print('Error adding registration request: $e');
    }
  }

  Future<void> updateRequest(RegistrationRequest request) async {
    try {
      await _registrationRequestRef.child(request.uid).update(request.toMap());
    } catch (e) {
      print('Error updating registration request: $e');
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      await _registrationRequestRef.child(id).remove();
    } catch (e) {
      print('Error deleting registration request: $e');
    }
  }

  Future<void> acceptRequest(String id) async {
    try {
      await _registrationRequestRef.child(id).update({'status': 'confirmed', 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Error accepting registration request: $e');
    }
  }
}