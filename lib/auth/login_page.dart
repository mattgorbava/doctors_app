import 'package:doctors_app/auth/register_screen.dart';
import 'package:doctors_app/doctor/doctor_home_page.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/patient/patient_home_page.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final UserDataService _userDataService = UserDataService();

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  bool _isLoading = false;
  bool _isNavigating = false;

  bool _obscureText = true;
  bool _rememberMe = false;

  late String language;
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    language = localization.currentLocale?.languageCode ?? 'en';
    if (language != 'en' && language != 'ro') {
      language = 'en';
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _saveRememberMePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        User? user = userCredential.user;

        if (user != null) {
          DatabaseReference userRef = _db.child('Doctors').child(user.uid);
          DataSnapshot snapshot = await userRef.get();
          _saveRememberMePreference(_rememberMe);
          
          if (snapshot.exists) {
            _navigateToDoctorHomePage();
            _userDataService.loadDoctorData();
          } else {
            userRef = _db.child('Patients').child(user.uid);
            snapshot = await userRef.get();
            if (snapshot.exists) {
              _navigateToPatientHomePage();
              _userDataService.loadPatientData();
            } else {
              _showErrorDialog('User not found');
            }
          }
        }
      } catch (e) {
        if (!mounted) return;
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
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DoctorHomePage()));
    }
  }
  
  void _navigateToPatientHomePage() {
    if (!_isNavigating) {
      _isNavigating = true;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const PatientHomePage()));
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

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleData.login.getString(context), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (language != 'ro') {
                        setState(() {
                          language = 'ro';
                          localization.translate('ro');
                        });
                      }
                    },
                    child: Text(
                      'RO',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: language == 'ro' ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '|',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey, // Separator color
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (language != 'en') {
                        setState(() {
                          language = 'en';
                          localization.translate('en');
                        });
                      }
                    },
                    child: Text(
                      'EN',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: language == 'en' ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  const SizedBox(height: 48,),
                  Image.asset('lib/assets/images/doctors_symbol.png', height: 200,),
                  const SizedBox(height: 10,),
                  Text(LocaleData.welcome.getString(context), style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),),
                  Text(LocaleData.loginToContinue.getString(context), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w400),),
                  const SizedBox(height: 60,),
                  SizedBox(
                    height: 44,
                    child: TextFormField(
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      onFieldSubmitted: (value) {
                        _passwordFocusNode.requestFocus();
                      },
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 191, 230, 191),
                        labelText: 'Email',
                        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF84c384),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF58ab58),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF84c384),
                            width: 1,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocaleData.emailValidationError.getString(context);
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: TextFormField(
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      focusNode: _passwordFocusNode,
                      onFieldSubmitted: (value) => _login(),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 191, 230, 191),
                        labelText: LocaleData.password.getString(context),
                        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF84c384),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF58ab58),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
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
                      validator: (value) {
                        if (value!= null && value.length < 6) {
                          return LocaleData.passwordValidationError.getString(context);
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),
                  CheckboxListTile(
                    title: Text(LocaleData.rememberMe.getString(context), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
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
                      child: Text(LocaleData.login.getString(context), style: const TextStyle(fontSize: 16, color: Colors.white),),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterPage()));
                      },
                      child: Text(LocaleData.registerNewAccount.getString(context), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),),
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

  
}
