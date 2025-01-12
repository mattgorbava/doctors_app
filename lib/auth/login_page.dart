import 'package:doctors_app/auth/register_screen.dart';
import 'package:doctors_app/doctor/doctor_home_page.dart';
import 'package:doctors_app/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    double topPadding = 0.1 * MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          automaticallyImplyLeading: false,
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator(),) : 
        SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                spacing: 10,
                children: [
                  SizedBox(height: 48,),
                  Image.asset('lib/assets/images/doctors_symbol.png', height: 200,),
                  SizedBox(height: 10,),
                  Text('Welcome', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600),),
                  Text('Login to continue', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w400),),
                  SizedBox(height: 60,),
                  SizedBox(
                    height: 44,
                    child: TextFormField(
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 191, 230, 191),
                        labelText: 'Email',
                        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF84c384),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF58ab58),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF84c384),
                            width: 1,
                          ),
                        ),
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
                  SizedBox(
                    height: 44,
                    child: TextFormField(
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 191, 230, 191),
                        labelText: 'Password',
                        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF84c384),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF58ab58),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF84c384),
                            width: 1,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.grey.shade400,),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureText,
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value!= null && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B962B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterPage()));
                      },
                      child: Text('Register new account', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),),
                    ),
                  ),
                ],
               )
            ),
          ),
        )
      ),
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
