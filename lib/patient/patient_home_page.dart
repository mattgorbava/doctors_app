import 'package:doctors_app/cabinet/doctor_cabinet_page.dart';
import 'package:doctors_app/cabinet/patient_cabinet_page.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:doctors_app/doctor/doctor_list_page.dart';
import 'package:doctors_app/patient/chat_list_page.dart';
import 'package:doctors_app/patient/map_page.dart';
import 'package:doctors_app/patient/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:doctors_app/model/doctor.dart';

class PatientHomePage extends StatefulWidget {
  final bool rememberMe;

  const PatientHomePage({super.key, required this.rememberMe});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final DatabaseReference _cabinetRef = FirebaseDatabase.instance.ref().child('Cabinets');
  List<Cabinet> _cabinets = [];
  List<Doctor> _doctors = [];
  bool _isLoading = true;

  int _selectedIndex = 0;

  late List<Widget> _children;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchDoctors();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      if (!widget.rememberMe) {
        _auth.signOut();
      }
    }
  }

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

  Future<void> _fetchDoctors() async {
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
          const UserProfile(),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(child: CircularProgressIndicator(),)
      : PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        
        // Show the confirmation dialog
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
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _children,
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
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

}