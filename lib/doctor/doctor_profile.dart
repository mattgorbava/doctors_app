import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _doctorRef = FirebaseDatabase.instance.ref().child('Doctors');
  Doctor? _doctor;
  bool _isLoading = true;

  Future<void> _fetchDoctorDetails() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      try {
      DatabaseEvent event = await _doctorRef.child(currentUserId).once();
      DataSnapshot snapshot = event.snapshot;
      Doctor? doctor;

      if (snapshot.value != null) {
        doctor = Doctor.fromMap(snapshot.value as Map<dynamic, dynamic>, currentUserId);
      }

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
      // Navigate to login screen after logout
      Navigator.of(context).pushReplacementNamed('/login'); // Replace '/login' with your login route
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
    _fetchDoctorDetails();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _isLoading == true ? const Center(child: CircularProgressIndicator(),) 
    : Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _logout();
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
            ],
          ),
        ),
      ),
    );
  }
}