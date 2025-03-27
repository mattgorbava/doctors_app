import 'package:doctors_app/cabinet/cabinet_card.dart';
import 'package:doctors_app/cabinet/cabinet_details_page.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:flutter/material.dart';

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