import 'package:doctors_app/model/patient.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class PatientService {
  static final PatientService _instance = PatientService._internal();
  factory PatientService() {
    return _instance;
  }
  PatientService._internal();

  var logger = Logger();

  late DatabaseReference _patientRef = FirebaseDatabase.instance.ref().child('Patients');

  PatientService.withDbRef({required DatabaseReference patientRef}) {
    _patientRef = patientRef;
  }

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
      logger.e('Error fetching patients: $e');
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

  Future<bool> checkUniqueCnp(String cnp) async {
    try {
      final snapshot = await _patientRef.orderByChild('cnp').equalTo(cnp).once();
      return !snapshot.snapshot.exists;
    } catch (e) {
      logger.e('Error checking unique CNP: $e');
      return false;
    }
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
      logger.e('Error fetching patients by cabinet ID: $e');
    }
    return patients;
  }

  Future<List<Patient>> getChildrenByParentId(String parentId) async {
    List<Patient> patients = [];
    try {
      final snapshot = await _patientRef.orderByChild('parentId').equalTo(parentId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          patients.add(Patient.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      logger.e('Error fetching patients by parent ID: $e');
    }
    return patients;
  }

  Future<void> addPatient(Map<String, dynamic> patientData) async {
    try {
      String patientId = _patientRef.push().key!;
      await _patientRef.child(patientId).set(patientData);
    } catch (e) {
      logger.e('Error adding patient: $e');
    }
  }

  Future<void> updatePatient(Patient patient) async {
    try {
      await _patientRef.child(patient.uid).update(patient.toMap());
    } catch (e) {
      logger.e('Error updating patient: $e');
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      await _patientRef.child(id).remove();
    } catch (e) {
      logger.e('Error deleting patient: $e');
    }
  }

  Future<void> updateCabinet(String patientId, String cabinetId) async {
    try {
      await _patientRef.child(patientId).update({'cabinetId': cabinetId});
    } catch (e) {
      logger.e('Error updating cabinet: $e');
    }
  }

  Future<bool> isPatient(String id) async {
    try {
      final snapshot = await _patientRef.child(id).once();
      return snapshot.snapshot.exists;
    } catch (e) {
      logger.e('Error checking if patient exists: $e');
      return false;
    }
  }

  Future<void> updatePatientEmergencyStatus(String patientId, bool hasEmergency, [String symptoms = '']) async {
    try {
      await _patientRef.child(patientId).update(
        {
          'hasEmergency': hasEmergency,
          'emergencySymptoms': symptoms,
        }
      );
    } catch (e) {
      logger.e('Error updating patient emergency status: $e');
    }
  }
}