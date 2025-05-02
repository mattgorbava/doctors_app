import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/doctor/patient_card.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _bookingRef = FirebaseDatabase.instance.ref().child('Bookings');
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? pdfFileName;
  String? pdfFilePath;
  String? analysisResultsPdfUrl;
  final UserDataService _userDataService = UserDataService();

  final cloudinary = CloudinaryPublic(
    '',  
    'doctors-app', 
    cache: false,
  );

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      await _bookingRef.orderByChild('patientId').equalTo(currentUserId).once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        List<Booking> bookings = [];

        if (snapshot.value != null) {
          Map<dynamic, dynamic> bookingMap = snapshot.value as Map<dynamic, dynamic>;
          bookingMap.forEach((key, value) {
            bookings.add(Booking.fromMap(Map<String, dynamic>.from(value), key));
          });
        }

        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }).catchError((error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not get bookings.'),
          backgroundColor: Colors.red,
        ));
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      case 'Completed':
        return Colors.blue;
      case 'AnalysisPending':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          pdfFileName = result.files.single.name;
          pdfFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick PDF file');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('An error occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                PatientCard(patient: _userDataService.patient!),
                Expanded(child: 
                  _bookings.isEmpty ? const Center(child: Text('No bookings found.')) 
                  : ListView.builder(
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final Booking booking = _bookings[index];
                        return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.description,
                                style: const TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Date: ${booking.date}'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.access_time, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Time: ${booking.time}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(booking.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      booking.status,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  if (booking.status == "AnalysisPending")
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        _pickPdf();
                                        if (pdfFilePath != null) {
                                          try {
                                            CloudinaryResponse response = await cloudinary.uploadFile(
                                              CloudinaryFile.fromFile(
                                                pdfFilePath!,
                                                folder: 'medical_history',
                                                resourceType: CloudinaryResourceType.Raw,
                                              ),
                                            );
                                            final medicalHistoryRef = FirebaseDatabase.instance.ref('MedicalHistory');
                                            medicalHistoryRef.orderByChild('bookingId').equalTo(booking.id).once().then((DatabaseEvent event) {
                                              if (event.snapshot.exists) {
                                                final key = event.snapshot.children.first.key;
                                                if (key != null) {
                                                  medicalHistoryRef.child(key).update({
                                                    'analysisResultsPdfUrl': response.secureUrl,
                                                  });
                                                  _bookingRef.child(booking.id).update({
                                                    'status': 'Completed',
                                                  });
                                                }
                                              }
                                            });
                                            
                                          } catch (e) {
                                            _showErrorDialog('Failed to upload PDF file');
                                            
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            return;
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.add_chart),
                                      label: const Text("Add Test Results"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                      },
                    ),)
              ],
          ) 
    );
  }
}