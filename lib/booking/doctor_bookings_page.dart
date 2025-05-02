import 'dart:async';

import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/booking/booking_card.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DoctorBookingsPage extends StatefulWidget {
  const DoctorBookingsPage({super.key});

  @override
  State<DoctorBookingsPage> createState() => _DoctorBookingsPageState();
}

class _DoctorBookingsPageState extends State<DoctorBookingsPage> {
  final BookingService _bookingService = BookingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _bookingsRef = FirebaseDatabase.instance.ref().child('Bookings');
  List<Booking> _bookings = <Booking>[];
  bool _isLoading = true;
  List<String> statuses = ['Pending', 'Confirmed', 'Cancelled'];
  String? currentStatus = 'Pending';

  void getBookings() async {
    _bookings = await _bookingService.getAllBookingsByDoctorId(_auth.currentUser!.uid);
  }

  @override
  void initState() {
    super.initState();
    getBookings();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        automaticallyImplyLeading: false,
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
                        getBookings();
                      }
                    );
                  },
                ),
    );
  }
   
}