import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/auth/register_screen.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/services/doctor_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key, this.doctorId});
  
  final String? doctorId;

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> with AutomaticKeepAliveClientMixin<DoctorProfile> {
  @override
  bool get wantKeepAlive => true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DoctorService _doctorService = DoctorService();
  final UserDataService _userDataService = UserDataService();
  Doctor? _doctor;
  bool _isLoading = true;

  // Future<void> _fetchDoctorDetails() async {
  //   if (widget.doctorId != null) {
  //     try {
  //     DatabaseEvent event = await _doctorRef.child(widget.doctorId!).once();
  //     DataSnapshot snapshot = event.snapshot;
  //     Doctor? doctor;

  //     if (snapshot.value != null) {
  //       doctor = Doctor.fromMap(snapshot.value as Map<dynamic, dynamic>, widget.doctorId!);
  //     }

  //     setState(() {
  //       _doctor = doctor;
  //       _isLoading = false;
  //     });

  //   } catch (e) {
  //     print('Error fetching doctor by ID: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //       content: Text('Could not get doctor details.'),
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  //   }
  // }

  Future<void> _fetchDoctorDetails() async {
    if (widget.doctorId != null) {
      try {
        Doctor? doctor = await _doctorService.getDoctorById(widget.doctorId!);
        setState(() {
          _doctor = doctor;
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching doctor by ID: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not get doctor details.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Logged out successfully.'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not log out.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    if (widget.doctorId != null) {
      _fetchDoctorDetails();
    } else {
      _doctor = _userDataService.doctor;
    }
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading == true ? const Center(child: CircularProgressIndicator(),) 
    : Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _auth.signOut();
              _userDataService.clearUserData();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: _doctor!.profileImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person),
              ),
              const SizedBox(height: 20),
              Text(
                '${_doctor!.firstName} ${_doctor!.lastName}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_doctor!.cvUrl != null && _doctor!.cvUrl!.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = _doctor!.cvUrl!;
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open CV.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Open CV'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green,),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: 0.5 * MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterPage(
                      doctor: _doctor,
                    )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B962B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Edit Profile', style: TextStyle(fontSize: 16, color: Colors.white),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}