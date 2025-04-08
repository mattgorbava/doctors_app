import 'package:doctors_app/registration_request/registration_request_card.dart';
import 'package:doctors_app/registration_request/registration_request_details_page.dart';
import 'package:doctors_app/model/registration_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RegistrationRequestsPage extends StatefulWidget {
  const RegistrationRequestsPage({super.key});

  @override
  State<RegistrationRequestsPage> createState() => _RegistrationRequestsPageState();
}

class _RegistrationRequestsPageState extends State<RegistrationRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _registrationRequestsRef = FirebaseDatabase.instance.ref().child('RegistrationRequests');

  List<RegistrationRequest> _registrationRequests = [];
  bool _isLoading = true;

  Future<void> _fetchRegistrationRequests() async {
    String? doctorId = _auth.currentUser?.uid;
    try {
      await _registrationRequestsRef.orderByChild('doctorId').equalTo(doctorId).once().then((snapshot) {
        List<RegistrationRequest> requests = [];
        if (snapshot.snapshot.exists) {
          Map<dynamic, dynamic> data = snapshot.snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            requests.add(RegistrationRequest.fromMap(Map<String, dynamic>.from(value), key));
          });
          setState(() {
            _registrationRequests = requests;
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch registration requests. Please try again later.'),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRegistrationRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Requests'),
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _registrationRequests.isEmpty
        ? const Center(child: Text('No registration requests found.'))
        : ListView.builder(
          itemCount: _registrationRequests.length,
          itemBuilder: (context, index) {
            final request = _registrationRequests[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationRequestDetailsPage(request: request),
                  ),
                );
              },
              child: RegistrationRequestCard(request: request)
            );
          },
        ),
    );
  }
}