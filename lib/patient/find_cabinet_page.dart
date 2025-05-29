import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:doctors_app/widgets/cabinet_card.dart';
import 'package:doctors_app/cabinet/cabinet_details_page.dart';
import 'package:doctors_app/cabinet/cabinet_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class FindCabinetPage extends StatefulWidget {
  const FindCabinetPage({super.key, this.child});

  final Patient? child;

  @override
  State<FindCabinetPage> createState() => _FindCabinetPageState();
}

class _FindCabinetPageState extends State<FindCabinetPage> {
  final UserDataService _userDataService = UserDataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.cabinetTitle.getString(context)),
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
              child: Text(
                LocaleData.openMap.getString(context),
              ),
            ),
          ),
        ],
      ),
      body: _userDataService.cabinets == null || _userDataService.cabinets!.isEmpty ? 
        Center(
          child: Text(LocaleData.failedToFetchCabinets.getString(context)),
        ) 
      : ListView.builder(
        itemCount: _userDataService.cabinets!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              if (widget.child != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CabinetDetailsPage(cabinet: _userDataService.cabinets![index], child: widget.child),),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CabinetDetailsPage(cabinet: _userDataService.cabinets![index]),),
                );
              }
            },
            child: CabinetCard(cabinet: _userDataService.cabinets![index])
          );
        },
      )
    );
  }
}