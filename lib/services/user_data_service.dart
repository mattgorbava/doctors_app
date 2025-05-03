import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/child.dart';
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
  List<Booking>? _patientBookings;
  List<Child> _children = [];
  Cabinet? _cabinet;
  Doctor? _doctor;
  List<Patient>? _doctorPatients;
  bool _isDataLoaded = false;

  Patient? get patient => _patient;
  List<Booking>? get patientBookings => _patientBookings;
  Cabinet? get cabinet => _cabinet;
  Doctor? get doctor => _doctor;
  List<Patient>? get doctorPatients => _doctorPatients;
  bool get isDataLoaded => _isDataLoaded;
  List<Child> get children => _children;

  set patient(Patient? value) {
    _patient = value;
  }
  set cabinet(Cabinet? value) {
    _cabinet = value;
  }
  set doctor(Doctor? value) {
    _doctor = value;
  }
  set doctorPatients(List<Patient>? value) {
    _doctorPatients = value;
  }
  set patientBookings(List<Booking>? value) {
    _patientBookings = value;
  }
  set children(List<Child> value) {
    _children = value;
  }
  

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
        await _loadBookings(userId);
        await loadChildren(userId);
      }
      
      _isDataLoaded = true;
    } catch (e) {
      print('Error loading patient data: $e');
    }
  }

  Future<void> loadDoctorData() async {
    if (_isDataLoaded) return;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _loadDoctor(userId);
      
      if (_doctor != null && _doctor!.cabinetId != null && _doctor!.cabinetId!.isNotEmpty) {
        await _loadCabinet(_doctor!.cabinetId!);
        if (_cabinet != null) {
          await _loadPatients(_cabinet!.uid);
        }
      }
      
      _isDataLoaded = true;
    } catch (e) {
      print('Error loading doctor data: $e');
    }
  }

  Future<void> loadChildren(String userId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('Children')
        .orderByChild('parentId')
        .equalTo(userId)
        .once();
    
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      List<Child> children = [];
      data.forEach((key, value) {
        children.add(Child.fromMap(
          Map<String, dynamic>.from(value), 
          key
        ));
      });
      _children = children;
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
    try {
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
    } catch (e) {
      print('Error loading doctor data: $e');
    }
  }

  Future<void> _loadPatients(String cabinetId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('Patients')
        .orderByChild('cabinetId')
        .equalTo(cabinetId)
        .once();
    
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      List<Patient> patients = [];
      data.forEach((key, value) {
        patients.add(Patient.fromMap(
          Map<String, dynamic>.from(value), 
          key
        ));
      });
      _doctorPatients = patients;
    }
  }

  Future<void> _loadBookings(String userId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('Bookings')
        .orderByChild('patientId')
        .equalTo(userId)
        .once();
    
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      List<Booking> bookings = [];
      data.forEach((key, value) {
        bookings.add(Booking.fromMap(
          Map<String, dynamic>.from(value), 
          key
        ));
      });
      _patientBookings = bookings;
    }
  }
  
  void clearUserData() {
    _patient = null;
    _cabinet = null;
    _doctor = null;
    _doctorPatients = null;
    _patientBookings = null;
    _children = [];
    _isDataLoaded = false;
  }
}