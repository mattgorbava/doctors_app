import 'package:doctors_app/doctor/doctor_cabinet_page.dart';
import 'package:doctors_app/booking/doctor_bookings_page.dart';
import 'package:doctors_app/doctor/doctor_chatlist_page.dart';
import 'package:doctors_app/doctor/doctor_profile.dart';
import 'package:doctors_app/registration_request/registration_requests_page.dart';
import 'package:doctors_app/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> with WidgetsBindingObserver {
  final UserDataService _userDataService = UserDataService();

  final String _doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
        print("Error: Doctor data could not be loaded in DoctorHomePage.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load doctor details.'), backgroundColor: Colors.red),
        );
        setState(() {
           _isLoading = false;
           _children = List.generate(5, (_) => const Center(child: Text('Error loading page.')));
        });
        return;
      }

      setState(() {
        _children = <Widget>[
          const CabinetPage(key: PageStorageKey('doctorCabinetPage')),
          const RegistrationRequestsPage(key: PageStorageKey('doctorRequestsPage')),
          const DoctorBookingsPage(key: PageStorageKey('doctorBookingsPage')),
          const DoctorChatlistPage(key: PageStorageKey('doctorChatlistPage')),
          const DoctorProfile(key: const PageStorageKey('doctorProfilePage')),
        ];
        _isLoading = false; // Stop loading
      });
    } catch (e) {
      print('Error initializing doctor home page data: $e');
      if (!mounted) return;
      setState(() {
         _isLoading = false;
         _children = List.generate(5, (_) => Center(child: Text('Error: ${e.toString()}')));
      });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error initializing data: ${e.toString()}'), backgroundColor: Colors.red),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Cabinet'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookings',
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
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}