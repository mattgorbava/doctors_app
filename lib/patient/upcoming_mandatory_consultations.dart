import 'dart:convert';

import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/consultation.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/patient/consultation_card.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class UpcomingMandatoryConsultations extends StatefulWidget {
  const UpcomingMandatoryConsultations({super.key, required this.patientId});

  final String patientId;

  @override
  State<UpcomingMandatoryConsultations> createState() => _UpcomingMandatoryConsultationsState();
}

class _UpcomingMandatoryConsultationsState extends State<UpcomingMandatoryConsultations> with AutomaticKeepAliveClientMixin<UpcomingMandatoryConsultations> {
  @override
  bool get wantKeepAlive => true;
  final UserDataService _userDataService = UserDataService();
  final BookingService _bookingService = BookingService();

  late List<Consultation> consultations = [];
  late Patient patient;
  late Future<List<Consultation>> consultationsFuture;
  late List<Booking> bookings = [];

  Future<void> _loadConsultations() async {
    if (patient == null) {
      throw Exception('Patient not loaded yet');
    }

    try {
      String jsonString = await rootBundle.loadString('lib/assets/json/consultations.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      
      if (jsonData.containsKey('consultations')) {
        List<dynamic> consultationsJson = jsonData['consultations'];
        DateTime now = DateTime.now();
        DateTime date = patient.birthDate;
        int patientAgeInMonths = ((now.year - date.year) * 12 + now.month - date.month).toInt();
        consultationsJson = consultationsJson.where((consultation) {
          int ageInMonthsStart = int.parse(consultation['ageInMonthsStart']);
          int ageInMonthsEnd = int.parse(consultation['ageInMonthsEnd']);
          return patientAgeInMonths >= ageInMonthsStart && patientAgeInMonths <= ageInMonthsEnd;
        }).toList();
        setState(() {
          consultations = consultationsJson.map((consultation) => Consultation.fromMap(consultation)).toList();
        });
      } else {
        try {
          List<dynamic> consultationsJson = jsonData as List<dynamic>;
          DateTime now = DateTime.now();
          DateTime date = patient.birthDate;
          int patientAgeInMonths = ((now.year - date.year) * 12 + now.month - date.month).toInt();
          consultationsJson = consultationsJson.where((consultation) {
            int ageInMonthsStart = consultation['ageInMonthsStart'] as int;
            int ageInMonthsEnd = consultation['ageInMonthsEnd'] as int;
            return patientAgeInMonths >= ageInMonthsStart && patientAgeInMonths <= ageInMonthsEnd;
          }).toList();
          setState(() {
            consultations = consultationsJson.map((consultation) => Consultation.fromMap(consultation)).toList();
          });
        } catch (e) {
          throw Exception(e);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not get consultations.'),
        backgroundColor: Colors.red,
      ));
    }
  } 

  Future<void> _fetchBookings() async {
    List<Booking> bookings = await _bookingService.getAllBookingsByPatientId(widget.patientId);
    setState(() {
      this.bookings = bookings;
    });
  }

  Future<List<Consultation>> _loadPatientAndConsultations() async {
    patient = _userDataService.patient!;
    await _loadConsultations();
    await _fetchBookings();
    _filterConsultations();
    return consultations;
  }

  void _filterConsultations() {
    if (consultations.isEmpty || bookings.isEmpty) {
      return;
    }

    DateTime now = DateTime.now();
    
    setState(() {
      consultations = consultations.where((consultation) {
        bool hasMatchingBooking = bookings.any((booking) {
          bool titleMatches = booking.description.toLowerCase().contains(consultation.title.toLowerCase());
          
          DateTime bookingDate = DateTime.parse(booking.date);
          bool isInFuture = bookingDate.isAfter(now);
          
          bool hasValidStatus = booking.status == 'Pending' || 
            booking.status == 'Confirmed' || 
            booking.status == 'Completed' ||
            booking.status == 'AnalysisPending';
          
          bool isMandatory = booking.isMandatory;

          return titleMatches && isInFuture && hasValidStatus && isMandatory;
        });
        return !hasMatchingBooking;
      }).toList();
    });
  }

  int _ageInMonths(Patient patient) {
    DateTime date = patient.birthDate;
    DateTime now = DateTime.now();
    int ageInMonths = (now.year - date.year) * 12 + now.month - date.month;
    return ageInMonths;
  }

  DateTime _nextConsultationDate(Consultation consultation) {
    DateTime nextConsultationDate = DateTime.now();

    if (bookings.any((booking) => booking.description.toLowerCase().contains(consultation.title.toLowerCase())
                              && booking.isMandatory == true)) {
      DateTime bookingDate = DateTime.parse(
        bookings.firstWhere((booking) => booking.description.toLowerCase().contains(consultation.title.toLowerCase())
        && booking.isMandatory == true
        && booking.status == 'Completed')
        .date
      );
      bookingDate.add(Duration(days: (consultation.periodInMonths * 30.44).floor()));
    }
    else {
      int patientAgeInMonths = _ageInMonths(patient);
      int consultationPeriod = consultation.periodInMonths;
      int monthsUntilNextConsultation = consultationPeriod - (patientAgeInMonths % consultationPeriod);

      DateTime now = DateTime.now();
      nextConsultationDate = DateTime(now.year, now.month + monthsUntilNextConsultation, patient.birthDate.day);
    }

    // if (nextConsultationDate.isBefore(DateTime.now().add(const Duration(days: 60)))) {
    //   nextConsultationDate = DateTime.now().subtract(const Duration(days: 1));
    // }

    if (nextConsultationDate.isBefore(DateTime.now())) {
      nextConsultationDate = DateTime.now().add(const Duration(days: 7));
    }

    return nextConsultationDate;
  }

  @override
  void initState() {
    super.initState();
    consultationsFuture = _loadPatientAndConsultations();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Mandatory Consultations'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Consultation>>(
        future: consultationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No consultations available'));
          } else {
            List<Consultation> consultations = snapshot.data!;
            return ListView.builder(
              itemCount: consultations.length,
              itemBuilder: (context, index) {
                Consultation consultation = consultations[index];
                DateTime nextConsultationDate = _nextConsultationDate(consultation);
                if (nextConsultationDate.isBefore(DateTime.now())) {
                  return const SizedBox.shrink();
                }
                return ConsultationCard(
                  consultation: consultation,
                  patient: patient,
                  nextConsultationDate: nextConsultationDate,
                );
              },
            );
          }
        },
      ),
    );
  }
}