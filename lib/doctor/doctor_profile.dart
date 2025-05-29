import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctors_app/auth/login_page.dart';
import 'package:doctors_app/auth/register_screen.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key, this.patientSideRequest = false});

  final bool patientSideRequest;

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> with AutomaticKeepAliveClientMixin<DoctorProfile> {
  @override
  bool get wantKeepAlive => true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserDataService _userDataService = UserDataService();
  Doctor? _doctor;
  bool _isLoading = true;

  @override
  void initState() {
    _doctor = _userDataService.doctor;
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isLoading == true ? const Center(child: CircularProgressIndicator(),) 
    : Scaffold(
      appBar: AppBar(
          title: Text(LocaleData.profileTitle.getString(context)),
        automaticallyImplyLeading: false,
        actions: [
          widget.patientSideRequest == false ?
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                _auth.signOut();
                _userDataService.clearUserData();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            )
          : const SizedBox.shrink(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: _doctor!.profileImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person),
              ),
              const SizedBox(height: 20),
              Text(
                '${_doctor!.firstName} ${_doctor!.lastName}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_doctor!.cvUrl.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = _doctor!.cvUrl;
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(LocaleData.couldNotOpenCv.getString(context)),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(LocaleData.openCvButton.getString(context), style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green,),
                ),
              if (!widget.patientSideRequest) ... [
                const SizedBox(height: 20),
                SizedBox(
                  width: 0.5 * MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterPage(
                        doctor: _doctor,
                      )));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B962B),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(LocaleData.editProfileButton.getString(context), style: TextStyle(fontSize: 16, color: Colors.white),),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}