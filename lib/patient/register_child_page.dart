import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterChildPage extends StatefulWidget {
  const RegisterChildPage({super.key});

  @override
  State<RegisterChildPage> createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _formKey = GlobalKey<FormState>();

  final DatabaseReference _childrenRef = FirebaseDatabase.instance.ref('Children');

  final UserDataService _userDataService = UserDataService();
  late Patient parent;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cnpController = TextEditingController();
  DateTime _birthDate = DateTime.now();

  bool _isLoading = false;

  Future<void> _getDateOfBirth() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null && selectedDate != _birthDate) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }

  Future<void> _registerChild() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
  
      if (_childrenRef != null) {
        final snapshot = await _childrenRef
          .orderByChild('cnp')
          .equalTo(_cnpController.text)
          .once();
        
        if (snapshot.snapshot.value != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('A child with this CNP already exists.'),
            backgroundColor: Colors.red,
          ));
          setState(() {
            _isLoading = false;
          });
          return;
        } else {
          
          
          _childrenRef.push().set({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'cnp': _cnpController.text,
            'birthDate': _birthDate.toIso8601String(),
            'parentId': parent.uid,
            'cabinetId': '',
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Child registered successfully.'),
              backgroundColor: Colors.green,
            ));
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ));
          });
        }
      }

      Navigator.pop(context);
    } else
    {
      setState(() {
        _isLoading = true;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    parent = _userDataService.patient!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Register Child', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
          automaticallyImplyLeading: true,
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator(),) :
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the last name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cnpController,
                    decoration: const InputDecoration(labelText: 'CNP'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the CNP';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _getDateOfBirth,
                    child: Text('Select Date of Birth', style: GoogleFonts.poppins(fontSize: 16),),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerChild,
                    child: Text('Register Child', style: GoogleFonts.poppins(fontSize: 16),),
                  ),
                ],
              ),
            )
        ),
      )
    );
  }
}