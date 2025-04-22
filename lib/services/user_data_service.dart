import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() {
    return _instance;
  }
  UserDataService._internal();

  Patient? patient;
  Cabinet? cabinet;
  Doctor? doctor;
  bool isLoading = true;

  Future<void> loadPatientData() async {
    isLoading = true;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final patientSnapshot = await FirebaseDatabase.instance
          .ref()
          .child('Patients')
          .child(userId)
          .once();
      
      if (patientSnapshot.snapshot.value != null) {
        final patientData = patientSnapshot.snapshot.value as Map<dynamic, dynamic>;
        patient = Patient.fromMap(Map<String, dynamic>.from(patientData), userId);
        
        if (patient?.cabinetId != null) {
          final cabinetSnapshot = await FirebaseDatabase.instance
              .ref()
              .child('Cabinets')
              .child(patient!.cabinetId)
              .once();
              
          if (cabinetSnapshot.snapshot.value != null) {
            final cabinetData = cabinetSnapshot.snapshot.value as Map<dynamic, dynamic>;
            cabinet = Cabinet.fromMap(Map<String, dynamic>.from(cabinetData), patient!.cabinetId);
            
            final doctorSnapshot = await FirebaseDatabase.instance
                .ref()
                .child('Doctors')
                .child(cabinet!.doctorId)
                .once();
                  
            if (doctorSnapshot.snapshot.value != null) {
              final doctorData = doctorSnapshot.snapshot.value as Map<dynamic, dynamic>;
              doctor = Doctor.fromMap(Map<String, dynamic>.from(doctorData), cabinet!.doctorId);
            }
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading = false;
    }
  }

  void clearData() {
    patient = null;
    cabinet = null;
    doctor = null;
    isLoading = false;
  }
}