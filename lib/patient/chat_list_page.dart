import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
      ),
      body: Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            'Chat List Page',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}