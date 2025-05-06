import 'package:doctors_app/patient/patient_user_profile.dart';
import 'package:doctors_app/widgets/patient_card.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/patient/patient_details_page.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

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
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context) => PatientUserProfile(patient: _patients[index]),
                      ),
                    );
                  },
                  child: PatientCard(patient: _patients[index]),
                );
              },
            ),
    );
  }
}