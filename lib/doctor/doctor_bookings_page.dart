import 'package:doctors_app/auth/login_page.dart';
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
  final DatabaseReference _bookingsRef = FirebaseDatabase.instance.ref().child('Requests');
  List<Booking> _bookings = <Booking>[];
  bool _isLoading = true;
  List<String> statuses = ['Pending', 'Confirmed', 'Cancelled'];
  String? currentStatus = 'Pending'; // Initial selected status

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
        title: const Text('Bookings'),
        automaticallyImplyLeading: false,
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
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings found.'))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (BuildContext context, int index) {
                    Booking booking = _bookings[index];
                    return ListTile(
                      title: Text(booking.description),
                      subtitle: Text('Date ${booking.date} Time ${booking.time}'),
                      trailing: Text(booking.status),
                      onTap: () => _showUpdateStatusDialog(booking.id, booking.status),
                    );
                  },
                ),
    );
  }
  
  void _showUpdateStatusDialog(String id, String status) {
    showDialog(
      context: context,
      builder: (context) {
        String? dialogStatus = currentStatus; // Local state for the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select new status for this booking.'),
                  SizedBox(height: 16),
                  Column(
                    children: List.generate(statuses.length, (index) {
                      return RadioListTile<String>(
                        title: Text(statuses[index]),
                        value: statuses[index],
                        groupValue: dialogStatus,
                        onChanged: (String? value) {
                          setState(() {
                            dialogStatus = value;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    await _updateBookingStatus(id, dialogStatus!);
                    setState(() {
                      currentStatus = dialogStatus;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _updateBookingStatus(String id, String status) async {
    await _bookingsRef.child(id).update({'status': status});
    await _fetchBookings();
  }
}