import 'dart:convert';

import 'package:doctors_app/model/consultation.dart';
import 'package:flutter/services.dart';

class ConsultationService {
  static final ConsultationService _instance = ConsultationService._internal();
  factory ConsultationService() {
    return _instance;
  }
  ConsultationService._internal();

  Future<List<Consultation>> loadConsultationsByPatientId(String patientId) async {
    String jsonString = await rootBundle.loadString('lib/assets/json/consultations.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    if (jsonData.containsKey('consultations')) {
      List<dynamic> consultationsJson = jsonData['consultations'];
      DateTime now = DateTime.now();
      DateTime date = DateTime.parse(jsonData['patients'][patientId]['birthDate']);
      int patientAgeInMonths = ((now.year - date.year) * 12 + now.month - date.month).toInt();
      consultationsJson = consultationsJson.where((consultation) {
        int ageInMonthsStart = int.parse(consultation['ageInMonthsStart']);
        int ageInMonthsEnd = int.parse(consultation['ageInMonthsEnd']);
        return patientAgeInMonths >= ageInMonthsStart && patientAgeInMonths <= ageInMonthsEnd;
      }).toList();
      return consultationsJson.map((consultation) => Consultation.fromMap(consultation)).toList();
    } else {
      throw Exception('Consultations not found in JSON data');
    } 
  } 
}