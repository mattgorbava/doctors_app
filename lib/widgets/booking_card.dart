import 'package:doctors_app/medical_history/add_medical_history_page.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/patient_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  BookingCard({super.key, required this.booking, required this.onStatusUpdated});
  
  final Booking booking;

  final VoidCallback onStatusUpdated;

  final PatientService _patientService = PatientService();

  Future<String> _getPatientName(String patientId) async {
    try {
      Patient patient = await _patientService.getPatientById(patientId) ?? Patient.empty();
      if (patient.isEmpty) {
        return 'Unknown Patient';
      }
      return '${patient.firstName} ${patient.lastName}';
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
      onStatusUpdated.call();
    } catch (e) {
      return Future.error('Error updating booking status: $e');
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
                    '${booking.description}\nPatient: $patientName',
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
                        child: const Text('Confirm', style: TextStyle(color: Colors.white),),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          _updateBookingStatus(context, booking.id, 'Cancelled');
                        },
                        child: const Text('Cancel', style: TextStyle(color: Colors.white),),
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
                              // ignore: use_build_context_synchronously
                              _updateBookingStatus(context, booking.id, newStatus);
                            }
                          },
                          child: const Text('Complete', style: TextStyle(color: Colors.white),),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            _updateBookingStatus(context, booking.id, 'Cancelled');
                          },
                          child: const Text('Cancel', style: TextStyle(color: Colors.white),),
                      ),
                    ],
                    
                  ],
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 0.5 * MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B962B),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('View Details', style: TextStyle(fontSize: 16, color: Colors.white),),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          }
        ),
      ),
    );
  }
}