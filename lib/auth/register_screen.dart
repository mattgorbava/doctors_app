import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _userType = 'Patient';
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
  
  @override
  Widget build(BuildContext context) {
    double topPadding = 0.1 * MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(children: [
          DropdownButtonFormField(
            value: _userType,
            items: ['Patient', 'Doctor'].map((String type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(), 
          onChanged: (val){
            setState(() {
              _userType = val as String;
            });
          },
          decoration: InputDecoration(labelText: 'User type'),),
          TextFormField(
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
          TextFormField(
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
          TextFormField(
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
          TextFormField(
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
          TextFormField(
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
          DropdownButtonFormField(items: ['Brasov', 'Bucuresti'].map((String type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(), 
          onChanged: (val){
            setState (() {
              city = val as String;
            });
          }, 
          decoration: InputDecoration(labelText: 'City'),
          validator: (val) => val == null ? 'Please select a city' : null,),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Profile image URL',
            ),
            keyboardType: TextInputType.text,
            onChanged: (val) => profileImageUrl = val,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter profile image URL';
              }
              return null;
            },
            onSaved: (value) {
              profileImageUrl = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Category',
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
          TextFormField(
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
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Years of experience',
            ),
            keyboardType: TextInputType.text,
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
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Latitude',
            ),
            keyboardType: TextInputType.text,
            onChanged: (val) => latitude = val,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter latitude';
              }
              return null;
            },
            onSaved: (value) {
              latitude = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Longitude',
            ),
            keyboardType: TextInputType.text,
            onChanged: (val) => longitude = val,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter longitude';
              }
              return null;
            },
            onSaved: (value) {
              longitude = value!;
            },
          ),
        ],)
      )
    );
  }
}