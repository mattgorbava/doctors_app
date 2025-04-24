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

  Patient? _patient;
  Cabinet? _cabinet;
  Doctor? _doctor;
  bool _isDataLoaded = false;

  Patient? get patient => _patient;
  Cabinet? get cabinet => _cabinet;
  Doctor? get doctor => _doctor;
  bool get isDataLoaded => _isDataLoaded;

  Future<void> loadPatientData() async {
    if (_isDataLoaded) return;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _loadPatient(userId);
      
      if (_patient != null && _patient!.cabinetId != null && _patient!.cabinetId!.isNotEmpty) {
        await _loadCabinet(_patient!.cabinetId!);
        if (_cabinet != null && _cabinet!.doctorId.isNotEmpty) {
          await _loadDoctor(_cabinet!.doctorId);
        }
      }
      
      _isDataLoaded = true;
    } catch (e) {
      print('Error loading patient data: $e');
    }
  }

  Future<void> _loadPatient(String userId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('Patients')
        .child(userId)
        .once();
    
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      _patient = Patient.fromMap(
        Map<String, dynamic>.from(data), 
        snapshot.snapshot.key!
      );
    }
  }
  
  Future<void> _loadCabinet(String cabinetId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('Cabinets')
        .child(cabinetId)
        .once();
    
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      _cabinet = Cabinet.fromMap(
        Map<String, dynamic>.from(data), 
        snapshot.snapshot.key!
      );
    }
  }
  
  Future<void> _loadDoctor(String doctorId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('Doctors')
        .child(doctorId)
        .once();
    
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      _doctor = Doctor.fromMap(
        Map<String, dynamic>.from(data), 
        snapshot.snapshot.key!
      );
    }
  }
  
  void clearData() {
    _patient = null;
    _cabinet = null;
    _doctor = null;
    _isDataLoaded = false;
  }
}