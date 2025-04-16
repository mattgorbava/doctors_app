import 'package:doctors_app/model/patient.dart';
import 'package:flutter/material.dart';

class PatientMedicalHistory extends StatefulWidget {
  const PatientMedicalHistory({super.key, required this.patient});

  final Patient patient;

  @override
  State<PatientMedicalHistory> createState() => _PatientMedicalHistoryState();
}

class _PatientMedicalHistoryState extends State<PatientMedicalHistory> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}