import 'package:doctors_app/widgets/patient_card.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/patient/patient_details_page.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  final UserDataService _userDataService = UserDataService();
  FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _patientsRef = FirebaseDatabase.instance.ref().child('Patients');
  List<Patient> _patients = <Patient>[];

  bool _isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid;
    _patients = _userDataService.doctorPatients ?? <Patient>[];
    // if (_patients.isEmpty) {
    //   _fetchPatients();
    // } 
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchPatients() async {
    if (currentUserId != null) {
      await _patientsRef.orderByChild('doctorId').equalTo(currentUserId).once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        List<Patient> patients = [];

        if (snapshot.value != null) {
          Map<dynamic, dynamic> patientMap = snapshot.value as Map<dynamic, dynamic>;
          patientMap.forEach((key, value) {
            patients.add(Patient.fromMap(Map<String, dynamic>.from(value), key));
          });
        }

        setState(() {
          _patients = patients;
          _isLoading = false;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not get patients.'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
        });
      });
    }
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
                        builder: (context) => PatientDetailsPage(patient: _patients[index]),
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