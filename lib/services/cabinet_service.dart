import 'package:doctors_app/model/cabinet.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class CabinetService {
  static final CabinetService _instance = CabinetService._internal();
  factory CabinetService() {
    return _instance;
  }
  CabinetService._internal();

  var logger = Logger();

  late DatabaseReference _cabinetRef = FirebaseDatabase.instance.ref().child('Cabinets');
  
  CabinetService.withDbRef({DatabaseReference? cabinetRef}) {
    _cabinetRef = cabinetRef ?? FirebaseDatabase.instance.ref().child('Cabinets');
  }

  Future<Cabinet> getCabinetById(String id) async {
    if (id.isEmpty) {
      return Cabinet.empty();
    }
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
      return Cabinet.fromMap(Map<String, dynamic>.from(data.entries.first.value), data.keys.first);
    }
    throw Exception('Cabinet not found for this doctor');
  }

  Future<List<Cabinet>> getAllCabinets() async {
    List<Cabinet> cabinets = [];
    try {
      final snapshot = await _cabinetRef.once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          cabinets.add(Cabinet.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      logger.e('Error fetching cabinets: $e');
    }
    return cabinets;
  }

  Future<String> addCabinet(Cabinet cabinet) async {
    String? key;
    try {
      key = _cabinetRef.push().key;
      if (key == null) {
        throw Exception('Failed to generate a unique key for the cabinet');
      }
      cabinet.uid = key;
      await _cabinetRef.child(key).set(cabinet.toMap());
    } catch (e) {
      logger.e('Error adding cabinet: $e');
    }
    return key ?? '';
  }

  Future<void> updateCabinet(Cabinet cabinet) async {
    try {
      await _cabinetRef.child(cabinet.uid).update(cabinet.toMap());
    } catch (e) {
      logger.e('Error updating cabinet: $e');
    }
  }

  Future<void> deleteCabinet(String id) async {
    try {
      await _cabinetRef.child(id).remove();
    } catch (e) {
      logger.e('Error deleting cabinet: $e');
    }
  }

  Future<void> incrementPatientsCount(String cabinetId, int newAmount) async {
    try {
      await _cabinetRef.child(cabinetId).child('numberOfPatients').set(newAmount);
    } catch (e) {
      logger.e('Error incrementing patients count: $e');
    }
  }

  Future<void> decrementPatientsCount(String cabinetId, int newAmount) async {
    try {
      await _cabinetRef.child(cabinetId).child('numberOfPatients').set(newAmount);
    } catch (e) {
      logger.e('Error decrementing patients count: $e');
    }
  }
}