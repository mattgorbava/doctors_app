import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/chat_screen.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:doctors_app/widgets/patient_card.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientUserProfile extends StatefulWidget {
  const PatientUserProfile({super.key, this.patient});

  final Patient? patient;

  @override
  State<PatientUserProfile> createState() => _PatientUserProfileState();
}

class _PatientUserProfileState extends State<PatientUserProfile> with AutomaticKeepAliveClientMixin<PatientUserProfile> {
  @override
  bool get wantKeepAlive => true;

  final UserDataService _userDataService = UserDataService();
  final BookingService _bookingService = BookingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Booking> _bookings = [];
  List<Patient> _children = [];
  bool _isLoading = true;
  String? pdfFileName;
  String? pdfFilePath;
  String? analysisResultsPdfUrl;
  bool _isPatient = true;
  Patient? _patient;

  final cloudinary = CloudinaryPublic(
    '',  
    'doctors-app', 
    cache: false,
  );

  @override
  void initState() {
    super.initState();
    _isPatient = _userDataService.isPatient ?? true;
    _patient = widget.patient ?? _userDataService.patient;
    if (_isPatient) {
      _bookings = _userDataService.patientBookings ?? <Booking>[];
      _children = _userDataService.children ?? <Patient>[];
      _fetchChildrenBookings();
    } else {
      _fetchBookings();
    }
    _isLoading = false;
  }

  Future<void> _fetchChildrenBookings() async {
    try {
      for (var child in _children) {
        List<Booking> bookings = await _bookingService.getAllBookingsByPatientId(child.uid);
        setState(() {
          _bookings.addAll(bookings);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch bookings. Please try again later.'),
        ),
      );
    }
  }

  Future<void> _fetchBookings() async {
    try {
      List<Booking> bookings = await _bookingService.getAllBookingsByPatientId(_patient!.uid);
      setState(() {
        _bookings = bookings;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch bookings. Please try again later.'),
        ),
      );
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
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('User Profile'),
        actions: [
          _isPatient 
          ? IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              _userDataService.clearUserData();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false);
            },
          )
          : const SizedBox.shrink(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                PatientCard(patient: _patient!),
                if (!_isPatient) ... [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 0.5 * MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _makePhoneCall(_patient!.phoneNumber);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.phone),
                          SizedBox(width: 8),
                          Text('Call Patient', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 0.5 * MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            patientId: _patient!.uid,
                            patientName: '${_patient!.firstName} ${_patient!.lastName}',
                            doctorId: _userDataService.doctor!.uid,
                            doctorName: '${_userDataService.doctor!.firstName} ${_userDataService.doctor!.lastName}',
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message),
                          SizedBox(width: 8),
                          Text('Message', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
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
                                  if (booking.status == "AnalysisPending" && _isPatient)
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
                                            booking.analysisResultsPdf = response.secureUrl;
                                            _bookingService.updateBooking(booking);
                                            setState(() {
                                              analysisResultsPdfUrl = response.secureUrl;
                                              pdfFileName = null;
                                              pdfFilePath = null;
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
                              if (booking.status != null && booking.status == 'Completed') ... [
                                const SizedBox(height: 8),
                                Text(
                                  'Results: ${booking.results}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Recommendations: ${booking.recommendations}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                )
                              ],
                              if (booking.analysisResultsPdf != null && booking.analysisResultsPdf!.isNotEmpty) ... [
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final url = booking.analysisResultsPdf!;
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                    } else {
                                      _showErrorDialog('Could not open PDF file.');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('View Test Results'),
                                ),
                              ],
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