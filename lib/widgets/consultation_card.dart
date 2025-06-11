import 'package:doctors_app/booking/book_appointment_page.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/consultation.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/cabinet_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsultationCard extends StatelessWidget {
  ConsultationCard({
    super.key,
    required this.consultation, 
    required this.patient,
    required this.nextConsultationDate,
    this.onBookingSuccess,
  });

  final CabinetService _cabinetService = CabinetService();
  final Consultation consultation;
  final Patient patient;
  final DateTime nextConsultationDate;
  final UserDataService _userDataService = UserDataService();
  final VoidCallback? onBookingSuccess;

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(nextConsultationDate);
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 196, 255, 209)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: consultation.isNotEmpty 
      ? Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Text(
                '${patient.firstName} ${patient.lastName}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
            ListTile(
              title: Text(consultation.title),
              subtitle: Text('Next Consultation: $formattedDate'),
              trailing: SizedBox(
                width: 100,
                child: _userDataService.cabinet != null && patient.cabinetId.isNotEmpty ?
                 ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BookAppointmentPage(
                        patient: patient,
                        cabinet: _userDataService.cabinet!,
                        desiredDate: nextConsultationDate,
                        description: consultation.title,
                      ),
                    ));
                  },
                  child: const Text('Book'),
                )
                : _userDataService.cabinet== null && patient.cabinetId.isNotEmpty
                ? FutureBuilder(
                  future: _cabinetService.getCabinetById(patient.cabinetId),
                  initialData: null,
                  builder: (context, asyncSnapshot) {
                    return ElevatedButton(
                      onPressed: () async {
                        if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                          final result = await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BookAppointmentPage(
                              patient: patient,
                              cabinet: asyncSnapshot.data!,
                              desiredDate: nextConsultationDate,
                              description: consultation.title,
                            ),
                          ));
                          if (result == true && onBookingSuccess != null) {
                            onBookingSuccess!();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cabinet not found!'))
                          );
                        }
                      },
                      child: const Text('Book'),
                    );
                  }
                )
                : const Text('Register to cabinet first!',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      )
      : Card(
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(),
            child: Text(
              '${patient.firstName} ${patient.lastName}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
          subtitle: const Text('No consultations available'),
        ),
      ),
    );
  }
}