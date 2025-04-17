import 'package:doctors_app/model/booking.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddMedicalHistoryPage extends StatefulWidget {
  const AddMedicalHistoryPage({
    super.key, 
    required this.bookingId, 
    required this.isMandatory, 
  });

  final String bookingId;
  final bool isMandatory;

  @override
  State<AddMedicalHistoryPage> createState() => _AddMedicalHistoryPageState();
}

class _AddMedicalHistoryPageState extends State<AddMedicalHistoryPage> {
  final _resultsController = TextEditingController();
  final _recommendationsController = TextEditingController();

  bool _addAnalysis = false;
  String? newStatus = 'Confirmed';

  Future<void> _saveMedicalHistory() async {
    try {
      await FirebaseDatabase.instance.ref('MedicalHistory').push().set({
        'bookingId': widget.bookingId,
        'results': _resultsController.text,
        'recommendations': _recommendationsController.text,
        'dateAdded': DateTime.now().toIso8601String(),
        'analysisResultsPdfUrl': '',
      });
      if (_addAnalysis) {
        newStatus = 'AnalysisPending';
      } else {
        newStatus = 'Completed';
      }
      Navigator.of(context).pop(newStatus);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not save medical history.'),
        backgroundColor: Colors.red,
      ));
    }
    
    Navigator.of(context).pop(true);
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
              decoration: const InputDecoration(labelText: 'Results'),
              controller: _resultsController,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Recommendations'),
              controller: _recommendationsController,
            ),
            const SizedBox(height: 20),
            if (widget.isMandatory) 
              Row(
                children: [
                  const Text('Add Analysis'),
                  const SizedBox(width: 10),
                  Checkbox(
                    value: _addAnalysis,
                    onChanged: (bool? value) {
                      setState(() {
                        _addAnalysis = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveMedicalHistory();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}