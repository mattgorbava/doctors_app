import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cabinet {
  String uid;
  String name;
  String doctorId;
  String image;
  DateTime createdAt;
  DateTime updatedAt;
  LatLng location;
  String address;
  int capacity;
  int numberOfPatients;
  String openingTime;
  String closingTime;

  Cabinet({
    required this.uid,
    required this.name,
    required this.doctorId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
    required this.address,
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
      capacity == 0 &&
      numberOfPatients == 0 &&
      openingTime.isEmpty &&
      closingTime.isEmpty;
  }
}