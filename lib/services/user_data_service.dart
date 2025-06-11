import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() {
    return _instance;
  }
  UserDataService._internal();

  var logger = Logger();

  Patient? patient;
  List<Booking>? patientBookings;
  List<Patient>? children;
  Cabinet? cabinet;
  List<Cabinet>? cabinets;
  Doctor? doctor;
  List<Patient>? doctorPatients;
  bool isDataLoaded = false;
  bool isPatient = false;

  Future<void> loadPatientData() async {
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _loadPatient(userId);
      
      if (patient != null) {
        if (patient!.cabinetId.isNotEmpty) {
          await _loadCabinet(patient!.cabinetId);
        }
        if (cabinet != null && cabinet!.doctorId.isNotEmpty) {
          await _loadDoctor(cabinet!.doctorId);
        }
        await _loadBookings(userId);
        await loadChildren(userId);
        await loadCabinets();
      }

      isDataLoaded = true;
      isPatient = true;
    } catch (e) {
      logger.e('Error loading patient data: $e');
    }
  }

  Future<void> loadDoctorData() async {
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _loadDoctor(userId);
      
      if (doctor != null && doctor!.cabinetId != null && doctor!.cabinetId!.isNotEmpty) {
        await _loadCabinet(doctor!.cabinetId!);
        if (cabinet != null) {
          await loadPatients(cabinet!.uid);
        }
      }
      
      isDataLoaded = true;
    } catch (e) {
      logger.e('Error loading doctor data: $e');
    }
  }

  Future<void> loadChildren(String userId) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('Patients')
        .orderByChild('parentId')
        .equalTo(userId)
        .once();
    
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      List<Patient> childrenList = [];
      data.forEach((key, value) {
        childrenList.add(Patient.fromMap(
          Map<String, dynamic>.from(value), 
          key
        ));
      });
      if (childrenList.isNotEmpty) {
        children = childrenList;
      }
    }
  }

  Future<void> loadCabinets() async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('Cabinets')
        .once();
    
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      List<Cabinet> cabinetsList = [];
      data.forEach((key, value) {
        cabinetsList.add(Cabinet.fromMap(
          Map<String, dynamic>.from(value), 
          key
        ));
      });
      if (cabinetsList.isNotEmpty) {
        cabinets = cabinetsList;
      }
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
      patient = Patient.fromMap(
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
      cabinet = Cabinet.fromMap(
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
        doctor = Doctor.fromMap(
          Map<String, dynamic>.from(data), 
          snapshot.snapshot.key!
        );
      }
    } catch (e) {
      logger.e('Error loading doctor data: $e');
    }
  }

  Future<void> loadPatients(String cabinetId) async {
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
      if (patients.isNotEmpty) {
        doctorPatients = patients;
      }
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
      if (bookings.isNotEmpty) {
        patientBookings = bookings;
      }
    }
  }
  
  void clearUserData() {
    patient = null;
    cabinet = null;
    doctor = null;
    doctorPatients = null;
    patientBookings = null;
    children = [];
    isDataLoaded = false;
    isPatient = false;
    cabinets = [];
  }
}