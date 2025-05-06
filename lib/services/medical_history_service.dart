import 'package:doctors_app/model/medical_history.dart';
import 'package:firebase_database/firebase_database.dart';

class MedicalHistoryService {
  static final MedicalHistoryService _instance = MedicalHistoryService._internal();
  factory MedicalHistoryService() {
    return _instance;
  }
  MedicalHistoryService._internal();

  final DatabaseReference _medicalHistoryRef = FirebaseDatabase.instance.ref().child('MedicalHistory');

  Future<List<MedicalHistory>> getAllMedicalHistoryByPatientId(String patientId) async {
    List<MedicalHistory> medicalHistories = [];
    try {
      final snapshot = await _medicalHistoryRef.orderByChild('patientId').equalTo(patientId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          medicalHistories.add(MedicalHistory.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      print('Error fetching medical histories: $e');
    }
    return medicalHistories;
  }

  Future<List<MedicalHistory>> getBookingHistory(String bookingId) async {
    List<MedicalHistory> medicalHistories = [];
    try {
      final snapshot = await _medicalHistoryRef.orderByChild('bookingId').equalTo(bookingId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          medicalHistories.add(MedicalHistory.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      print('Error fetching booking histories: $e');
    }
    return medicalHistories;
  }

  Future<void> addMedicalHistory(MedicalHistory medicalHistory) async {
    try {
      await _medicalHistoryRef.push().set(medicalHistory.toMap());
    } catch (e) {
      print('Error adding medical history: $e');
    }
  }

  Future<void> updateMedicalHistory(MedicalHistory medicalHistory) async {
    try {
      await _medicalHistoryRef.child(medicalHistory.id).update(medicalHistory.toMap());
    } catch (e) {
      print('Error updating medical history: $e');
    }
  }

  Future<void> deleteMedicalHistory(String id) async {
    try {
      await _medicalHistoryRef.child(id).remove();
    } catch (e) {
      print('Error deleting medical history: $e');
    }
  }
}