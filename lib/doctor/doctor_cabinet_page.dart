import 'package:doctors_app/cabinet/register_cabinet_page.dart';
import 'package:doctors_app/doctor/patients_list_page.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class CabinetPage extends StatefulWidget {
  const CabinetPage({super.key});

  @override
  State<CabinetPage> createState() => _CabinetPageState();
}

class _CabinetPageState extends State<CabinetPage> with AutomaticKeepAliveClientMixin<CabinetPage> {
  @override
  bool get wantKeepAlive => true;

  final UserDataService _userDataService = UserDataService();

  Cabinet? _cabinet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getCabinet();
  }

  void getCabinet() async {
    setState(() {
      _cabinet = _userDataService.cabinet;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading ? const Center(child: CircularProgressIndicator(),)
      : Scaffold(
          appBar: AppBar(
            title: const Text('Cabinet'),
            automaticallyImplyLeading: false,
          ),
          body: _cabinet == null ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LocaleData.noCabinetRegisteredYet.getString(context),
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              SizedBox(
                  width: 0.5 * MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async { 
                      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterCabinetPage()));
                      setState(() {
                        _cabinet = _userDataService.cabinet;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B962B),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(LocaleData.registerYourCabinet.getString(context), style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
            ]
          ),)
          : Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cabinet!.image.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                        radius: 60, // Adjust size as needed (30 = 60px diameter)
                        backgroundImage: NetworkImage(_cabinet!.image),
                        backgroundColor: Colors.grey[200], // Fallback color while loading
                      ),
                  )
                  : const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                  const SizedBox(width: 20,),
                  Flexible(
                    child: Text(
                      _cabinet!.name,
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              ListTile(
                title: Text('${LocaleData.numberOfPatients.getString(context)}: ${_cabinet!.numberOfPatients}'),
              ),
              ListTile(
                title: Text('${LocaleData.capacity.getString(context)}: ${_cabinet!.capacity}'),
              ),
              ListTile(
                title: Text('${LocaleData.address.getString(context)}: ${_cabinet!.address}'),
              ),
              ListTile(
                title: Text('${LocaleData.workingHours.getString(context)}: ${_cabinet!.openingTime} - ${_cabinet!.closingTime}'),
              ),
              const SizedBox(height: 10,),
              SizedBox(
                width: 0.5 * MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () { 
                    if (!mounted) return;
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PatientsListPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B962B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(LocaleData.patientList.getString(context), style: TextStyle(fontSize: 16, color: Colors.white),),
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 0.5 * MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () { 
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PatientsListPage(emergencies: true,)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B962B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(LocaleData.emergencies.getString(context), style: TextStyle(fontSize: 16, color: Colors.white),),
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 0.5 * MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async { 
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterCabinetPage(
                      cabinet: _cabinet,
                    )));
                    setState(() {
                      _cabinet = _userDataService.cabinet;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B962B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(LocaleData.editCabinet.getString(context), style: TextStyle(fontSize: 16, color: Colors.white),),
                ),
              )
            ],
          ),
        );
  }
}