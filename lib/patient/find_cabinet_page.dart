import 'package:doctors_app/cabinet/cabinet_card.dart';
import 'package:doctors_app/cabinet/cabinet_details_page.dart';
import 'package:doctors_app/patient/cabinet_map.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FindCabinetPage extends StatefulWidget {
  const FindCabinetPage({super.key, required this.cabinets});

  final List<Cabinet> cabinets;

  @override
  State<FindCabinetPage> createState() => _FindCabinetPageState();
}

class _FindCabinetPageState extends State<FindCabinetPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Cabinet'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CabinetMap(cabinets: widget.cabinets)),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Open Map',
              ),
            ),
          ),
        ],
      ),
      body: Expanded(
        child: ListView.builder(
          itemCount: widget.cabinets.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CabinetDetailsPage(cabinet: widget.cabinets[index]),),
                );
              },
              child: CabinetCard(cabinet: widget.cabinets[index])
            );
          },
        )
      )
    );
  }
}