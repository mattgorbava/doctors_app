import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/model/registration_request.dart';
import 'package:doctors_app/services/cabinet_service.dart';
import 'package:doctors_app/services/patient_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationRequestDetailsPage extends StatefulWidget {
  const RegistrationRequestDetailsPage({super.key, required this.request});

  final RegistrationRequest request;

  @override
  State<RegistrationRequestDetailsPage> createState() => _RegistrationRequestDetailsPageState();
}

class _RegistrationRequestDetailsPageState extends State<RegistrationRequestDetailsPage> {
  Patient? _patient;
  Cabinet? _cabinet;
  bool _isLoading = true;
  final PatientService _patientService = PatientService();
  final CabinetService _cabinetService = CabinetService();

  Future<void> _fetchPatient() async {
    try {
      Patient patient = await _patientService.getPatientById(widget.request.patientId) ?? Patient.empty();
      if (patient.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No patient details available.'),
          ),
        );
      } else {
        setState(() {
          _patient = patient;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch patient details. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCabinet() async {
    try {
      Cabinet cabinet = await _cabinetService.getCabinetById(_patient!.cabinetId) ?? Cabinet.empty();
      if (cabinet.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No cabinet details available.'),
          ),
        );
      } else {
        setState(() {
          _cabinet = cabinet;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch cabinet details. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest() async {
    DatabaseReference registrationRequestRef = FirebaseDatabase.instance.ref().child('RegistrationRequests').child(widget.request.uid!);
    DatabaseReference patientsRef = FirebaseDatabase.instance.ref().child('Patients').child(widget.request.patientId!);
    DatabaseReference cabinetsRef = FirebaseDatabase.instance.ref().child('Cabinets').child(_cabinet!.uid!);
    try {
      await registrationRequestRef.update({
        'status': 'confirmed',
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await patientsRef.update({
        'cabinetId': _cabinet!.uid,
      });
      await cabinetsRef.update({
        'numberOfPatients': _cabinet!.numberOfPatients + 1,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration request accepted successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept registration request. Please try again later.'),
        ),
      );
    }
  }

  Future<void> _rejectRequest() async {
    DatabaseReference registrationRequestRef = FirebaseDatabase.instance.ref().child('RegistrationRequests').child(widget.request.uid!);
    try {
      await registrationRequestRef.update({
        'status': 'rejected',
        'updatedAt': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration request rejected successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject registration request. Please try again later.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPatient();
    _fetchCabinet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Request Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patient != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient Name: ${_patient!.firstName} ${_patient!.lastName}'),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _patient!.profileImageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Patient Phone: ${_patient!.phoneNumber}'),
                      const SizedBox(height: 8),
                      Text('Request Status: ${widget.request.status}'),
                      const SizedBox(height: 8),
                      Text('Request Date: ${DateFormat('dd.MM.yyyy').format(widget.request.createdAt!)}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 0.35 * MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                _acceptRequest();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Accept Request'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 0.35 * MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                _rejectRequest();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Reject Request'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              : const Center(child: Text('No patient details available')),
    );
  }
}