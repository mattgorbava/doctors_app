import 'package:doctors_app/auth/register_screen.dart';
import 'package:doctors_app/doctor/doctor_home_page.dart';
import 'package:doctors_app/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String email = '';
  String password = '';

  bool _isLoading = false;
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    double topPadding = 0.1 * MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : 
      Form(
        key: _formKey,
        child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: topPadding, bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterPage()));
                  },
                  child: const Text('Register new account'),
                ),
              ),
            ],
           )
        ),
      )
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
        );
        User? user = userCredential.user;

        if (user != null) {
          DatabaseReference userRef = _db.child('Doctors').child(user.uid);
          DataSnapshot snapshot = await userRef.get();
          
          if (snapshot.exists) {
            _navigateToDoctorHomePage();
          } else {
            userRef = _db.child('Patients').child(user.uid);
            snapshot = await userRef.get();
            if (snapshot.exists) {
              _navigateToPatientHomePage();
            } else {
              _showErrorDialog('User not found');
            }
          }
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password')));
      }

      setState(() {
        _isLoading = false;
      });
  }
}

  void _navigateToDoctorHomePage() {
    if (!_isNavigating) {
      _isNavigating = true;
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorHomePage()));
    }
  }
  
  void _navigateToPatientHomePage() {
    if (!_isNavigating) {
      _isNavigating = true;
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientHomePage()));
    }
  }
  
  void _showErrorDialog(String s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(s),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      }
    );
  }
}
