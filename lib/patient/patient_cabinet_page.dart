import 'package:doctors_app/booking/book_appointment_page.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/patient/find_cabinet_page.dart';
import 'package:doctors_app/chat_screen.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doctors_app/doctor/doctor_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientCabinetPage extends StatefulWidget {
  const PatientCabinetPage({super.key});

  @override
  State<PatientCabinetPage> createState() => _PatientCabinetPageState();
}

class _PatientCabinetPageState extends State<PatientCabinetPage> with AutomaticKeepAliveClientMixin<PatientCabinetPage> {
  @override
  bool get wantKeepAlive => true;

  final FlutterLocalization _localization = FlutterLocalization.instance;

  Cabinet? _cabinet;
  Patient? _patient;
  Doctor? _doctor;
  bool _isLoading = true;
  final UserDataService _userDataService = UserDataService(); 

  Future<void> _deregisterFromCabinet() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseDatabase.instance.ref().child('Patients').child(_patient!.uid).update({
        'cabinetId': null,
      });

      if (_cabinet != null) {
        await FirebaseDatabase.instance.ref().child('Cabinets').child(_cabinet!.uid).update({
          'numberOfPatients': ServerValue.increment(-1) 
        });
        _userDataService.cabinet = null;
        _userDataService.doctor = null;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleData.deregisteredSuccess.getString(context)),
        backgroundColor: Colors.green,
      ));

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleData.deregisteredFailed.getString(context)),
        backgroundColor: Colors.red,
      ));
      
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneCall = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneCall)) {
        await launchUrl(phoneCall);
      } else {
        throw 'Could not call $phoneCall';
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${LocaleData.couldNotCall.getString(context)} $phoneNumber'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _patient = _userDataService.patient;
    _cabinet = _userDataService.cabinet;
    _doctor = _userDataService.doctor;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cabinet', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),)
      : _cabinet == null ? Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocaleData.notRegisteredToCabinetPrompt.getString(context), 
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 0.5 * MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: () { 
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FindCabinetPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B962B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(LocaleData.registerToCabinetButton.getString(context), style: const TextStyle(fontSize: 16, color: Colors.white),),
              ),
            ),
          ],
        ),
      )
      : Column(
        children: [
            Text(LocaleData.registeredToLabel.getString(context), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
          ListTile(
              title: Text('${LocaleData.cabinetNamePrefixLabel.getString(context)}${_cabinet!.name}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
              subtitle: Text('${LocaleData.addressPrefixLabel.getString(context)}${_cabinet!.address}', style: GoogleFonts.poppins(fontSize: 14),),
          ),
          ListTile(
            title: Text('${LocaleData.doctorPrefixLabel.getString(context)}${_doctor!.firstName} ${_doctor!.lastName}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
            subtitle: SizedBox(
              width: 0.5 * MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () { 
                  // ignore: prefer_const_constructors
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => DoctorProfile(patientSideRequest: true, cabinet: _cabinet,)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B962B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(LocaleData.viewDoctorProfile.getString(context), style: const TextStyle(fontSize: 14, color: Colors.white), textAlign: TextAlign.center,), // Adjusted font size
              ),
            ),
          ),
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 0.4 * MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B962B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        _makePhoneCall(_doctor!.phoneNumber);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.white, size: 20),
                          const SizedBox(width: 10,),
                          Text(
                            'Call',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
                          ),
                        ],
                      )
                    ),
                  ),
                  SizedBox(
                    width: _localization.currentLocale?.languageCode == 'en'
                    ? 0.4 * MediaQuery.of(context).size.width
                    : 0.5 * MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B962B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        String currentUserName = '${_patient!.firstName} ${_patient!.lastName}';
                        String doctorName = '${_doctor!.firstName} ${_doctor!.lastName}';
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatScreen(
                            patientName: currentUserName, patientId: _patient!.uid, doctorName: doctorName, doctorId:_doctor!.uid,)),
                        );
                      }, 
                      child: Row(
                        children: [
                          const Icon(Icons.message, color: Colors.white, size: 20),
                          const SizedBox(width: 10,),
                          Text(
                            LocaleData.message.getString(context),
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
                          ),
                        ],
                      )
                    ),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            width: _localization.currentLocale?.languageCode == 'en' 
            ? 0.6 * MediaQuery.of(context).size.width
            : 0.7 * MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B962B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookAppointmentPage(patient: _patient!, cabinet: _cabinet!, desiredDate: DateTime.now(),)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  const SizedBox(width: 10,),
                  Text(
                    LocaleData.bookAppointment.getString(context),
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
                  ),
                ],
              ),
            )
          ),
          const SizedBox(height: 20,),
          SizedBox(
            width: 0.6 * MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B962B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                _deregisterFromCabinet();
              },
              child: Text(
                LocaleData.deregisterFromCabinetButton.getString(context),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
              ),
            )
          ),
        ],
      ) 
    );
  }
}