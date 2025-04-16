import 'package:doctors_app/booking/book_appointment_page.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/consultation.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsultationCard extends StatelessWidget {
  const ConsultationCard({super.key, required this.consultation, required this.patient});

  final Consultation consultation;
  final Patient patient;

  Future<Cabinet> _fetchCabinet(String cabinetId) async {
   try {
      DatabaseReference cabinetRef = FirebaseDatabase.instance.ref().child('Cabinets').child(cabinetId);
      DataSnapshot snapshot = await cabinetRef.get();
      if (snapshot.exists) {
        final value = snapshot.value as Map<dynamic, dynamic>;
        final Cabinet cabinet = Cabinet.fromMap(Map<String, dynamic>.from(value), cabinetId);
        return cabinet;
      } else {
        throw Exception('Cabinet not found');
      }
    } catch (e) {
      print('Error fetching cabinet: $e');
      throw Exception('Error fetching cabinet');
    }
  }

  int _ageInMonths(Patient patient) {
    DateTime date = patient.birthDate;
    DateTime now = DateTime.now();
    int ageInMonths = (now.year - date.year) * 12 + now.month - date.month;
    return ageInMonths;
  }

  DateTime _nextConsultationDate(DateTime date) {
    int patientAgeInMonths = _ageInMonths(patient);
    int consultationPeriod = consultation.periodInMonths;
    int monthsUntilNextConsultation = consultationPeriod - (patientAgeInMonths % consultationPeriod);

    DateTime now = DateTime.now();
    DateTime nextConsultationDate = DateTime(now.year, now.month + monthsUntilNextConsultation, date.day);
    return nextConsultationDate;
  }

  @override
  Widget build(BuildContext context) {
    DateTime nextConsultationDate = _nextConsultationDate(patient.birthDate);
    String formattedDate = DateFormat('dd/MM/yyyy').format(nextConsultationDate);
    return FutureBuilder<Cabinet>(
      future: _fetchCabinet(patient.cabinetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading cabinet'));
        } else if (snapshot.hasData) {
          Cabinet cabinet = snapshot.data!;
          return Card(
            child: ListTile(
              title: Text(consultation.title),
              subtitle: Text('Next Consultation: ${formattedDate}'),
              trailing: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BookAppointmentPage(
                        patient: patient,
                        cabinet: cabinet,
                        desiredDate: nextConsultationDate,
                        description: consultation.title,
                      ),
                    ));
                  },
                  child: const Text('Book'),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}