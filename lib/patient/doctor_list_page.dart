import 'package:doctors_app/patient/doctor_details_page.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/doctor/widget/doctor_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key, required this.doctors});
  
  final List<Doctor> doctors;

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {

  String _selectedCategory = 'Cardiologist';

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
              'Find your doctor, \nand book an appointment',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            Text(
              'Find doctor by category',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              _buildCategoryCard(context, 'Cardiologist', 'lib/assets/images/cardiology.png'),
              _buildCategoryCard(context, 'Dentist', 'lib/assets/images/dentist.png'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildCategoryCard(context, 'Oncologist', 'lib/assets/images/oncology.png'),],
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

Widget _buildCategoryCard(BuildContext context, String title, dynamic icon,
    {bool isHighlighed = false}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    decoration: BoxDecoration(
        color: isHighlighed ? const Color(0xFF2B962B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isHighlighed
            ? null
            : Border.all(color: const Color(0xffC8C4FF), width: 2)),
    child: Card(
      color: isHighlighed ? const Color(0xFF2B962B) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 40,
                color: isHighlighed ? Colors.white : Colors.white,
              )
            else
              Image.asset(
                icon,
                width: 40,
                height: 40,
              ),
            const SizedBox(
              height: 16,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isHighlighed ? Colors.white : const Color(0xFF2B962B),
              ),
            )
          ],
        ),
      ),
    ),
  );
}