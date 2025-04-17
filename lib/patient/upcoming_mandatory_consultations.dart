import 'dart:convert';

import 'package:doctors_app/model/booking.dart';
import 'package:doctors_app/model/consultation.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/patient/consultation_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class UpcomingMandatoryConsultations extends StatefulWidget {
  const UpcomingMandatoryConsultations({super.key, required this.patientId});

  final String patientId;

  @override
  State<UpcomingMandatoryConsultations> createState() => _UpcomingMandatoryConsultationsState();
}

class _UpcomingMandatoryConsultationsState extends State<UpcomingMandatoryConsultations> {
  late List<Consultation> consultations = [];

  late Patient patient;

  late Future<List<Consultation>> consultationsFuture;

  late List<Booking> bookings = [];

  Future<List<Consultation>> _loadConsultations() async {
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
        return consultationsJson.map((consultation) => Consultation.fromMap(consultation)).toList();
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
          return consultationsJson.map((consultation) => Consultation.fromMap(consultation)).toList();
        } catch (e) {
          print('JSON format not recognized: $e');
          return [];
        }
      }
    } catch (e) {
      print('Error loading consultations: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not get consultations.'),
        backgroundColor: Colors.red,
      ));
      return [];
    }
  }

  Future<void> _fetchBookings() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref()
        .child('Bookings')
        .orderByChild('patientId')
        .equalTo(widget.patientId)
        .once();
      if (snapshot.snapshot.value == null) {
        throw Exception('Bookings data is null');
      }
      final value = snapshot.snapshot.value as Map<dynamic, dynamic>;
      setState() {
        bookings = value.entries.map((entry) {
          return Booking.fromMap(Map<String, dynamic>.from(entry.value), entry.key);
        }).toList();
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not get bookings.'),
        backgroundColor: Colors.red,
      ));
    }
  } 

  Future<void> _fetchPatient() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref().child('Patients').child(widget.patientId).once();
      
      if (snapshot.snapshot.value == null) {
        throw Exception('Patient data is null');
      }
      
      final value = snapshot.snapshot.value as Map<dynamic, dynamic>;
      
      setState(() {
        patient = Patient.fromMap(Map<String, dynamic>.from(value), snapshot.snapshot.key!);
      });
    } catch (e) {
      print('Error fetching patient: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not get patient details.'),
        backgroundColor: Colors.red,
      ));
      rethrow;
    }
  }

  Future<List<Consultation>> _loadPatientAndConsultations() async {
    await _fetchPatient();
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

  @override
  void initState() {
    super.initState();
    consultationsFuture = _loadPatientAndConsultations();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Mandatory Consultations'),
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
                return ConsultationCard(consultation: consultation, patient: patient);
              },
            );
          }
        },
      ),
    );
  }
}