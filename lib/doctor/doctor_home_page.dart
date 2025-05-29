import 'package:doctors_app/doctor/doctor_cabinet_page.dart';
import 'package:doctors_app/booking/doctor_bookings_page.dart';
import 'package:doctors_app/doctor/doctor_chatlist_page.dart';
import 'package:doctors_app/doctor/doctor_profile.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/registration_request/registration_requests_page.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logger/logger.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> with WidgetsBindingObserver {
  final UserDataService _userDataService = UserDataService();
  var logger = Logger();

  bool _isLoading = true;

  int _selectedIndex = 0;

  List<Widget> _children = List.generate(5, (_) => const SizedBox.shrink());

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeData();
  }

  Future<void> initializeData() async {
    if (!_isLoading) {
       setState(() { _isLoading = true; });
    }

    try {
      await _userDataService.loadDoctorData();

      if (!mounted) return;

      if (_userDataService.doctor == null) {
        logger.e("Doctor data could not be loaded in DoctorHomePage.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleData.failedToLoadDoctorDetails.getString(context)), backgroundColor: Colors.red),
        );
        setState(() {
           _isLoading = false;
           _children = List.generate(5, (_) => Center(child: Text(LocaleData.errorLoadingPage.getString(context))));
        });
        return;
      }

      setState(() {
        _children = <Widget>[
          const CabinetPage(key: PageStorageKey('doctorCabinetPage')),
          const RegistrationRequestsPage(key: PageStorageKey('doctorRequestsPage')),
          const DoctorBookingsPage(key: PageStorageKey('doctorBookingsPage')),
          const DoctorChatlistPage(key: PageStorageKey('doctorChatlistPage')),
          const DoctorProfile(key: PageStorageKey('doctorProfilePage')),
        ];
        _isLoading = false;
      });
    } catch (e) {
      logger.e("Error initializing doctor home page data: $e");
      if (!mounted) return;
      setState(() {
         _isLoading = false;
         _children = List.generate(5, (_) => Center(child: Text('Error: ${e.toString()}')));
      });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(LocaleData.errorLoadingData.getString(context)), backgroundColor: Colors.red),
       );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket, 
        child: _isLoading ? const Center(child: CircularProgressIndicator()) 
        : _children[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Cabinet'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: LocaleData.navRequests.getString(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: LocaleData.navBookings.getString(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: LocaleData.navChat.getString(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: LocaleData.navProfile.getString(context),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}