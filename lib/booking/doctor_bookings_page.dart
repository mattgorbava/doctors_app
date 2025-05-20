import 'package:doctors_app/widgets/booking_card.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorBookingsPage extends StatefulWidget {
  const DoctorBookingsPage({super.key});

  @override
  State<DoctorBookingsPage> createState() => _DoctorBookingsPageState();
}

class _DoctorBookingsPageState extends State<DoctorBookingsPage> with AutomaticKeepAliveClientMixin<DoctorBookingsPage> {
  @override
  bool get wantKeepAlive => true;

  final BookingService _bookingService = BookingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Booking> _bookings = <Booking>[];
  bool _isLoading = true;
  List<String> statuses = ['Pending', 'Confirmed', 'Cancelled'];
  String? currentStatus = 'Pending';

  void getBookings() async {
    _bookings = await _bookingService.getAllBookingsByDoctorId(_auth.currentUser!.uid);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getBookings();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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