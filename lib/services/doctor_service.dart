import 'package:doctors_app/model/doctor.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class DoctorService {
  static final DoctorService _instance = DoctorService._internal();
  factory DoctorService() {
    return _instance;
  }
  DoctorService._internal();

  var logger = Logger();

  late DatabaseReference _doctorRef = FirebaseDatabase.instance.ref().child('Doctors');

  DoctorService.withDbRef({DatabaseReference? doctorRef}) {
    _doctorRef = doctorRef ?? FirebaseDatabase.instance.ref().child('Doctors');
  }

  Future<List<Doctor>> getAllDoctors() async {
    List<Doctor> doctors = [];
    try {
      final snapshot = await _doctorRef.once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          doctors.add(Doctor.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      logger.e('Error fetching doctors: $e');
    }
    return doctors;
  }

  Future<void> updateCabinetIdForDoctor(String doctorId, String cabinetId) async {
    try {
      await _doctorRef.child(doctorId).update({'cabinetId': cabinetId});
    } catch (e) {
      logger.e('Error updating cabinet ID for doctor: $e');
    }
  }

  Future<Doctor> getDoctorById(String id) async {
    try {
      final snapshot = await _doctorRef.child(id).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        return Doctor.fromMap(Map<String, dynamic>.from(data), id);
      }
    } catch (e) {
      logger.e('Error fetching doctor by ID: $e');
    }
    return Doctor.empty();
  }

  Future<void> addDoctor(Doctor doctor) async {
    try {
      await _doctorRef.push().set(doctor.toMap());
    } catch (e) {
      logger.e('Error adding doctor: $e');
    }
  }

  Future<void> updateDoctor(Doctor doctor) async {
    try {
      await _doctorRef.child(doctor.uid).update(doctor.toMap());
    } catch (e) {
      logger.e('Error updating doctor: $e');
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      await _doctorRef.child(id).remove();
    } catch (e) {
      logger.e('Error deleting doctor: $e');
    }
  }

  Future<Doctor> getDoctorByCabinetId(String cabinetId) async {
    try {
      final snapshot = await _doctorRef.orderByChild('cabinetId').equalTo(cabinetId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        return Doctor.fromMap(Map<String, dynamic>.from(data.entries.first.value), data.keys.first);
      }
    } catch (e) {
      logger.e('Error fetching doctor by cabinet ID: $e');
    }
    throw Exception('Doctor not found for this cabinet');
  }
}