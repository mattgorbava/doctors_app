import 'package:doctors_app/model/booking.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() {
    return _instance;
  }
  BookingService._internal();

  var logger = Logger();

  final DatabaseReference _bookingRef = FirebaseDatabase.instance.ref().child('Bookings');

  Future<List<Booking>> getAllBookingsByPatientId(String patientId) async {
    List<Booking> bookings = [];
    try {
      final snapshot = await _bookingRef.orderByChild('patientId').equalTo(patientId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          bookings.add(Booking.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      logger.e('Error fetching bookings: $e');
    }
    return bookings;
  }

  Future<List<Booking>> getAllBookingsByDoctorId(String doctorId) async {
    List<Booking> bookings = [];
    try {
      final snapshot = await _bookingRef.orderByChild('doctorId').equalTo(doctorId).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          bookings.add(Booking.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
    } catch (e) {
      logger.e('Error fetching bookings: $e');
    }
    return bookings;
  }

  Future<void> addBooking(Map<String, dynamic> bookingData) async {
    try {
      String bookingId = _bookingRef.push().key!;
      await _bookingRef.child(bookingId).set(bookingData);
    } catch (e) {
      logger.e('Error adding booking: $e');
    }
  }

  Future<void> updateBooking(Booking booking) async {
    try {
      await _bookingRef.child(booking.id).update(booking.toMap());
    } catch (e) {
      logger.e('Error updating booking: $e');
    }
  }

  Future<void> deleteBooking(String id) async {
    try {
      await _bookingRef.child(id).remove();
    } catch (e) {
      logger.e('Error deleting booking: $e');
    }
  }
}