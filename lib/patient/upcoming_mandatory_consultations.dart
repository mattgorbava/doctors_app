import 'dart:convert';

import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/consultation.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/widgets/consultation_card.dart';
import 'package:doctors_app/services/booking_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localization/flutter_localization.dart';

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
  late List<List<Booking>> bookings = [];
  List<Patient> children = [];

  Future<void> _loadConsultations() async {
    try {
      String jsonString = await rootBundle.loadString('lib/assets/json/consultations.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      
      if (jsonData.containsKey('consultations')) {
        List<dynamic> consultationsJson = jsonData['consultations'];
        setState(() {
          consultations = consultationsJson.map((consultation) => Consultation.fromMap(consultation)).toList();
        });
      } else {
        try {
          List<dynamic> consultationsJson = jsonData as List<dynamic>;
          setState(() {
            consultations = consultationsJson.map((consultation) => Consultation.fromMap(consultation)).toList();
          });
        } catch (e) {
          throw Exception(e);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleData.couldNotGetConsultations.getString(context)),
        backgroundColor: Colors.red,
      ));
    }
  } 

  Future<void> _fetchBookings(String id, int patientIndex) async {
    List<Booking> bookings = await _bookingService.getAllBookingsByPatientId(id);
    setState(() {
      this.bookings.add(bookings);
    });
  }

  Future<List<Consultation>> _loadPatientAndConsultations() async {
    patient = _userDataService.patient!;
    if (_userDataService.children != null && _userDataService.children!.isNotEmpty) {
      children = _userDataService.children!;
    }
    await _loadConsultations();
    await _fetchBookings(widget.patientId, 0);
    if (children.isNotEmpty) {
      int patientIndex = 1;
      for (var child in children) {
        await _fetchBookings(child.uid, patientIndex);
        patientIndex++;
      }
    }
    _filterConsultations(0);
    for (int i = 1; i < bookings.length; i++) {
      _filterConsultations(i);
    }
    return consultations;
  }

  void _filterConsultations(int patientIndex) {
    if (consultations.isEmpty || bookings.isEmpty) {
      return;
    }

    DateTime now = DateTime.now();
    
    setState(() {
      consultations = consultations.where((consultation) {
        bool hasMatchingBooking = bookings[patientIndex].any((booking) {
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

  (DateTime, Consultation?) _nextConsultationDate(int patientIndex) {
    DateTime nextConsultationDate = DateTime.now();
    Patient patient = patientIndex == 0 ? this.patient : children[patientIndex - 1];
    int patientAgeInMonths = _ageInMonths(patient);
    DateTime now = DateTime.now();
    Consultation fittingConsultation = Consultation.empty();

    for (var consultation in consultations) {
      if (consultation.periodInMonths > 0 &&
          patientAgeInMonths >= consultation.ageInMonthsStart &&
          patientAgeInMonths <= consultation.ageInMonthsEnd) {
        if (bookings[patientIndex].any((booking) => booking.description.toLowerCase().contains(consultation.title.toLowerCase())
                              && booking.isMandatory == true)) {
          DateTime bookingDate = DateTime.parse(
            bookings[patientIndex].firstWhere((booking) => booking.description.toLowerCase().contains(consultation.title.toLowerCase())
            && booking.isMandatory == true
            && booking.status == 'Completed')
            .date
          );
          bookingDate.add(Duration(days: (consultation.periodInMonths * 30.44).floor()));
          nextConsultationDate = bookingDate;
          fittingConsultation = consultation;
        } else {
          if (patient.parentId.isNotEmpty) {
            nextConsultationDate = now.add(const Duration(days: 7));
            fittingConsultation = consultation;
          } else {
            int consultationPeriod = consultation.periodInMonths;
            int monthsUntilNextConsultation = consultationPeriod - (patientAgeInMonths % consultationPeriod);
            nextConsultationDate = DateTime(now.year, now.month + monthsUntilNextConsultation, patient.birthDate.day);
            fittingConsultation = consultation;
          }
        }
      }
    }

    if (nextConsultationDate.isBefore(now)) {
      nextConsultationDate = now.add(const Duration(days: 7));
    }
    return (nextConsultationDate, fittingConsultation);
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
        title: Text(LocaleData.upcomingMandatoryConsultationsTitle.getString(context)),
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
            return ListView.builder(
              itemCount: children.isNotEmpty ? children.length + 1 : 1,
              itemBuilder: (context, index) {
                final (nextConsultationDate, consultation) = _nextConsultationDate(index);
                if (nextConsultationDate.isBefore(DateTime.now())) {
                  return const SizedBox.shrink();
                }
                return ConsultationCard(
                  consultation: consultation!,
                  patient: index == 0 ? patient : children[index - 1],
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