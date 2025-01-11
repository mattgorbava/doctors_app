import 'package:doctors_app/doctor/doctor_list_page.dart';
import 'package:doctors_app/user_profile.dart';
import 'package:flutter/material.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    DoctorListPage(),
    //ChatListPage(), daca mai am timp
    UserProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      color: Colors.white,
      child: const Center(
        child: Text(
          'Patient Home Page',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
    ),
    );
  }
}