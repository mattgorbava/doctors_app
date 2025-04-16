import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:doctors_app/cabinet/cabinet_location_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class RegisterCabinetPage extends StatefulWidget {
  const RegisterCabinetPage({super.key});

  @override
  State<RegisterCabinetPage> createState() => _RegisterCabinetPageState();
}

class _RegisterCabinetPageState extends State<RegisterCabinetPage> {
  String _cabinetName = '';
  String _cabinetPhotoUrl = '';
  LatLng? _cabinetLocation;
  String? _cabinetAddress;
  int _cabinetCapacity = 0;
  String? _cabinetOpeningTime;
  String? _cabinetClosingTime;

  final _openingTimeController = TextEditingController();
  final _closingTimeController = TextEditingController();
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  final cloudinary = CloudinaryPublic(
      '',
      'doctors-app',
      cache: false,
  );

  @override
  void dispose() {
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectOpening() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        _cabinetOpeningTime = selectedTime.format(context);
        _openingTimeController.text = _cabinetOpeningTime!;
      });
    }
  }

  Future<void> _selectClosing() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        _cabinetClosingTime = selectedTime.format(context);
        _closingTimeController.text = _cabinetClosingTime!;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude 
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _cabinetAddress = place.street.toString();
        });
      }
    } catch (e) {
      setState(() {
        _cabinetAddress = 'Could not get address';
      });
    }
  }

  Future<void> _registerCabinet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_imageFile != null) {
          try {
            CloudinaryResponse response = await cloudinary.uploadFile(
                CloudinaryFile.fromFile(
                  _imageFile!.path,
                  folder: 'cabinets', 
                ),
              );
              _cabinetPhotoUrl = response.secureUrl;
          } catch (e) {
            _showErrorDialog('Failed to upload image');
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        Map<String, dynamic> cabinetData = {
          'name': _cabinetName,
          'image': _cabinetPhotoUrl,
          'doctorId': FirebaseAuth.instance.currentUser!.uid,
          'location': {
            'latitude': _cabinetLocation!.latitude,
            'longitude': _cabinetLocation!.longitude,
          },
          'address': _cabinetAddress,
          'capacity': _cabinetCapacity,
          'numberOfPatients': 0,
          'rating': 0,
          'totalReviews': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'openingTime': _cabinetOpeningTime,
          'closingTime': _cabinetClosingTime,
        };

        String cabinetId = FirebaseDatabase.instance.ref().child('Cabinets').push().key!;
        await FirebaseDatabase.instance.ref().child('Cabinets').child(cabinetId).set(cabinetData);

        Navigator.of(context).pop();
      } catch (e) {
        _showErrorDialog('Failed to register cabinet');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('An error occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
      },
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
          title: Text('Register Cabinet', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500)),
          automaticallyImplyLeading: true,
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator(),)
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  spacing: 10,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 44,
                      child: TextFormField(
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 191, 230, 191),
                          labelText: 'Cabinet name',
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
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          _cabinetName = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cabinet name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 44,
                      child: TextFormField(
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(255, 191, 230, 191),
                          labelText: 'Cabinet patients capacity',
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
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _cabinetCapacity = int.parse(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty || int.parse(value) <= 0) {
                            return 'Please enter capacity';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: TextFormField(
                              controller: _openingTimeController,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color.fromARGB(255, 191, 230, 191),
                                labelText: 'Cabinet opening time',
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
                              readOnly: true,
                              onTap: _selectOpening,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select opening time';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: TextFormField(
                              controller: _closingTimeController,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color.fromARGB(255, 191, 230, 191),
                                labelText: 'Cabinet closing time',
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
                              readOnly: true,
                              onTap: _selectClosing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select closing time';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(100), 
                    child: _imageFile != null ? Image.file(
                      File(_imageFile!.path),
                      width: 100, 
                      height: 100,
                      fit: BoxFit.cover,)
                    : Container(
                        color: const Color(0xffF0EFFF), 
                        width: 100, 
                        height: 100,
                        child: Center(
                          child: Icon(Icons.add_a_photo, color: Colors.grey.shade600, size: 30,),
                            ),
                          ),
                      ),
                    ),
                    _imageFile == null ? const Text('Pick an image') 
                    : const SizedBox.shrink(),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 0.5 * MediaQuery.of(context).size.width,
                      height: 50,
                      child: Row(
                        children: [
                          Icon(Icons.map, color: Colors.grey.shade600, size: 30,),
                          ElevatedButton(
                            onPressed: () async { 
                              final result = await Navigator.of(context).push<LatLng>( 
                                MaterialPageRoute(builder: (context) => const CabinetLocationPicker())
                              );
                              if (result != null) {
                                setState(() {
                                  _cabinetLocation = result;
                                });
                                _getAddressFromLatLng(_cabinetLocation!);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B962B),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Open map', style: TextStyle(fontSize: 16, color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    _cabinetLocation == null 
                  ? Text(
                      'Choose cabinet location', 
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 191, 230, 191),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF84c384)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cabinet location:',
                            style: GoogleFonts.poppins(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coordinates: ${_cabinetLocation!.latitude.toStringAsFixed(6)}, ${_cabinetLocation!.longitude.toStringAsFixed(6)}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Address: ${_cabinetAddress ?? "Loading..."}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: _registerCabinet,
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
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}