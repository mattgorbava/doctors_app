import 'package:doctors_app/model/child.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:doctors_app/widgets/cabinet_card.dart';
import 'package:doctors_app/cabinet/cabinet_details_page.dart';
import 'package:doctors_app/cabinet/cabinet_map.dart';
import 'package:flutter/material.dart';

class FindCabinetPage extends StatefulWidget {
  const FindCabinetPage({super.key, this.child});

  final Child? child;

  @override
  State<FindCabinetPage> createState() => _FindCabinetPageState();
}

class _FindCabinetPageState extends State<FindCabinetPage> {
  final UserDataService _userDataService = UserDataService();

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
                  MaterialPageRoute(builder: (context) => const CabinetMap()),
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
      body: ListView.builder(
        itemCount: _userDataService.cabinets.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              if (widget.child != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CabinetDetailsPage(cabinet: _userDataService.cabinets[index], child: widget.child),),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CabinetDetailsPage(cabinet: _userDataService.cabinets[index]),),
                );
              }
            },
            child: CabinetCard(cabinet: _userDataService.cabinets[index])
          );
        },
      )
    );
  }
}