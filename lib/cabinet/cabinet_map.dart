import 'package:doctors_app/model/directions_model.dart';
import 'package:flutter/material.dart';
import 'package:doctors_app/model/cabinet.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CabinetMap extends StatefulWidget {
  const CabinetMap({super.key, required this.cabinets});

  final List<Cabinet> cabinets;

  @override
  State<CabinetMap> createState() => _CabinetMapState();
}

class _CabinetMapState extends State<CabinetMap> {
  dynamic _initialCameraPosition;
  GoogleMapController? _googleMapController;
  Directions? _info;
  LatLng? _currentPosition;
  bool _isLoading = false;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initialCameraPosition = CameraPosition(
      target: _currentPosition ?? const LatLng(0, 0),
      zoom: 14.5,
    );
    _addCabinetMarkers();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
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

      if (_googleMapController != null) {
        _googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 14.5,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addCabinetMarkers() async {
    for (var cabinet in widget.cabinets) {
      LatLng cabinetPosition = LatLng(cabinet.location.latitude, cabinet.location.longitude);

      _markers.add(
        Marker(
          markerId: MarkerId(cabinet.uid),
          position: cabinetPosition,
          infoWindow: InfoWindow(
            title: cabinet.name,
            snippet: cabinet.address,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Cabinet Map'),
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _googleMapController = controller;
            if (_currentPosition != null) {
              _googleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _currentPosition!,
                    zoom: 14.5,
                  ),
                ),
              );
            }
          });
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () {
          if (_currentPosition != null && _googleMapController != null) {
            _googleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _currentPosition!,
                  zoom: 14.5,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}