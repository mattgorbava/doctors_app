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
    DateTime safeParseDateTime(String? dateString, DateTime defaultValue) {
      if (dateString == null) {
        return defaultValue;
      }
      return DateTime.tryParse(dateString) ?? defaultValue;
    }

    LatLng parseLocation(dynamic locationData) {
      if (locationData is Map &&
          locationData.containsKey('latitude') &&
          locationData.containsKey('longitude') &&
          locationData['latitude'] is num &&
          locationData['longitude'] is num) {
        return LatLng(
          (locationData['latitude'] as num).toDouble(),
          (locationData['longitude'] as num).toDouble(),
        );
      }
      return const LatLng(0, 0);
    }

    return Cabinet(
      uid: id,
      doctorId: map['doctorId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      createdAt: safeParseDateTime(map['createdAt'], DateTime(2003, 09, 30)),
      updatedAt: safeParseDateTime(map['updatedAt'], DateTime(2003, 09, 30)),
      location: parseLocation(map['location']),
      address: map['address'] ?? '',
      capacity: map['capacity'] ?? 0,
      numberOfPatients: map['numberOfPatients'] ?? 0,
      openingTime: map['openingTime'] ?? '',
      closingTime: map['closingTime'] ?? '',
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