import 'package:doctors_app/booking/book_appointment_page.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/patient/find_cabinet_page.dart';
import 'package:doctors_app/services/cabinet_service.dart';
import 'package:doctors_app/services/patient_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChildCard extends StatefulWidget {
  const ChildCard({super.key, required this.child});

  final Patient child;

  @override
  State<ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<ChildCard> {
  final CabinetService _cabinetService = CabinetService();
  final PatientService _patientService = PatientService();
  final TextEditingController _symptomsController = TextEditingController();

  Cabinet? _cabinet;

  late Future<void> _cabinetFuture;

  Future<void> _getCabinet() async {
    _cabinet = await _cabinetService.getCabinetById(widget.child.cabinetId);
  }

  @override
  void initState() {
    super.initState();
    _cabinetFuture = _getCabinet();
  }

  void _makeEmergency() {
    if (widget.child.hasEmergency) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Emergency already reported.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    _showEmergencyDialog();
  }

  Future<void> _showEmergencyDialog() async {
    _symptomsController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Report Emergency'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please describe the symptoms:'),
                const SizedBox(height: 10),
                TextField(
                  controller: _symptomsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter symptoms here',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Report'),
              onPressed: () {
                if (_symptomsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter symptoms.'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }
                Navigator.of(dialogContext).pop();
                _proceedWithEmergency(_symptomsController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _proceedWithEmergency(String symptoms) {
    if (!mounted) return;

    setState(() {
      widget.child.hasEmergency = true;
      widget.child.emergencySymptoms = symptoms;
    });

    _patientService.updatePatientEmergencyStatus(widget.child.uid, widget.child.hasEmergency, symptoms);
  
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Emergency reported successfully.'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 196, 255, 209)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: FutureBuilder<void>(
          future: _cabinetFuture,
          builder: (context, snapshot) {
            Widget listTileContent;

            if (snapshot.connectionState == ConnectionState.waiting) {
              listTileContent = ListTile(
                title: Text(
                  '${widget.child.firstName} ${widget.child.lastName}\n${DateFormat('dd-MM-yyyy').format(widget.child.birthDate)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Loading cabinet...\nCNP: ${widget.child.cnp}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                leading: const CircularProgressIndicator(strokeWidth: 2),
              );
            } else if (snapshot.hasError) {
              listTileContent = ListTile(
                title: Text(
                  '${widget.child.firstName} ${widget.child.lastName}\n${DateFormat('dd-MM-yyyy').format(widget.child.birthDate)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Error loading cabinet\nCNP: ${widget.child.cnp}',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
                leading: const Icon(Icons.error, color: Colors.red),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FindCabinetPage(child: widget.child),
                      ),
                    );
                  },
                  child: const Text('Register to cabinet'),
                ),
              );
            } else {
              listTileContent = Column(
                children: [
                  ListTile(
                    title: Text(
                      '${widget.child.firstName} ${widget.child.lastName}\n${DateFormat('dd-MM-yyyy').format(widget.child.birthDate)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Cabinet: ${_cabinet == null ? 'No cabinet assigned' : _cabinet!.name}\nCNP: ${widget.child.cnp}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: _cabinet == null || _cabinet!.isEmpty ?
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FindCabinetPage(child: widget.child),
                          ),
                        );
                      },
                      child: const Text('Register to cabinet'),
                    )
                    : null,
                  ),
                  if (widget.child.cabinetId.isNotEmpty) ... [
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B962B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => (BookAppointmentPage(
                                    patient: widget.child,
                                    cabinet: _cabinet!,
                                    desiredDate: DateTime.now(),
                                  )),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              child: Text('Book Appointment', style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                        widget.child.hasEmergency == false ?
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              _makeEmergency();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              child: Text('Emergency', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                  ]
                ],
              );
            }
            return listTileContent;
          },
        ),
      ),
    );
  }
}