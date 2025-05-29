import 'package:doctors_app/doctor/doctor_details_page.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/widgets/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key, required this.doctors});
  
  final List<Doctor> doctors;

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 30,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              LocaleData.findDoctorPrompt.getString(context),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.doctors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorDetailsPage(doctor: widget.doctors[index]),),
                      );
                    },
                    child: DoctorCard(doctor: widget.doctors[index])
                  );
                },
              )
            )
          ],
        )
      )
    );
  }
}