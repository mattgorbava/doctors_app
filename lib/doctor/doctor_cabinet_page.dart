import 'package:doctors_app/cabinet/register_cabinet_page.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CabinetPage extends StatefulWidget {
  const CabinetPage({super.key});

  @override
  State<CabinetPage> createState() => _CabinetPageState();
}

class _CabinetPageState extends State<CabinetPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Cabinet? _cabinet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCabinet();
  }

  Future<void> _fetchCabinet() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      final cabinetReference = await FirebaseDatabase.instance.ref().child('Cabinets').once();
      Cabinet? cabinet;
      if (cabinetReference.snapshot.exists) {
        final snapshot = await _db
          .child('Cabinets')
          .orderByChild('doctorId')
          .equalTo(currentUserId)
          .once();


        if (snapshot.snapshot.exists) {
          final Map<dynamic, dynamic> values = snapshot.snapshot.value as Map<dynamic, dynamic>;
        
          if (values.isNotEmpty) {
            final key = values.keys.first;
            cabinet = Cabinet.fromMap(Map<String, dynamic>.from(values[key]), key);
          }
        }

      }
      setState(() {
        _cabinet = cabinet;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(child: CircularProgressIndicator(),)
      : Scaffold(
          appBar: AppBar(
            title: const Text('Cabinet'),
            automaticallyImplyLeading: false,
          ),
          body: _cabinet == null ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You haven\'t registered\nyour cabinet yet.', 
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              SizedBox(
                  width: 0.5 * MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () { 
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterCabinetPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B962B),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white),),
                  ),
                ),
            ]
            ),)
          : Column(
            children: <Widget>[
              ListTile(
                title: Text(_cabinet!.name),
                subtitle: Text('Rating: ${_cabinet!.rating}'),
              ),
              ListTile(
                title: Text('Total Reviews: ${_cabinet!.totalReviews}'),
                subtitle: Text('Capacity: ${_cabinet!.capacity}'),
              ),
              ListTile(
                title: Text('Number of Patients: ${_cabinet!.numberOfPatients}'),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 0.5 * MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () { 
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterCabinetPage(
                      cabinet: _cabinet,
                    )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B962B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 16, color: Colors.white),),
                ),
              )
            ],
          ),
        );
  }
}