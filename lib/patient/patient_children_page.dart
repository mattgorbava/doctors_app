import 'package:doctors_app/model/child.dart';
import 'package:doctors_app/patient/register_child_page.dart';
import 'package:doctors_app/services/children_service.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientChildrenPage extends StatefulWidget {
  const PatientChildrenPage({super.key});

  @override
  State<PatientChildrenPage> createState() => _PatientChildrenPageState();
}

class _PatientChildrenPageState extends State<PatientChildrenPage> with AutomaticKeepAliveClientMixin<PatientChildrenPage> {
  @override
  bool get wantKeepAlive => true;

  List<Child> _children = [];
  String patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final UserDataService _userDataService = UserDataService();
  final ChildrenService _childrenService = ChildrenService();

  DatabaseReference _childrenRef = FirebaseDatabase.instance.ref().child('Children');

  @override
  void initState() {
    super.initState();
    _children = _userDataService.children;
  }

  void _navigateAndRegisterChild() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RegisterChildPage()),
    );

    if (mounted && result == true) {
      setState(() {
        _children = _userDataService.children;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: (_children.isEmpty)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No children found.'),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _navigateAndRegisterChild(),
                      icon: const Icon(Icons.add),
                      label: const Text('Register Child'),
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
                      return ListTile(
                        title: Text('${_children[index].firstName} ${_children[index].lastName}'),
                        subtitle: Text('Birth date: ${DateFormat('dd-MM-yyyy').format(_children[index].birthDate)}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _navigateAndRegisterChild(),
                  icon: const Icon(Icons.add),
                  label: const Text('Register Child'),
                ),
              ],
            ),
              
      ),
    );
  }
}