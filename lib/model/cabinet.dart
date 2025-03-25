import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cabinet {
  final String uid;
  final String name;
  final String doctorId;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LatLng location;
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
    required this.rating,
    required this.totalReviews,
    required this.capacity,
    required this.numberOfPatients,
  });

  factory Cabinet.fromJson(Map<String, dynamic> json) {
    return Cabinet(
      uid: json['uid'],
      name: json['name'],
      doctorId: json['doctorId'],
      image: json['image'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      location: LatLng(json['location']['latitude'], json['location']['longitude']),
      rating: json['rating'],
      totalReviews: json['totalReviews'],
      capacity: json['capacity'],
      numberOfPatients: json['numberOfPatients'],
    );
  }
}