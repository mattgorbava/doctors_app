import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/medical_history.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:doctors_app/services/medical_history_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key, this.patient, this.booking});

  final Patient? patient;
  final Booking? booking;

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  final UserDataService _userDataService = UserDataService();
  final BookingService _bookingService = BookingService();
  final MedicalHistoryService _medicalHistoryService = MedicalHistoryService();

  List<Booking> _bookings = <Booking>[];
  List<MedicalHistory> _history= <MedicalHistory>[];

  Future<void> _fetchBookings() async {
    try {
      if (widget.patient != null) {
        _bookings = _userDataService.patientBookings ?? <Booking>[];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch bookings. Please try again later.'),
        ),
      );
    }
  }

  Future<void> _fetchMedicalHistory() async {
    try {
      if (widget.patient != null) {
        _history = await _medicalHistoryService.getAllMedicalHistoryByPatientId(widget.patient!.uid);
      } else if (widget.booking != null) {
        _history = await _medicalHistoryService.getBookingHistory(widget.booking!.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch medical history. Please try again later.'),
        ),
      );
    }
  }

  Future<void> _fetchData() async {
    await _fetchBookings();
    await _fetchMedicalHistory();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patient != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medical History'),
          automaticallyImplyLeading: false,
        ),
        body: _bookings.isEmpty
            ? const Center(child: Text('No history found.'))
            : ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicalHistoryPage(booking: booking),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(booking.date.toString()),
                      subtitle: Text(booking.description),
                    ),
                  );
                },
              ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medical History'),
          automaticallyImplyLeading: false,
        ),
        body: _history.isEmpty
            ? const Center(child: Text('No medical history found.'))
            : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final history = _history[index];
                  return ListTile(
                    title: Text(''),
                    subtitle: Text(''),
                  );
                },
              ),
      );
    }
  }
}