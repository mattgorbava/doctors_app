import 'package:doctors_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatScreen extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;
  final String? patientId;
  final String? patientName;
  
  const ChatScreen({super.key, this.doctorId, this.doctorName, this.patientId, this.patientName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListRef = FirebaseDatabase.instance.ref().child('ChatList');
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref().child('Chat');

  final TextEditingController _messageController = TextEditingController();

  String? currentUserId;

  bool get isDoctor => widget.doctorId == currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      String message = _messageController.text.trim();
      String chatId = _chatRef.push().key!;
      String timeStamp = DateTime.now().toIso8601String();

      String senderUid;
      String receiverUid;

      if (isDoctor) {
        senderUid = widget.doctorId!;
        receiverUid = widget.patientId!;
      } else {
        senderUid = widget.patientId!;
        receiverUid = widget.doctorId!;
      }

      _chatRef.child(chatId).set({
        'senderId': senderUid,
        'receiverId': receiverUid,
        'message': message,
        'timeStamp': timeStamp
      });

      _chatListRef.child(senderUid).child(receiverUid).set({
        'id': receiverUid,
      });

      _chatListRef.child(receiverUid).child(senderUid).set({
        'id': senderUid,
      });

      _messageController.clear();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    String? chatPartnerName = isDoctor ? widget.patientName : widget.doctorName;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $chatPartnerName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text('No messages yet'));
                } else {

                  Map<dynamic, dynamic> messagesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<String, dynamic>> messages = [];

                  messagesMap.entries.forEach((entry) {
                    var value = entry.value;
                    if ((value['senderId'] == currentUserId && value['receiverId'] == widget.doctorId) ||
                        (value['senderId'] == widget.doctorId && value['receiverId'] == currentUserId) ||
                        (value['senderId'] == currentUserId && value['receiverId'] == widget.patientId)||
                        (value['senderId'] == widget.patientId && value['receiverId'] == currentUserId)) {
                      messages.add({
                        'senderId': value['senderId'],
                        'message': value['message'],
                        'timeStamp': value['timeStamp']
                      });
                    }
                  });
                  messages.sort((a, b) => a['timeStamp'].compareTo(b['timeStamp']));

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                    bool isMe = messages[index]['senderId'] == currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(messages[index]['message'], style: const TextStyle(color: Colors.white),),
                      ),
                    );
                  });
                }
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)
                      )
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ]
      ),
    );
  }

  Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'chat_notifications', 
    'Chat Notifications', 
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}
}