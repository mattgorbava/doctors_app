import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cabinet {
  final String uid;
  final String name;
  final String doctorId;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LatLng location;
  final String address;
  final double rating;
  final int totalReviews;
  final int capacity;
  final int numberOfPatients;

  Cabinet({
    required this.uid,
    required this.name,
    required this.doctorId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
    required this.address,
    required this.rating,
    required this.totalReviews,
    required this.capacity,
    required this.numberOfPatients,
  });

  factory Cabinet.fromMap(Map<String, dynamic> map) {
    return Cabinet(
      uid: map['uid'],
      name: map['name'],
      doctorId: map['doctorId'],
      image: map['image'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      location: LatLng(map['location']['latitude'], map['location']['longitude']),
      address: map['address'],
      rating: map['rating'],
      totalReviews: map['totalReviews'],
      capacity: map['capacity'],
      numberOfPatients: map['numberOfPatients'],
    );
  }
}