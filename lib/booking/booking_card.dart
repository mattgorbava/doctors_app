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

  Future<void> _updateMedicalHistory(BuildContext context, String bookingId, String reason, String results, String recommendations) async {
    try {
      await _medicalHistoryRef.child(bookingId).set({
        'doctorId': booking.doctorId,
        'patientId': booking.patientId,
        'reason': booking.description,
        'date': DateTime.now().toIso8601String(),
        'results': results,
        'recommendations': recommendations,
      });
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not update medical history.'),
          backgroundColor: Colors.red,
        ));
    }
  }

  void _showCompletionDialog(BuildContext context, Booking booking) {
    TextEditingController resultsController = TextEditingController();
    TextEditingController recommendationsController = TextEditingController();
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Consultation Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Consultation',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: resultsController,
                  decoration: const InputDecoration(
                    labelText: 'Consultation Results',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: recommendationsController,
                  decoration: const InputDecoration(
                    labelText: 'Recommendations',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String reason = reasonController.text;
                String results = resultsController.text;
                String recommendations = recommendationsController.text;
                _updateBookingStatus(context, booking.id, 'Completed');
                _updateMedicalHistory(context, booking.id, reason, results, recommendations);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddMedicalHistoryPage(bookingId: booking.id,),));
                            _updateBookingStatus(context, booking.id, 'Completed');
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