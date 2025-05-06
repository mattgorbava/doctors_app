import 'package:doctors_app/model/child.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/model/registration_request.dart';
import 'package:doctors_app/services/children_service.dart';
import 'package:doctors_app/services/patient_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationRequestCard extends StatefulWidget {
  const RegistrationRequestCard({super.key, required this.request});

  final RegistrationRequest request;

  @override
  State<RegistrationRequestCard> createState() => _RegistrationRequestCardState();
}

class _RegistrationRequestCardState extends State<RegistrationRequestCard> {
  final PatientService _patientService = PatientService();

  Patient? patient;

  late Future<void> _dataFuture;

  Future<void> _getPatient() async {
    patient = await _patientService.getPatientById(widget.request.patientId!);
  }

  @override
  void initState() {
    super.initState();
    _dataFuture = _getPatient();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _dataFuture,
      builder: (context, snapshot) {
        Widget content;

        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const ListTile(
            title: Text('Loading...'),
            subtitle: Text('Please wait'),
            leading: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          content = ListTile(
            title: const Text('Error Loading Data', style: TextStyle(color: Colors.red)),
            subtitle: Text('${snapshot.error}'),
            leading: const Icon(Icons.error, color: Colors.red),
          );
        } else {
          if (patient == null) {
             content = const ListTile(
                title: Text('Error: Patient data missing', style: TextStyle(color: Colors.red)),
                leading: Icon(Icons.error, color: Colors.red),
             );
          } else {
             content = ListTile(
                title: Text(
                  '${patient!.firstName} ${patient!.lastName}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Status: ${widget.request.status}\nDate of request: ${DateFormat('dd.MM.yyyy').format(widget.request.createdAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: widget.request.status == 'pending' ? Colors.orange
                    : widget.request.status == 'confirmed' ? Colors.green
                    : Colors.red,
                  ),
                ),
             );
          }
        }

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
            child: content,
          ),
        );
      },
    );
  }
}