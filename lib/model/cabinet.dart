import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

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

  factory Cabinet.fromMap(Map<String, dynamic> map, [String id = '']) {
    Logger logger = Logger();
    logger.d(map['name']);
    logger.d(map['doctorId']);
    logger.d(map['image']);
    logger.d(map['createdAt']);
    logger.d(map['updatedAt']);
    logger.d(map['location']);
    logger.d(map['address']);
    logger.d(map['rating']);
    logger.d(map['totalReviews']);
    logger.d(map['capacity']);
    logger.d(map['numberOfPatients']);

    return Cabinet(
      uid: id,
      name: map['name'],
      doctorId: map['doctorId'],
      image: map['image'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      location: LatLng(map['location']['latitude'], map['location']['longitude']),
      address: map['address'],
      rating: double.parse(map['rating'].toString()),
      totalReviews: map['totalReviews'],
      capacity: map['capacity'],
      numberOfPatients: map['numberOfPatients'],
    );
  }
}