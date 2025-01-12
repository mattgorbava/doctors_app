import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/model/booking.dart';
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
  final DatabaseReference _requestRef = FirebaseDatabase.instance.ref().child('Requests');
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      await _requestRef.orderByChild('patientId').equalTo(currentUserId).once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        List<Booking> bookings = [];

        if (snapshot.value != null) {
          Map<dynamic, dynamic> bookingMap = snapshot.value as Map<dynamic, dynamic>;
          bookingMap.forEach((key, value) {
            bookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
          });
        }

        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }).catchError((error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not get bookings.'),
          backgroundColor: Colors.red,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty ? Center(child: Text('No bookings found.')) 
          : ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final Booking booking = _bookings[index];
                return ListTile(
                  title: Text(booking.description),
                  subtitle: Text('Date: ${booking.date} Time: ${booking.time}'),
                  trailing: Text(booking.status),
                ); 
              },
            ),
    );
  }
}