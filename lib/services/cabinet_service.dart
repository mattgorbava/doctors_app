import 'package:doctors_app/model/cabinet.dart';
import 'package:firebase_database/firebase_database.dart';

class CabinetService {
  static final CabinetService _instance = CabinetService._internal();
  factory CabinetService() {
    return _instance;
  }
  CabinetService._internal();

  final DatabaseReference _cabinetRef = FirebaseDatabase.instance.ref().child('Cabinets');

  Future<Cabinet> getCabinetById(String id) async {
    final snapshot = await _cabinetRef.child(id).once();
    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      return Cabinet.fromMap(Map<String, dynamic>.from(data), id);
    }
    throw Exception('Cabinet not found');
  }

  Future<Cabinet> getCabinetByDoctorId(String doctorId) async {
    final snapshot = await _cabinetRef.orderByChild('doctorId').equalTo(doctorId).once();
    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      return Cabinet.fromMap(Map<String, dynamic>.from(data), snapshot.snapshot.key!);
    }
    throw Exception('Cabinet not found for this doctor');
  }

  Future<void> addCabinet(Cabinet cabinet) async {
    try {
      await _cabinetRef.push().set(cabinet.toMap());
    } catch (e) {
      print('Error adding cabinet: $e');
    }
  }

  Future<void> updateCabinet(Cabinet cabinet) async {
    try {
      await _cabinetRef.child(cabinet.uid).update(cabinet.toMap());
    } catch (e) {
      print('Error updating cabinet: $e');
    }
  }

  Future<void> deleteCabinet(String id) async {
    try {
      await _cabinetRef.child(id).remove();
    } catch (e) {
      print('Error deleting cabinet: $e');
    }
  }
}