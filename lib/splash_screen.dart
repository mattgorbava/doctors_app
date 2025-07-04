import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/doctor/doctor_home_page.dart';
import 'package:doctors_app/no_internet_screen.dart';
import 'package:doctors_app/patient/patient_home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  final bool internetConnection = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (result[0] == ConnectivityResult.none) {
      setState(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NoInternetScreen()),
        );
      });
    } else {
      _checkAuthUser();
    }
  }

  Future<void> _checkAuthUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (!rememberMe) {
      await FirebaseAuth.instance.signOut();
    }

    User? user = _auth.currentUser;

    if (user == null) {
      await Future.delayed(const Duration(seconds: 3));
      _navigateToLogin();
    } else {
      DatabaseReference userRef = _db.child('Doctors').child(user.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        await Future.delayed(const Duration(seconds: 3));  
        _navigateToDoctorHomePage();
      } else {
        userRef = _db.child('Patients').child(user.uid);
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
    double textPosition = MediaQuery.of(context).size.height * 0.1;
    double imagePosition = MediaQuery.of(context).size.height * 0.2;

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: textPosition),
              child: Text('Doctors App', style: GoogleFonts.poppins(fontSize: 24, color: Colors.black, fontWeight: FontWeight.normal),),
            ),
            Padding(
              padding: EdgeInsets.only(top: imagePosition),
              child: Image.asset('lib/assets/images/doctors_symbol.png', height: 300, width: MediaQuery.of(context).size.width * 0.7, alignment: Alignment.center,),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20), 
              child: CircularProgressIndicator(),
            ),
          ]
        )
      )
    );

  }
  void _navigateToPatientHomePage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PatientHomePage()));
  }

  void _navigateToDoctorHomePage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DoctorHomePage()));
  }

  void _navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }
}
