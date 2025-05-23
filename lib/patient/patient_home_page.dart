import 'package:doctors_app/patient/patient_cabinet_page.dart';
import 'package:doctors_app/patient/chat_list_page.dart';
import 'package:doctors_app/patient/patient_children_page.dart';
import 'package:doctors_app/patient/upcoming_mandatory_consultations.dart';
import 'package:doctors_app/patient/patient_user_profile.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _userDataService = UserDataService();

  bool _isLoading = true;

  final PageStorageBucket _bucket = PageStorageBucket();

  int _selectedIndex = 0;

  List<Widget> _children = List.generate(4, (_) => const SizedBox.shrink());  
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void initializeData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _userDataService.loadPatientData();

      if (!mounted) return;

      setState(() {
        _children = <Widget>[
          const PatientCabinetPage(key: PageStorageKey('patientCabinetPage')),
          const ChatListPage(key: PageStorageKey('patientChatlistPage'),),
          UpcomingMandatoryConsultations(key: const PageStorageKey('patientMandatoryConsultationsPage'), patientId: _auth.currentUser!.uid),
          const PatientChildrenPage(key: PageStorageKey('patientChildrenPage')),
          const PatientUserProfile(key: PageStorageKey('patientProfilePage')),
        ];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch cabinets. Please try again later.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(child: CircularProgressIndicator(),)
      : Scaffold(
        body: PageStorage(
          bucket: _bucket,
          child: _isLoading ? const Center(child: CircularProgressIndicator(),)
          : _children[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Consultations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.child_care),
              label: 'Children',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
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