import 'package:doctors_app/doctor/doctor_home_page.dart';
import 'package:doctors_app/patient/patient_home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _checkAuthUser();
  }

  Future<void> _checkAuthUser() async {
    User? user = _auth.currentUser;

    if (user == null) {
      await Future.delayed(const Duration(seconds: 3));
      _navigateToLogin();
    } else {
      DatabaseReference userRef = _db.child('Doctor').child(user.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        await Future.delayed(const Duration(seconds: 3));  
        _navigateToDoctorHomePage();
      } else {
        userRef = _db.child('Patient').child(user.uid);
        snapshot = await userRef.get();
        if (snapshot.exists) {
          await Future.delayed(const Duration(seconds: 3));  
          _navigateToPatientHomePage();
        } else {
          await Future.delayed(const Duration(seconds: 3));
          _navigateToLogin();
        }
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text(
          'Splash Screen',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
    );

  }
  void _navigateToPatientHomePage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientHomePage()));
  }

  void _navigateToDoctorHomePage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorHomePage()));
  }

  void _navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
