import 'package:doctors_app/chat_screen.dart';
import 'package:doctors_app/localization/locales.dart';
import 'package:doctors_app/model/doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with AutomaticKeepAliveClientMixin<ChatListPage> {
  @override
  bool get wantKeepAlive => true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListRef = FirebaseDatabase.instance.ref().child('ChatList');
  final DatabaseReference _doctorRef = FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _chatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatList();
  }

  void _fetchChatList() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      try {
        final DatabaseEvent event = await _chatListRef.once();
        DataSnapshot snapshot = event.snapshot;
        List<Doctor> chatList = [];

        if (snapshot.value != null) {
          Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
          for (var doctorId in values.keys) {
            Map<dynamic, dynamic> chats = values[doctorId] as Map<dynamic, dynamic>;
            if (chats.containsKey(currentUserId)) {
              final DatabaseEvent doctorEvent = await _doctorRef.child(doctorId).once();
              DataSnapshot doctorSnapshot = doctorEvent.snapshot;
              if (doctorSnapshot.value != null) {
                Doctor doctor = Doctor.fromMap(doctorSnapshot.value as Map<dynamic, dynamic>, doctorId);
                chatList.add(doctor);
              }
            }
          }
        }
        setState(() {
          _chatList = chatList;
          _isLoading = false;
        });
      } catch (e) {
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
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) :
      ListView.builder(
        itemCount: _chatList.length,
        itemBuilder: (context, index) {
          Doctor doctor = _chatList[index];
          return Card(
            child: ListTile(
              title: Text('Chat with ${doctor.firstName} ${doctor.lastName}'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
                  ChatScreen(doctorId: doctor.uid, 
                             doctorName: '${doctor.firstName} ${doctor.lastName}', 
                             patientId: _auth.currentUser!.uid ,)));
              },
            ),
          );
        },
      )
    );
  }
}
