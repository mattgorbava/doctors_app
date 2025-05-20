import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctors_app/model/patient.dart';
import 'package:doctors_app/services/patient_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientCard extends StatefulWidget {
  const PatientCard({super.key, required this.patient});

  final Patient patient;

  @override
  State<PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard> {
  final PatientService _patientService = PatientService();
  
  Patient? _parent;

  @override
  void initState() {
    super.initState();
    if (widget.patient.parentId.isNotEmpty) {
      _getParent();
    }
  }

  Future<void> _getParent() async {
    Patient parent = await _patientService.getPatientById(widget.patient.parentId) ?? Patient.empty();
    setState(() {
      _parent = parent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 196, 255, 209)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Container(
            width: 55,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: const Color(0xff0064FA)),
            ),
            child: widget.patient.profileImageUrl.isNotEmpty 
            ? ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: CachedNetworkImage(
                imageUrl: widget.patient.profileImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person),
              ),
            )
            : null,
          ),
          title: Text(
            '${widget.patient.firstName} ${widget.patient.lastName}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: _parent != null && _parent!.isNotEmpty 
          ? Text(
            'Parent : ${_parent!.firstName} ${_parent!.lastName}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          )
          : const SizedBox.shrink(),
        ),
      ),
    );
  }
}