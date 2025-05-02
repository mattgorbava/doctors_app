import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/model/registration_request.dart';
import 'package:doctors_app/services/patient_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationRequestCard extends StatelessWidget {
  RegistrationRequestCard({super.key, required this.request});

  final RegistrationRequest request;

  final PatientService _patientService = PatientService();

  Future<String> _getPatientName(String patientId) async {
    try {
      Patient patient = await _patientService.getPatientById(patientId) ?? Patient.empty();
      if (patient.isEmpty) {
        return 'Unknown Patient';
      }
      return '${patient.firstName} ${patient.lastName}';
    } catch (e) {
      return 'Error fetching patient name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 196, 255, 209)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(2),
        child: FutureBuilder<String>(
          future: _getPatientName(request.patientId!),
          builder: (context, snapshot) {
            final patientName = snapshot.connectionState == ConnectionState.done
              ? (snapshot.hasData ? snapshot.data! : "Unknown Patient")
              : "Loading...";
            return ListTile(
              title: Text(
                patientName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Status: ${request.status}\nDate of request: ${DateFormat('dd.MM.yyyy').format(request.createdAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: request.status == 'pending' ? Colors.orange 
                  : request.status == 'confirmed' ? Colors.green
                  : Colors.red,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}