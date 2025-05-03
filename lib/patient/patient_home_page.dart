import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/patient/patient_cabinet_page.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/patient/chat_list_page.dart';
import 'package:doctors_app/patient/patient_children_page.dart';
import 'package:doctors_app/patient/upcoming_mandatory_consultations.dart';
import 'package:doctors_app/patient/user_profile.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _userDataService = UserDataService();

  final DatabaseReference _cabinetRef = FirebaseDatabase.instance.ref().child('Cabinets');
  List<Cabinet> _cabinets = [];
  bool _isLoading = true;

  final PageStorageBucket _bucket = PageStorageBucket();

  int _selectedIndex = 0;

  List<Widget> _children = List.generate(4, (_) => const SizedBox.shrink());  
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _fetchCabinets() async {
    try {
      await _cabinetRef.once().then((DatabaseEvent event){
        DataSnapshot snapshot = event.snapshot;
        List<Cabinet> cabinets = [];
        if(snapshot.value != null){
          Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) {
            cabinets.add(Cabinet.fromMap(Map<String, dynamic>.from(value), key));
          });
        }
        setState(() {
          _cabinets = cabinets;
          _isLoading = false;

          _children= <Widget>[
            PatientCabinetPage(cabinets: _cabinets),
            const ChatListPage(),
            UpcomingMandatoryConsultations(patientId: _auth.currentUser!.uid),
            const UserProfile(),
          ];
        });
      });
    } catch (e) {
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

  void initializeData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _userDataService.loadPatientData();

      List<Cabinet> cabinets = [];

      if (_userDataService.cabinet == null) {
        final DatabaseEvent event = await _cabinetRef.once();
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) {
            cabinets.add(Cabinet.fromMap(Map<String, dynamic>.from(value), key));
          });
        }
      }

      if (!mounted) return;

      setState(() {
        _cabinets = cabinets;
        _children = <Widget>[
          PatientCabinetPage(key: PageStorageKey('patientCabinetPage'), cabinets: _cabinets),
          const ChatListPage(key: PageStorageKey('patientChatlistPage'),),
          UpcomingMandatoryConsultations(key: PageStorageKey('patientMandatoryConsultationsPage'), patientId: _auth.currentUser!.uid),
          const PatientChildrenPage(key: PageStorageKey('patientChildrenPage'),),
          const UserProfile(key:PageStorageKey('patientProfilePage')),
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