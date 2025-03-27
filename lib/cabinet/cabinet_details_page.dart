import 'package:doctors_app/model/cabinet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CabinetDetailsPage extends StatefulWidget {
  const CabinetDetailsPage({super.key, required this.cabinet});

  final Cabinet cabinet;

  @override
  State<CabinetDetailsPage> createState() => _CabinetDetailsPageState();
}

class _CabinetDetailsPageState extends State<CabinetDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cabinet.name),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  color: const Color(0xffF0EFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.cabinet.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.cabinet.image,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                : const Icon(Icons.person, size: 60, color: Colors.grey),
              ),
              const SizedBox(width: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    widget.cabinet.name,
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.cabinet.address,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ]
              ),
            ],
          )
        ],
      ),
    );
  }
}