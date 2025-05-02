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
  final String openingTime;
  final String closingTime;

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
    required this.openingTime,
    required this.closingTime,
  });

  factory Cabinet.fromMap(Map<String, dynamic> map, [String id = '']) {
    return Cabinet(
      uid: id,
      doctorId: map['doctorId'],
      name: map['name'],
      image: map['image'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      location: LatLng(map['location']['latitude'], map['location']['longitude']),
      address: map['address'],
      rating: double.parse(map['rating'].toString()),
      totalReviews: map['totalReviews'],
      capacity: map['capacity'],
      numberOfPatients: map['numberOfPatients'],
      openingTime: map['openingTime'],
      closingTime: map['closingTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'doctorId': doctorId,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'address': address,
      'rating': rating,
      'totalReviews': totalReviews,
      'capacity': capacity,
      'numberOfPatients': numberOfPatients,
      'openingTime': openingTime,
      'closingTime': closingTime,
    };
  }

  factory Cabinet.empty() {
    return Cabinet(
      uid: '',
      name: '',
      doctorId: '',
      image: '',
      createdAt: DateTime(2003, 09, 30),
      updatedAt: DateTime(2003, 09, 30),
      location: const LatLng(0, 0),
      address: '',
      rating: 0.0,
      totalReviews: 0,
      capacity: 0,
      numberOfPatients: 0,
      openingTime: '',
      closingTime: '',
    );
  }

  bool get isEmpty {
    return 
      uid.isEmpty &&
      name.isEmpty &&
      doctorId.isEmpty &&
      image.isEmpty &&
      createdAt == DateTime(2003, 09, 30) &&
      updatedAt == DateTime(2003, 09, 30) &&
      location == const LatLng(0, 0) &&
      address.isEmpty &&
      rating == 0.0 &&
      totalReviews == 0 &&
      capacity == 0 &&
      numberOfPatients == 0 &&
      openingTime.isEmpty &&
      closingTime.isEmpty;
  }
}