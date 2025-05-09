import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/patient/find_cabinet_page.dart';
import 'package:doctors_app/services/cabinet_service.dart';
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
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B962B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Add your action here
                          },
                          child: const Text('Book Appointment'),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Add your action here
                          },
                          child: const Text('Emergency'),
                        ),
                      ),
                    ],
                  ),
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