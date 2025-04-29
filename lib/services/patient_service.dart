import 'package:doctors_app/model/patient.dart';
import 'package:firebase_database/firebase_database.dart';

class PatientService {
  static final PatientService _instance = PatientService._internal();
  factory PatientService() {
    return _instance;
  }
  PatientService._internal();

  final DatabaseReference _patientRef = FirebaseDatabase.instance.ref().child('Patients');

  Future<List<Patient>> getAllPatients() async {
    List<Patient> patients = [];
    try {
      final snapshot = await _patientRef.once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          patients.add(Patient.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
    return patients;
  }

  Future<Patient?> getPatientById(String id) async {
    final snapshot = await _patientRef.child(id).once();
    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      return Patient.fromMap(Map<String, dynamic>.from(data), id);
    }
    return null;
  }

  Future<List<Patient>> getPatientsByCabinetId(String cabinetId) async {
    List<Patient> patients = [];
    try {
      final snapshot = await _patientRef.orderByChild('cabinetId').equalTo(cabinetId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          patients.add(Patient.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      print('Error fetching patients by cabinet ID: $e');
    }
    return patients;
  }

  Future<void> addPatient(Patient patient) async {
    try {
      await _patientRef.push().set(patient.toMap());
    } catch (e) {
      print('Error adding patient: $e');
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      await _patientRef.child(patient.uid).update(patient.toMap());
    } catch (e) {
      print('Error updating patient: $e');
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      await _patientRef.child(id).remove();
    } catch (e) {
      print('Error deleting patient: $e');
    }
  }
}