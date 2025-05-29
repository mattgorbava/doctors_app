import 'package:doctors_app/auth/register_screen.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:doctors_app/widgets/child_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class PatientChildrenPage extends StatefulWidget {
  const PatientChildrenPage({super.key});

  @override
  State<PatientChildrenPage> createState() => _PatientChildrenPageState();
}

class _PatientChildrenPageState extends State<PatientChildrenPage> with AutomaticKeepAliveClientMixin<PatientChildrenPage> {
  @override
  bool get wantKeepAlive => true;

  List<Patient> _children = [];
  String patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final UserDataService _userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    if (_userDataService.children != null && _userDataService.children!.isNotEmpty) {
      _children = _userDataService.children!;
    }
  }

  void _navigateAndRegisterChild() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage(isChild: true,)),
    );

    setState(() {
      if (_userDataService.children != null && _userDataService.children!.isNotEmpty) {
        _children = _userDataService.children!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.childrenTitle.getString(context)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: (_children.isEmpty)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleData.noChildrenFound.getString(context)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _navigateAndRegisterChild(),
                      icon: const Icon(Icons.add),
                      label: Text(LocaleData.registerChildButton.getString(context)),
                    ),
                  ],
                ),
              )
            : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _children.length,
                    itemBuilder: (context, index) {
                      return ChildCard(child: _children[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _navigateAndRegisterChild(),
                  icon: const Icon(Icons.add),
                  label: Text(LocaleData.registerChildButton.getString(context)),
                ),
              ],
            ),
              
      ),
    );
  }
}