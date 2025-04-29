import 'package:doctors_app/medical_history/add_medical_history_page.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  BookingCard({super.key, required this.booking, required this.onStatusUpdated});
  
  final Booking booking;

  final DatabaseReference _patientRef = FirebaseDatabase.instance.ref().child('Patients');
  final DatabaseReference _medicalHistoryRef = FirebaseDatabase.instance.ref().child('MedicalHistory');

  final VoidCallback onStatusUpdated;

  Future<String> _getPatientName(String patientId) async {
    try {
      final snapshot = await _patientRef.child(patientId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        return '${data['firstName']} ${data['lastName']}';
      } else {
        return 'Unknown Patient';
      }
    } catch (e) {
      return 'Error fetching patient name';
    }
  }

  bool _isBookingDateAndTimeBeforeNow(String bookingDate, String bookingTime) {
    DateTime now = DateTime.now();
    DateTime bookingDateTime = DateTime.parse('$bookingDate $bookingTime');
    return bookingDateTime.isBefore(now);
  }

  Future<void> _updateBookingStatus(BuildContext context, String bookingId, String status) async {
    try {
      await FirebaseDatabase.instance.ref().child('Bookings').child(bookingId).update({'status': status});
      onStatusUpdated?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not update booking status.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 196, 255, 209)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(2),
        child: FutureBuilder<String>(
          future: _getPatientName(booking.patientId),
          builder: (context, snapshot) {
            final patientName = snapshot.connectionState == ConnectionState.done
            ? (snapshot.hasData ? snapshot.data! : "Unknown Patient")
            : "Loading...";
            return Column(
              children: [
                ListTile(
                  title: Text(
                    '${booking.description}\nPatient: ${patientName}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Status: ${booking.status}\nDate of booking: ${booking.date} at ${booking.time}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: booking.status == 'Pending' ? Colors.orange 
                      : booking.status == 'Confirmed' ? Colors.green
                      : booking.status == 'Cancelled' ? Colors.red
                      : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (booking.status == 'Pending') ... [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          _updateBookingStatus(context, booking.id, 'Confirmed');
                        },
                        child: const Text('Confirm'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          _updateBookingStatus(context, booking.id, 'Cancelled');
                        },
                        child: const Text('Cancel'),
                      ),
                    ] else if (booking.status == 'Confirmed') ... [
                      _isBookingDateAndTimeBeforeNow(booking.date, booking.time) ?
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          ),
                          onPressed: () async {
                            final String? newStatus = await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (context) => AddMedicalHistoryPage(
                                  bookingId: booking.id,
                                  isMandatory: booking.isMandatory,
                                ),
                              )
                            );
                            
                            if (newStatus != null) {
                              _updateBookingStatus(context, booking.id, newStatus);
                            }
                          },
                          child: const Text('Complete'),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            _updateBookingStatus(context, booking.id, 'Cancelled');
                          },
                          child: const Text('Cancel'),
                      ),
                    ],
                    
                  ],
                )
              ],
            );
          }
        ),
      ),
    );
  }
}