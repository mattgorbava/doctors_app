import 'package:doctors_app/chat_screen.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({super.key, required this.patient});

  final Patient patient;

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final UserDataService _userDataService = UserDataService();

  void _makePhoneCall() async {
    final Uri phoneCall = Uri(scheme: 'tel', path: widget.patient.phoneNumber);
    try {
      if (await canLaunchUrl(phoneCall)) {
        await launchUrl(phoneCall);
      } else {
        throw 'Could not call $phoneCall';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not call ${widget.patient.phoneNumber}'),
        backgroundColor: Colors.red,
      ));
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Patient Details'),
    //   ),
    //   body: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Row(
    //           children: [
    //             ClipOval(
    //               child: Image.network(
    //                 widget.patient.profileImageUrl,
    //                 width: 100,
    //                 height: 100,
    //                 fit: BoxFit.cover,
    //               ),
    //             ),
    //             Text('Name: ${widget.patient.firstName} ${widget.patient.lastName}',
    //                 style: const TextStyle(fontSize: 20)),
    //           ],
    //         ),
    //         const SizedBox(height: 10),
    //         Text('Email: ${widget.patient.email}',
    //             style: const TextStyle(fontSize: 20)),
    //         const SizedBox(height: 10),
    //         SizedBox(
    //           width: 0.5 * MediaQuery.of(context).size.width,
    //           child: ElevatedButton(
    //             onPressed: _makePhoneCall,
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: const Color(0xFF2B962B),
    //               padding:
    //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(10),
    //               ),
    //             ),
    //             child: const Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(Icons.phone, color: Colors.white),
    //                 SizedBox(width: 8),
    //                 Text(
    //                   'Call',
    //                   style: TextStyle(fontSize: 16, color: Colors.white),
    //                 ),
    //               ]
    //             ),
    //           ),
    //         ),
    //         const SizedBox(height: 10),
    //         SizedBox(
    //           width: 0.5 * MediaQuery.of(context).size.width,
    //           child: ElevatedButton(
    //             onPressed: () {
    //               Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(
    //                 doctorId: _userDataService.doctor!.uid,
    //                 doctorName: '${_userDataService.doctor!.firstName} ${_userDataService.doctor!.lastName}',
    //                 patientId: widget.patient.uid,
    //                 patientName: '${widget.patient.firstName} ${widget.patient.lastName}',
    //               ),));
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: const Color(0xFF2B962B),
    //               padding:
    //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(10),
    //               ),
    //             ),
    //             child: const Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(Icons.message, color: Colors.white),
    //                 SizedBox(width: 8),
    //                 Text(
    //                   'Message',
    //                   style: TextStyle(fontSize: 16, color: Colors.white),
    //                 ),
    //               ]
    //             ),
    //           ),
    //         ),
    //         const SizedBox(height: 10,),
    //         SizedBox(
    //           width: 0.5 * MediaQuery.of(context).size.width,
    //           child: ElevatedButton(
    //             onPressed: () {
    //               Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientHistory(
    //                 patient: widget.patient,
    //               ),));
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: const Color(0xFF2B962B),
    //               padding:
    //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(10),
    //               ),
    //             ),
    //             child: const Text(
    //               'Medical History',
    //               style: TextStyle(fontSize: 16, color: Colors.white),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}