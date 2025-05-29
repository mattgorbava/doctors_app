import 'package:doctors_app/chat_screen.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:logger/logger.dart';

class DoctorChatlistPage extends StatefulWidget {
  const DoctorChatlistPage({super.key});

  @override
  State<DoctorChatlistPage> createState() => _DoctorChatlistPageState();
}

class _DoctorChatlistPageState extends State<DoctorChatlistPage> with AutomaticKeepAliveClientMixin<DoctorChatlistPage> {
  @override
  bool get wantKeepAlive => true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListRef = FirebaseDatabase.instance.ref().child('ChatList');
  final DatabaseReference _patientsRef = FirebaseDatabase.instance.ref().child('Patients');
  List<Patient> _chatList = [];
  bool _isLoading = true;
  late String doctorId;

  var logger = Logger();

  @override
  void initState() {
    super.initState();
    doctorId = _auth.currentUser!.uid;
    _fetchChatList();
  }

  void _fetchChatList() async {
    if(doctorId.isNotEmpty){
      try{
        final DatabaseEvent event = await _chatListRef.child(doctorId).once();
        DataSnapshot snapshot = event.snapshot;
        List<Patient> chatList = [];

        if(snapshot.value != null){
          Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

          for(var userId in values.keys){
            final DatabaseEvent patientEvent = await _patientsRef.child(userId).once();
            DataSnapshot patientSnapshot = patientEvent.snapshot;
            if(patientSnapshot.value != null){
              Map<dynamic, dynamic> patientMap = patientSnapshot.value as Map<dynamic, dynamic>;
              chatList.add(Patient.fromMap(Map<String, dynamic>.from(patientMap), userId));
            }
          }
        }
        setState(() {
          _chatList = chatList;
          _isLoading = false;
        });

      } catch (e) {
        logger.e('Error fetching chat list: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(LocaleData.couldNotGetChats.getString(context)),
          backgroundColor: Colors.red,
        ));
      }
  }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.chatListTitle.getString(context)),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) 
      : _chatList.isEmpty ? Center(child: Text(LocaleData.noChatsFound.getString(context))) 
      : ListView.builder(
        itemCount: _chatList.length,
        itemBuilder: (context, index) {
          Patient patient = _chatList[index];
          return Card(
            child: ListTile(
              title: Text('${LocaleData.chatWithPrefix.getString(context)}${patient.firstName} ${patient.lastName}'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
                  ChatScreen(doctorId: doctorId, 
                             patientName: '${patient.firstName} ${patient.lastName}', 
                             patientId: patient.uid ,)));
              },
            ),
          );
        },
      )
    );
  }
}