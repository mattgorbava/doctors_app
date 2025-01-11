import 'dart:io';

import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/doctor/doctor_home_page.dart';
import 'package:doctors_app/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();
  
  String userType = 'Patient';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String? city;
  String profileImageUrl = '';
  String category = '';
  String qualification = '';
  String yearsOfExperience = '';
  String latitude = '';
  String longitude = '';

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  
  bool _isLoading = false;
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
          title: Text('Register', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
        ),
        body: _isLoading ? CircularProgressIndicator() :
         Form(
           key: _formKey,
           child: SingleChildScrollView(
             child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                spacing: 10,
                children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select user type', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black,)),
                      Wrap(
                        spacing: 10,
                        children: ['Patient', 'Doctor'].map((String type) {
                          final isSelected = userType == type;
                          return ChoiceChip(
                            checkmarkColor: Colors.black,
                            label: Text(type, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),),
                            selected: isSelected,
                            selectedColor: Color.fromARGB(255, 41, 148, 41),
                            backgroundColor: Color.fromARGB(255, 191, 230, 191),
                            labelStyle: GoogleFonts.poppins(color: isSelected ? Colors.white : Color(0xFF58ab58)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? Color(0xFF58ab58) : Color(0xFF84c384),
                                width: 2,
                              ),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                userType = (selected ? type : userType);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
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
                SizedBox(
                  height: 44,
                  child: TextFormField(
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 191, 230, 191),
                      labelText: 'Phone number',
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
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      phoneNumber = value;
                    },
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Please enter phone number';
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
                      labelText: 'First name',
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
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      firstName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
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
                      labelText: 'Last name',
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
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      lastName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: DropdownButtonFormField<String>(
                    value: city,
                    items: ['Alba Iulia', 'Alexandria', 'Arad', 'Bacău', 'Baia Mare', 'Bistrița', 'Botoșani', 'Brașov', 'Brăila', 'București', 'Buzău', 'Călărași', 'Cluj-Napoca', 'Constanța', 'Craiova', 'Deva', 'Focșani', 'Galați', 'Giurgiu', 'Iași', 'Miercurea Ciuc', 'Oradea', 'Piatra Neamț', 'Pitești', 'Ploiești', 'Râmnicu Vâlcea', 'Reșița', 'Satu Mare', 'Sfântu Gheorghe', 'Sibiu', 'Slatina', 'Slobozia', 'Suceava', 'Târgu Jiu', 'Târgu Mureș', 'Târgoviște', 'Timișoara', 'Tulcea', 'Vaslui', 'Zalău'].map((String city) {
                    return DropdownMenuItem(value: city, child: Text(city, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),));
                  }).toList(), 
                  onChanged: (val){
                    setState (() {
                      city = val as String;
                    });
                  }, 
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 191, 230, 191),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    labelText: 'City',
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
                  validator: (val) => val == null ? 'Please select a city' : null,),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 20),
                //   child: ElevatedButton(onPressed: _pickImage,
                //   child: Text('Upload profile image')),
                // ),
                // _imageFile == null ? Text('No image selected') : Image.file(File(_imageFile!.path)),
                if(userType == 'Doctor') ... [
                  SizedBox(
                  height: 44,
                  child: TextFormField(
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 191, 230, 191),
                      labelText: 'Qualification',
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
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      qualification = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter qualification';
                      }
                      return null;
                    },
                  ),
                ),
                  DropdownButtonFormField(items: ['Dentist', 'Cardiology', 'Oncology', 'Surgeon'].map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      category = val as String;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 191, 230, 191),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    labelText: 'Category',
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
                  validator: (val) => val == null ? 'Select a category' : null,),
                  SizedBox(
                  height: 44,
                  child: TextFormField(
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 191, 230, 191),
                      labelText: 'Years of experience',
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
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      yearsOfExperience = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter years of experience';
                      }
                      return null;
                    },
                  ),
                ),
                ],
                SizedBox(height: 10,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _getLocation,
                    child: Text('Get current location', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2B962B),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                ),
                if(latitude != '0.0' && longitude != '0.0' && latitude != '' && longitude != '')
                  Text('Location: ($latitude, $longitude)'),
                SizedBox(height: 10,),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B962B),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white),),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text('Already have an account? Login', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),),
                  ),
                ),
              ],),
            ),
           ),
         )
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _getLocation() async {
    final locationData = await Location().getLocation();
    setState(() {
      latitude = locationData.latitude.toString();
      longitude = locationData.longitude.toString();
    });
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        User? user = userCredential.user;
         if (user != null) {
          String userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients';
          Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': email,
            'phoneNumber': phoneNumber,
            'firstName': firstName,
            'lastName': lastName,
            'city': city,
            'profileImageUrl': profileImageUrl,
            'latitude': latitude,
            'longitude': longitude,
          };

          if (userType == 'Doctor') {
            userData['qualification'] = qualification;
            userData['category'] = category;
            userData['yearsOfExperience'] = yearsOfExperience;
            userData['totalReviews'] = 0;
            userData['averageRating'] = 0.0;
            userData['numberOfReviews'] = 0;
          }

          await _db.child(userTypePath).child(user.uid).set(userData);

          // if (_imageFile != null) {
          //   Reference storageReference = FirebaseStorage.instance.ref()
          //       .child('$userTypePath/${user.uid}/profile.jpg');
          //   //UploadTask uploadTask = storageReference.putFile(File(_imageFile!.path));
          //   final TaskSnapshot taskSnapshot = await storageReference.putFile(File(_imageFile!.path));

          //   final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
          //   await _db.child(userTypePath).child(user.uid).update({
          //     'profileImageUrl': downloadUrl,
          //   });
          // }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  userType == 'Doctor' ? DoctorHomePage() : PatientHomePage(),
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('An error occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
      },
    );
  }
}