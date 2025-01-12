import 'package:doctors_app/doctor/doctor_details_page.dart';
import 'package:doctors_app/doctor/model/doctor.dart';
import 'package:doctors_app/doctor/widget/doctor_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {

  final DatabaseReference _doctorRef = FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  String _selectedCategory = 'Cardiologist';

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : 
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 30,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
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
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorDetailsPage(doctor: _doctors[index]),),
                      );
                    },
                    child: DoctorCard(doctor: _doctors[index])
                  );
                },
              )
            )
          ],
        )
      )
    );
  }
  
  
  
  Future<void> _fetchDoctors() async {
    await _doctorRef.once().then((DatabaseEvent event){
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> doctors = [];
      if(snapshot.value != null){
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctorMap = Doctor.fromMap(value, key);
          doctors.add(doctorMap);
        });
      }
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    });
  }
}

Widget _buildCategoryCard(BuildContext context, String title, dynamic icon,
    {bool isHighlighed = false}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    decoration: BoxDecoration(
        color: isHighlighed ? Color(0xFF2B962B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isHighlighed
            ? null
            : Border.all(color: Color(0xffC8C4FF), width: 2)),
    child: Card(
      color: isHighlighed ? Color(0xFF2B962B) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
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
            SizedBox(
              height: 16,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isHighlighed ? Colors.white : Color(0xFF2B962B),
              ),
            )
          ],
        ),
      ),
    ),
  );
}