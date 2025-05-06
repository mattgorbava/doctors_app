import 'package:doctors_app/model/medical_history.dart';
import 'package:flutter/material.dart';

class MedicalHistoryCard extends StatefulWidget {
  const MedicalHistoryCard({super.key, required this.history});

  final MedicalHistory history;

  @override
  State<MedicalHistoryCard> createState() => _MedicalHistoryCardState();
}

class _MedicalHistoryCardState extends State<MedicalHistoryCard> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}