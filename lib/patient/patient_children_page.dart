import 'package:doctors_app/model/child.dart';
import 'package:doctors_app/patient/register_child_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientChildrenPage extends StatefulWidget {
  const PatientChildrenPage({super.key});

  @override
  State<PatientChildrenPage> createState() => _PatientChildrenPageState();
}

class _PatientChildrenPageState extends State<PatientChildrenPage> {
  List<Child> _children = [];
  String patientId = FirebaseAuth.instance.currentUser?.uid ?? '';

  DatabaseReference _childrenRef = FirebaseDatabase.instance.ref().child('Children');

  Future<void> _loadChildren() async {
    try {
      await _childrenRef.orderByChild('parentId').equalTo(patientId).once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        List<Child> children = [];

        if (snapshot.value != null) {
          Map<dynamic, dynamic> childrenMap = snapshot.value as Map<dynamic, dynamic>;
          childrenMap.forEach((key, value) {
            children.add(Child.fromMap(Map<String, dynamic>.from(value), key));
          });
        }

        setState(() {
          _children = children;
        });
      });
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not get children.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children'),
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
                      onPressed: () => 
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RegisterChildPage(),
                      )),
                      icon: const Icon(Icons.add),
                      label: const Text('Register Child'),
                    ),
                  ],
                ),
              )
            : Column(
              children: [
                ListView.builder(
                  itemCount: _children.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${_children[index].firstName} ${_children[index].lastName}'),
                      subtitle: Text('Age: ${DateFormat('dd-MM-yyyy').format(_children[index].birthDate)}'),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => 
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RegisterChildPage(),
                  )),
                  icon: const Icon(Icons.add),
                  label: const Text('Register Child'),
                ),
              ],
            ),
              
      ),
    );
  }
}