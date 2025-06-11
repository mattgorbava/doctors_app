import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/registration_request/registration_request_details_page.dart';
import 'package:doctors_app/widgets/registration_request_card.dart';
import 'package:doctors_app/model/registration_request.dart';
import 'package:doctors_app/services/registration_request_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class RegistrationRequestsPage extends StatefulWidget {
  const RegistrationRequestsPage({super.key});

  @override
  State<RegistrationRequestsPage> createState() => _RegistrationRequestsPageState();
}

class _RegistrationRequestsPageState extends State<RegistrationRequestsPage> with AutomaticKeepAliveClientMixin<RegistrationRequestsPage> {
  @override
  bool get wantKeepAlive => true;

  final RegistrationRequestService _registrationRequestService = RegistrationRequestService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<RegistrationRequest> _registrationRequests = [];
  bool _isLoading = true;

  Future<void> _fetchRegistrationRequests() async {
    String? doctorId = _auth.currentUser?.uid;
    try {
      List<RegistrationRequest> requests = await _registrationRequestService.getAllRequestsByDoctorId(doctorId!);
      setState(() {
        _registrationRequests = requests;
      });
    } catch (e) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleData.failedToFetchRegistrationRequests.getString(context)),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRegistrationRequests();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.registrationRequests.getString(context)),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _registrationRequests.isEmpty
        ? Center(child: Text(LocaleData.noRequests.getString(context)))
        : ListView.builder(
          itemCount: _registrationRequests.length,
          itemBuilder: (context, index) {
            final request = _registrationRequests[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationRequestDetailsPage(request: request),
                  ),
                );
              },
              child: RegistrationRequestCard(request: request)
            );
          },
        ),
    );
  }
}