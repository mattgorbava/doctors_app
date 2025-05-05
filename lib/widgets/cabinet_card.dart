import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CabinetCard extends StatelessWidget {
  const CabinetCard({super.key, required this.cabinet});

  final Cabinet cabinet;

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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: CachedNetworkImage(
                imageUrl: cabinet.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person), 
              )
            ),
          ),
          title: Text(cabinet.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),),
          subtitle: Text(cabinet.address, style: GoogleFonts.poppins(fontSize: 14),),
        ),
      )
    );
  }
}