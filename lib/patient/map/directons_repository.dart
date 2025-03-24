import 'package:dio/dio.dart';
import 'package:doctors_app/patient/map/directions_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '.env.dart';
import '.env.dart';

class DirectionsRepository {
  static const String _baseUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes';

  final Dio _dio; 

  DirectionsRepository ({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _dio.post(
      _baseUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': googleAPIKey,
          'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
        },
      ),
      data: {
        'origin': {
          'location': {
            'latLng': {
              'latitude': origin.latitude,
              'longitude': origin.longitude,
            }
          }
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destination.latitude,
              'longitude': destination.longitude,
            }
          }
        },
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_UNAWARE',
        'computeAlternativeRoutes': false,
        'routeModifiers': {
          'avoidTolls': false,
          'avoidHighways': false,
          'avoidFerries': false,
        },
        'languageCode': 'en-US',
        'units': 'METRIC'
      }
    );

    if (response.statusCode == 200) {
      try {
        return Directions.fromMap(response.data);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return null;
  }
}