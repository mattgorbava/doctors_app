import 'package:flutter/material.dart';

class DoctorBookingsPage extends StatefulWidget {
  const DoctorBookingsPage({super.key});

  @override
  State<DoctorBookingsPage> createState() => _DoctorBookingsPageState();
}

class _DoctorBookingsPageState extends State<DoctorBookingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Bookings Page'),
      ),
    );
  }
}