import 'package:doctors_app/chat_screen.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CabinetDetailsPage extends StatefulWidget {
  const CabinetDetailsPage({super.key, required this.cabinet});

  final Cabinet cabinet;

  @override
  State<CabinetDetailsPage> createState() => _CabinetDetailsPageState();
}

class _CabinetDetailsPageState extends State<CabinetDetailsPage> {
  Doctor? _doctor;

  @override
  void initState() {
    super.initState();
    _fetchDoctor();
  }
  
  Future<void> _fetchDoctor() async {
    final snapshot = await FirebaseDatabase.instance.ref().child('Doctors').child(widget.cabinet.doctorId).once();
    final value = snapshot.snapshot.value as Map<dynamic, dynamic>;
    final doctor = Doctor.fromMap(value, widget.cabinet.doctorId);
    setState(() {
      _doctor = doctor;
    });
  }

  Future<Patient> _fetchPatient(String patientId) async {
    final snapshot = await FirebaseDatabase.instance.ref().child('Patients').child(patientId).once();
    final value = snapshot.snapshot.value as Map<dynamic, dynamic>;
    return Patient.fromMap(Map<String, dynamic>.from(value), patientId);
  }

  Future<void> _sendRegistrationRequest() async {
    _fetchDoctor();
    Map<String, dynamic> data = {
      'patientId': FirebaseAuth.instance.currentUser!.uid,
      'doctorId': widget.cabinet.doctorId,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    try {
      await FirebaseDatabase.instance.ref().child('RegistrationRequests').push().set(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration request sent successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send registration request. Please try again later.'),
        ),
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cabinet.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              children: [
                Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    color: const Color(0xffF0EFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: widget.cabinet.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.cabinet.image,
                          fit: BoxFit.fitWidth,
                        ),
                      )
                  : const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
                const SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      widget.cabinet.name,
                      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.cabinet.address,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                  ]
                ),
              ],
            ),
            Text(
              'Rating: ${widget.cabinet.rating}',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            Text(
              'Number of reviews: ${widget.cabinet.totalReviews}',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            Text(
              widget.cabinet.numberOfPatients >= widget.cabinet.capacity
            ? 'Not taking new patients at the moment'
            : 'Accepting new patients',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            if (widget.cabinet.numberOfPatients < widget.cabinet.capacity) ... [
              const SizedBox(height: 20.0,),
              Center(
                child: SizedBox(
                  width: 0.8 * MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                  onPressed: _sendRegistrationRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B962B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Send request to register', style: TextStyle(fontSize: 16, color: Colors.white),),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20.0,),
            Text(
              'Contact doctor',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10.0,),
            Row(
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
                      Patient patient = await _fetchPatient(FirebaseAuth.instance.currentUser!.uid);
                      String currentUserName = '${patient.firstName} ${patient.lastName}';
                      String doctorName = '${_doctor!.firstName} ${_doctor!.lastName}';
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen(
                          patientName: currentUserName, patientId: patient.uid, doctorName: doctorName, doctorId:_doctor!.uid,)),
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
            )
            
          ],
        ),
      ),
    );
  }
}