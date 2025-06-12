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
    consultations.clear();
    bookings.clear();
    await _loadConsultations();
    await _fetchBookings(widget.patientId, 0);
    if (children.isNotEmpty) {
      int patientIndex = 1;
      for (var child in children) {
        await _fetchBookings(child.uid, patientIndex);
        patientIndex++;
      }
    }
    return consultations;
  }

  List<Consultation> _filterConsultations(int patientIndex) {  //testeaza aici: baga o consultatie care sa fie in trecut, dar sa aiba statusul "Completed" si sa fie mandatory
    if (consultations.isEmpty || bookings[patientIndex].isEmpty) {
      return consultations;
    }

    DateTime now = DateTime.now();
    List<Consultation> filteredConsultations;
    
      filteredConsultations = consultations.where((consultation) {
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

    return filteredConsultations;
  }

  int _ageInMonths(Patient patient) {
    DateTime date = patient.birthDate;
    DateTime now = DateTime.now();
    int ageInMonths = (now.year - date.year) * 12 + now.month - date.month;
    return ageInMonths;
  }

  List<(DateTime, Consultation?)> _nextConsultationDate(int patientIndex) {
    DateTime nextConsultationDate = DateTime.now();
    Patient patient = patientIndex == 0 ? this.patient : children[patientIndex - 1];
    List<Consultation> filteredConsultations = _filterConsultations(patientIndex);
    int patientAgeInMonths = _ageInMonths(patient);
    DateTime now = DateTime.now();
    Consultation fittingConsultation = Consultation.empty();
    List<(DateTime, Consultation?)> nextConsultations = [];

    for (var consultation in filteredConsultations) {
      if (consultation.periodInMonths > 0 &&
          patientAgeInMonths >= consultation.ageInMonthsStart &&
          patientAgeInMonths <= consultation.ageInMonthsEnd) {
        if (bookings[patientIndex].any((booking) => booking.description.toLowerCase().contains(consultation.title.toLowerCase())
            && booking.isMandatory == true && booking.status != 'Cancelled')) {
          DateTime bookingDate = DateTime.parse(
            bookings[patientIndex].firstWhere((booking) => booking.description.toLowerCase().contains(consultation.title.toLowerCase())
            && booking.isMandatory == true
            && booking.status != 'Cancelled')
            .date
          );
          bookingDate.add(Duration(days: (consultation.periodInMonths * 30.44).floor()));
          nextConsultationDate = bookingDate;
          fittingConsultation = consultation;
          if (nextConsultationDate.isBefore(now)) {
            nextConsultationDate = now.add(const Duration(days: 7));
          }
          nextConsultations.add((nextConsultationDate, fittingConsultation));
        } else {
          if (patient.parentId.isNotEmpty) {
            nextConsultationDate = now.add(const Duration(days: 7));
            fittingConsultation = consultation;
            if (nextConsultationDate.isBefore(now)) {
              nextConsultationDate = now.add(const Duration(days: 7));
            }
            nextConsultations.add((nextConsultationDate, fittingConsultation));
          } else {
            int consultationPeriod = consultation.periodInMonths;
            int monthsUntilNextConsultation = consultationPeriod - (patientAgeInMonths % consultationPeriod);
            nextConsultationDate = DateTime(now.year, now.month + monthsUntilNextConsultation, patient.birthDate.day);
            fittingConsultation = consultation;
            if (nextConsultationDate.isBefore(now)) {
              nextConsultationDate = now.add(const Duration(days: 7));
            }
            nextConsultations.add((nextConsultationDate, fittingConsultation));
          }
        }
      }
    }

    return nextConsultations;
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
                final nextConsultations = _nextConsultationDate(index);
                final currentPatient = index == 0 ? patient : children[index - 1];
                if (nextConsultations.isEmpty) {
                  return ConsultationCard(
                    consultation: Consultation.empty(),
                    patient: index == 0 ? patient : children[index - 1],
                    nextConsultationDate: DateTime(1970, 1, 1), 
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${currentPatient.firstName} ${currentPatient.lastName}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: nextConsultations.length,
                                itemBuilder: (context, consultationIndex) {
                                  final (nextConsultationDate, consultation) = nextConsultations[consultationIndex];

                                  return ConsultationCard(
                                    consultation: consultation ?? Consultation.empty(),
                                    patient: currentPatient,
                                    nextConsultationDate: nextConsultationDate,
                                    onBookingSuccess: () {
                                      setState(() {
                                        consultationsFuture = _loadPatientAndConsultations();
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}