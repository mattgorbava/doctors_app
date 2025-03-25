import 'package:doctors_app/chat_screen.dart';
import 'package:doctors_app/main.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailsPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailsPage({super.key, required this.doctor});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _patientsDatabase = FirebaseDatabase.instance.ref().child('Patients');
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref().child('Requests');

  TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: widget.doctor.profileImageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.doctor.profileImageUrl,
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
                        '${widget.doctor.firstName} ${widget.doctor.lastName}',
                        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${widget.doctor.city}',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: (){
                              _makePhoneCall(widget.doctor.phoneNumber);
                            }, 
                            icon: Image.asset('lib/assets/images/phone.png', height: 30, width: 30), 
                          ),
                          IconButton(
                            onPressed: () async {
                              String currentUserId = _auth.currentUser!.uid;
                              DataSnapshot firstNameSnapshot = await _patientsDatabase.child(currentUserId).child('firstName').get();
                              DataSnapshot lastNameSnapshot = await _patientsDatabase.child(currentUserId).child('lastName').get();
                              String currentUserName = '${firstNameSnapshot.value} ${lastNameSnapshot.value}';
                              String doctorName = '${widget.doctor.firstName} ${widget.doctor.lastName}';
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatScreen(
                                  patientName: currentUserName, patientId: currentUserId, doctorName: doctorName, doctorId:widget.doctor.uid)),
                              );
                            }, 
                            icon: Image.asset('lib/assets/images/chat.png', height: 30, width: 30), 
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF2B962B),
              //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12)
              //       )
              //     ),
              //     onPressed: (){
              //       _openMap();
              //     },
              //     child: Text('Open location in maps', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),),
              //   ),
              // ),
              const SizedBox(height: 50),
              Text('Select date and time', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
              const SizedBox(height: 8,),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF84c384),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color.fromARGB(255, 98, 176, 98), width: 1)
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B962B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              )
                            ),
                            child: Text(
                              _selectedDate == null ? 
                              'Select date' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                            ),
                          )
                        ),
                        const SizedBox(width: 16,),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _selectTime(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B962B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              )
                            ),
                            child: Text(
                              _selectedTime == null ? 
                              'Select time' : _selectedTime!.format(context),
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                            ),
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 16,),
                    TextField(
                      controller: _descriptionController,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    )
                  ],
                )
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B962B),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                  onPressed: (){
                    _bookAppointment();
                  },
                  child: Text('Book appointment', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),),
                ),
              )
            ],
          ),
        ),
      ),
    );
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

  // void _openMap() async {
  //   String google = 'https://www.google.com/maps/search/?api=1&query=${widget.doctor.latitude},${widget.doctor.longitude}';
  //   Uri googleUrl = Uri.parse(google);
  //   try {
  //     if (await canLaunchUrl(googleUrl)) {
  //       await launchUrl(googleUrl);
  //     } else {
  //       throw 'Could not open the map.';
  //     }
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //       content: Text('Could not open the map.'),
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  // }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  void _bookAppointment() {
    if(_selectedDate == null || _selectedTime == null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select date and time'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    String date = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    String time = _selectedTime!.format(context);
    String description = _descriptionController.text;
    String requestId = _requestDatabase.push().key!;
    String doctorId = widget.doctor.uid;
    String patientId = _auth.currentUser!.uid;
    String status = 'Pending';

    _requestDatabase.child(requestId).set({
      'id': requestId,
      'doctorId': doctorId,
      'patientId': patientId,
      'date': date,
      'time': time,
      'description': description,
      'status': status
    }).then((_) {
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _descriptionController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Appointment booked successfully'),
        backgroundColor: Colors.green,
      ));
      _sendNotification();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to book appointment'),
        backgroundColor: Colors.red,
      ));
    });
  }

  void _sendNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Appointment',
      'New appointment created',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}