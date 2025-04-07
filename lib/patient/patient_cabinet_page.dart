import 'package:doctors_app/patient/book_appointment_page.dart';
import 'package:doctors_app/patient/find_cabinet_page.dart';
import 'package:doctors_app/chat_screen.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doctors_app/doctor/doctor_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientCabinetPage extends StatefulWidget {
  const PatientCabinetPage({Key? key, required this.cabinets}) : super(key: key);

  final List<Cabinet> cabinets;

  @override
  State<PatientCabinetPage> createState() => _PatientCabinetPageState();
}

class _PatientCabinetPageState extends State<PatientCabinetPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Cabinet? _cabinet;
  Patient? _patient;
  Doctor? _doctor;
  bool _isLoading = true;

  Future<void> _fetchPatientCabinetAndDoctor() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      Cabinet? cabinet;
      Patient? patient;
      Doctor? doctor;
      final snapshot = await FirebaseDatabase.instance.ref().child('Patients').child(currentUserId).once();
      if (snapshot.snapshot.value != null) {
        final patientValues = snapshot.snapshot.value as Map<dynamic, dynamic>;
        patient = Patient.fromMap(Map<String, dynamic>.from(patientValues), currentUserId);
      }

      for (Cabinet cab in widget.cabinets) {
        if (cab.uid == patient!.cabinetId) {
          cabinet = cab;
          break;
        }
      }

      if (cabinet != null)
      {
        final doctorSnapshot = await FirebaseDatabase.instance.ref().child('Doctors').child(cabinet!.doctorId).once();
        if (doctorSnapshot.snapshot.value != null) {
          final doctorValues = doctorSnapshot.snapshot.value as Map<dynamic, dynamic>;
          doctor = Doctor.fromMap(Map<String, dynamic>.from(doctorValues), cabinet.doctorId);
        }
      }

      setState(() {
        _cabinet = cabinet;
        _patient = patient;
        _doctor = doctor;
        _isLoading = false;
      });
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneCall = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneCall)) {
        await launchUrl(phoneCall);
      } else {
        throw 'Could not call $phoneCall';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not call $phoneNumber'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    _fetchPatientCabinetAndDoctor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cabinet', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),)
      : _cabinet == null ? Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You haven\'t registered\nto any cabinet yet.', 
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 0.5 * MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: () { 
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => FindCabinetPage(cabinets: widget.cabinets)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B962B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white),),
              ),
            ),
          ],
        ),
      )
      : Column(
        children: [
          ListTile(
            title: Text('Cabinet Name: ${_cabinet!.name}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
            subtitle: Text('Address: ${_cabinet!.address}', style: GoogleFonts.poppins(fontSize: 14),),
          ),
          ListTile(
            title: Text('Doctor: ${_doctor!.firstName} ${_doctor!.lastName}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
            subtitle: SizedBox(
              width: 0.5 * MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () { 
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorProfile(doctorId: _doctor!.uid)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B962B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('View Profile', style: TextStyle(fontSize: 16, color: Colors.white),),
              ),
            ),
          ),
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 0.4 * MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B962B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        _makePhoneCall(_doctor!.phoneNumber);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.white, size: 20),
                          const SizedBox(width: 10,),
                          Text(
                            'Call',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
                          ),
                        ],
                      )
                    ),
                  ),
                  SizedBox(
                    width: 0.4 * MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B962B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        String currentUserName = '${_patient!.firstName} ${_patient!.lastName}';
                        String doctorName = '${_doctor!.firstName} ${_doctor!.lastName}';
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatScreen(
                            patientName: currentUserName, patientId: _patient!.uid, doctorName: doctorName, doctorId:_doctor!.uid,)),
                        );
                      }, 
                      child: Row(
                        children: [
                          const Icon(Icons.message, color: Colors.white, size: 20),
                          const SizedBox(width: 10,),
                          Text(
                            'Message',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
                          ),
                        ],
                      )
                    ),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            width: 0.6 * MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B962B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookAppointmentPage(patient: _patient!, cabinet: _cabinet!)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  const SizedBox(width: 10,),
                  Text(
                    'Book Appointment',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
                  ),
                ],
              ),
            )
          )
        ],
      ) 
    );
  }
}