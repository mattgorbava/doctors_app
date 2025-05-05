import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/child.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/children_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RegisterChildPage extends StatefulWidget {
  const RegisterChildPage({super.key});

  @override
  State<RegisterChildPage> createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _formKey = GlobalKey<FormState>();

  final ChildrenService _childrenService = ChildrenService();

  final UserDataService _userDataService = UserDataService();
  late Patient parent;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cnpController = TextEditingController();
  DateTime _birthDate = DateTime.now();
  bool _isDateSelected = false;

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
        _isDateSelected = true;
      });
    }
  }

  bool _isDateValid(DateTime date) {
    DateTime today = DateTime.now();
    final difference = today.difference(date).inDays;
    return difference >= 0 && difference <= 365 * 18 - 1;
  }

  Future<void> _registerChild() async {
    if (_isDateSelected && !_isDateValid(_birthDate)) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
  
      Map<String, dynamic> childData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'cnp': _cnpController.text,
        'birthDate': _birthDate.toIso8601String(),
        'parentId': parent.uid,
      };

      bool added = false; 
      
      try {
        added = await _childrenService.addChild(childData);

        if (!mounted) return;

        if (added) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child registered successfully!')),
          );
          await _userDataService.loadChildren(_userDataService.patient!.uid);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to register child.')),
          );
        }
      } catch (e) {
        print('Error registering child: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register child.')),
        );
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
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
                    keyboardType: TextInputType.number,
                    maxLength: 13,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 13) {
                        return 'Please enter a valid CNP';
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
                  _isDateSelected ? _isDateValid(_birthDate) ? Text('Selected Date: ${DateFormat('yyyy-MM-dd').format(_birthDate)}',)
                  : const Text('Child must be a minor', style: TextStyle(color: Colors.red),)
                  : const Text('No date selected', style: TextStyle(color: Colors.red),),
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