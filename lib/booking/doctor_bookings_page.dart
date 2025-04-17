import 'dart:async';

import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/booking/booking_card.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DoctorBookingsPage extends StatefulWidget {
  const DoctorBookingsPage({super.key});

  @override
  State<DoctorBookingsPage> createState() => _DoctorBookingsPageState();
}

class _DoctorBookingsPageState extends State<DoctorBookingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _bookingsRef = FirebaseDatabase.instance.ref().child('Bookings');
  List<Booking> _bookings = <Booking>[];
  bool _isLoading = true;
  List<String> statuses = ['Pending', 'Confirmed', 'Cancelled'];
  String? currentStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      await _bookingsRef.orderByChild('doctorId').equalTo(currentUserId).once().then((DatabaseEvent event) {
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
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        automaticallyImplyLeading: false,
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
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings found.'))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return BookingCard(
                      booking: booking,
                      onStatusUpdated: () {
                        _fetchBookings();
                      }
                    );
                  },
                ),
    );
  }
   
}