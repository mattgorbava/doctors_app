import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/model/registration_request.dart';
import 'package:doctors_app/services/cabinet_service.dart';
import 'package:doctors_app/services/patient_service.dart';
import 'package:doctors_app/services/registration_request_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
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
  final RegistrationRequestService _registrationRequestService = RegistrationRequestService();
  final UserDataService _userDataService = UserDataService();

  Future<void> _fetchPatient() async {
    try {
      Patient patient = await _patientService.getPatientById(widget.request.patientId) ?? Patient.empty();
      if (patient.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleData.noPatientDetailsAvailable.getString(context)),
          ),
        );
      } else {
        setState(() {
          _patient = patient;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleData.failedToFetchPatientDetails.getString(context)),
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
      Cabinet? cabinet = _userDataService.cabinet;
      if (cabinet!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleData.noCabinetDetailsAvailable.getString(context)),
          ),
        );
      } else {
        setState(() {
          _cabinet = cabinet;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleData.failedToFetchCabinetDetails.getString(context)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest() async {
    try {
      await _patientService.updateCabinet(_patient!.uid, _cabinet!.uid);
      await _cabinetService.incrementPatientsCount(_cabinet!.uid, _cabinet!.numberOfPatients + 1);
      await _registrationRequestService.acceptRequest(widget.request.uid);
      await _userDataService.loadPatients(_userDataService.cabinet!.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleData.requestAcceptedSuccess.getString(context)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleData.failedToAcceptRequest.getString(context)),
        ),
      );
    }
  }

  Future<void> _rejectRequest() async {
    DatabaseReference registrationRequestRef = FirebaseDatabase.instance.ref().child('RegistrationRequests').child(widget.request.uid);
    try {
      await registrationRequestRef.update({
        'status': 'rejected',
        'updatedAt': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleData.requestRejectedSuccess.getString(context)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleData.failedToRejectRequest.getString(context)),
        ),
      );
    }
  }

  Future<void> _getData() async {
    await _fetchPatient();
    await _fetchCabinet();
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.registrationRequestDetailsTitle.getString(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patient != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${LocaleData.patientName.getString(context)}: ${_patient!.firstName} ${_patient!.lastName}'),
                      const SizedBox(height: 8),
                      _patient!.profileImageUrl.isNotEmpty 
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _patient!.profileImageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                      : const Icon(Icons.person, size: 100),
                      const SizedBox(height: 8),
                      _patient!.phoneNumber.isNotEmpty 
                      ? Text('${LocaleData.patientPhone.getString(context)}: ${_patient!.phoneNumber}')
                      : Text('${LocaleData.patientPhone.getString(context)}: ${LocaleData.noPatientDetailsAvailable.getString(context)}'), // Or a more specific "not available"
                      const SizedBox(height: 8),
                      Text('${LocaleData.requestStatusLabel.getString(context)}${widget.request.status}'),
                      const SizedBox(height: 8),
                      Text('${LocaleData.dateOfRequest.getString(context)}: ${DateFormat('dd.MM.yyyy').format(widget.request.createdAt)}'),
                      const SizedBox(height: 8),
                      widget.request.status == 'pending' 
                      ? Row(
                        children: [
                          SizedBox(
                            width: 0.35 * MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                _acceptRequest();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(LocaleData.accept.getString(context), style: const TextStyle(color: Colors.white)), // Added text color
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
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                                child: Text(LocaleData.reject.getString(context), style: const TextStyle(color: Colors.white)), // Added text color
                            ),
                          ),
                        ],
                      ) : const SizedBox.shrink(),
                    ],
                  ),
                )
              : const Center(child: Text('No patient details available')),
    );
  }
}