import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/patient/patient_user_profile.dart';
import 'package:doctors_app/widgets/patient_card.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key, this.emergencies = false});

  final bool emergencies;

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  final UserDataService _userDataService = UserDataService();
  List<Patient> _patients = <Patient>[];

  bool _isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _patients = _userDataService.doctorPatients ?? <Patient>[];
    if (widget.emergencies) {
      _patients = _patients.where((patient) => patient.hasEmergency).toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshPatientsList() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    await _userDataService.loadPatients(_userDataService.doctor?.cabinetId ?? '');
    
    setState(() {
      _patients = _userDataService.doctorPatients ?? <Patient>[];
      
      if (widget.emergencies) {
        _patients = _patients.where((patient) => patient.hasEmergency).toList();
      }
    });
  } catch (e) {
    print('Error refreshing patients list: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to refresh patients list: $e'))
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.emergencies ? LocaleData.emergencies.getString(context) : LocaleData.patientList.getString(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty 
          ? Center(
              child: Text(
                widget.emergencies 
                  ? LocaleData.noEmergenciesFound.getString(context) 
                  : LocaleData.noPatientsFound.getString(context),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context) => PatientUserProfile(patient: _patients[index]),
                      ),
                    );
                    if (result == true) {
                      await _refreshPatientsList();
                    }
                  },
                  child: PatientCard(patient: _patients[index]),
                );
              },
            ),
    );
  }
}