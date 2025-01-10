import 'dart:io';

import 'package:doctors_app/doctor/doctor_home_page.dart';
import 'package:doctors_app/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  String city = '';
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

  @override
  Widget build(BuildContext context) {
    double topPadding = 0.1 * MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(children: [
              Padding(
                padding: EdgeInsets.only(top: topPadding,bottom: 20),
                child: DropdownButtonFormField(
                  value: userType,
                  items: ['Patient', 'Doctor'].map((String type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(), 
                onChanged: (val){
                  setState(() {
                    userType = val as String;
                  });
                },
                decoration: InputDecoration(labelText: 'User type'),),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => email = val,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  onChanged: (val) => password = val,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => phoneNumber = val,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    phoneNumber = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'First name',
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (val) => firstName = val,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    firstName = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Last name',
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (val) => lastName = val,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    lastName = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: DropdownButtonFormField(items: ['Alba Iulia', 'Alexandria', 'Arad', 'Bacău', 'Baia Mare', 'Bistrița', 'Botoșani', 'Brașov', 'Brăila', 'București', 'Buzău', 'Călărași', 'Cluj-Napoca', 'Constanța', 'Craiova', 'Deva', 'Focșani', 'Galați', 'Giurgiu', 'Iași', 'Miercurea Ciuc', 'Oradea', 'Piatra Neamț', 'Pitești', 'Ploiești', 'Râmnicu Vâlcea', 'Reșița', 'Satu Mare', 'Sfântu Gheorghe', 'Sibiu', 'Slatina', 'Slobozia', 'Suceava', 'Târgu Jiu', 'Târgu Mureș', 'Târgoviște', 'Timișoara', 'Tulcea', 'Vaslui', 'Zalău'].map((String city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(), 
                onChanged: (val){
                  setState (() {
                    city = val as String;
                  });
                }, 
                decoration: InputDecoration(labelText: 'City'),
                validator: (val) => val == null ? 'Please select a city' : null,),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(onPressed: _pickImage,
                child: Text('Upload profile image')),
              ),
              _imageFile == null ? Text('No image selected') : Image.file(File(_imageFile!.path)),
              if(userType == 'Doctor') ... [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Qualification',
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (val) => category = val,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      category = value!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Qualification',
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (val) => qualification = val,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter qualification';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      qualification = value!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: DropdownButtonFormField(items: ['Dentist', 'Cardiology', 'Oncology', 'Surgeon'].map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      category = val as String;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (val) => val == null ? 'Select a category' : null,),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Years of experience',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => yearsOfExperience = val,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter years of experience';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      yearsOfExperience = value!;
                    },
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(onPressed: _getLocation, child: Text('Get current location')),
              ),
              if(latitude != '0.0' && longitude != '0.0' && latitude != '' && longitude != '')
                Text('Location: ($latitude, $longitude)'),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(onPressed: _registerUser, child: Text('Register')),
              ),
            ],),
          )
        ),
      )
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

          if (_imageFile != null) {
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('$userTypePath/${user.uid}/profile.jpg');
            UploadTask uploadTask =
                storageReference.putFile(File(_imageFile!.path));
            TaskSnapshot taskSnapshot = await uploadTask;

            String downloadUrl = await taskSnapshot.ref.getDownloadURL();
            await _db.child(userTypePath).child(user.uid).update({
              'profileImageUrl': downloadUrl,
            });
          }

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