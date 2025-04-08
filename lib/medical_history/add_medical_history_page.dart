import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddMedicalHistoryPage extends StatefulWidget {
  const AddMedicalHistoryPage({super.key, required this.patientId, required this.doctorId});

  final String patientId;
  final String doctorId;

  @override
  State<AddMedicalHistoryPage> createState() => _AddMedicalHistoryPageState();
}

class _AddMedicalHistoryPageState extends State<AddMedicalHistoryPage> {
  final _reasonController = TextEditingController();
  final _resultsController = TextEditingController();
  final _recommendationsController = TextEditingController();
  String? checkUpType; // routine, emergency, tests

  Future<void> _saveMedicalHistory() async {
    try {
      await FirebaseDatabase.instance.ref('MedicalHistory').push().set({
        'doctorId': widget.doctorId,
        'patientId': widget.patientId,
        'date': DateTime.now().toIso8601String(),
        'reason': _reasonController.text,
        'results': _resultsController.text,
        'recommendations': _recommendationsController.text,
        'checkUpType': checkUpType,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not save medical history.'),
        backgroundColor: Colors.red,
      ));
    }
    
    Navigator.pop(context); // Close the page after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medical History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Reason for Visit'),
              controller: _reasonController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Results'),
              controller: _resultsController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Recommendations'),
              controller: _recommendationsController,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 60,
              child: DropdownButtonFormField<String>(
                value: checkUpType,
                decoration: const InputDecoration(
                  labelText: 'Check-Up Type',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Routine', 'Emergency', 'Tests'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    checkUpType = newValue;
                  });
                },
              )
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveMedicalHistory();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}