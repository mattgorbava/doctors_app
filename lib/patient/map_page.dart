import 'dart:async';

import 'package:doctors_app/model/doctor.dart';
import 'package:doctors_app/model/directions_model.dart';
import 'package:doctors_app/repository/directons_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.doctors});

  final List<Doctor> doctors;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  dynamic _initialCameraPosition;

  GoogleMapController? _googleMapController;
  Directions? _info;
  LatLng? _currentPosition;
  bool _isLoading = false;
  final Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initialCameraPosition = CameraPosition(
      target: _currentPosition ?? const LatLng(0, 0),
      zoom: 14.5,
    );
    //addDoctorMarkers();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        centerTitle: false,
        title: const Text('Google Maps'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
          ),
          if (_isLoading) 
            const CircularProgressIndicator()
          else if (_info != null) 
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ]
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600
                  ), 
                )  
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        onPressed: () => _googleMapController!.animateCamera(
          _info != null 
            ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
            : _currentPosition != null
              ? CameraUpdate.newLatLng(_currentPosition!)
              : CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      
      _googleMapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> addDoctorMarkers() async {
  //   for (Doctor doctor in widget.doctors) {
  //     _markers.add(
  //       Marker(
  //         markerId: MarkerId(doctor.uid),
  //         position: LatLng(double.parse(doctor.latitude), double.parse(doctor.longitude)),
  //         infoWindow: InfoWindow(
  //           title: '${doctor.lastName} ${doctor.firstName}',
  //           snippet: doctor.category,
  //         ),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //         onTap: () async {
  //         if (_currentPosition != null) {
  //           Directions? directions = await DirectionsRepository().getDirections(
  //             origin: _currentPosition!,
  //             destination: LatLng(double.parse(doctor.latitude), double.parse(doctor.longitude)),
  //           );

  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(
  //                 'Duration to ${doctor.lastName} ${doctor.firstName}: ${directions!.totalDuration}',
  //               ),
  //               duration: const Duration(seconds: 3),
  //             ),
  //           );
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('Current location not available'),
  //               duration: Duration(seconds: 3),
  //             ),
  //           );
  //         }
  //       },
  //       ),
  //     );
  //   }
  // }  
}