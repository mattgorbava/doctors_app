import 'dart:async';

import 'package:doctors_app/model/directions_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CabinetLocationPicker extends StatefulWidget {
  const CabinetLocationPicker({super.key});

  @override
  State<CabinetLocationPicker> createState() => _CabinetLocationPickerState();
}

class _CabinetLocationPickerState extends State<CabinetLocationPicker> {
  dynamic _initialCameraPosition;

  GoogleMapController? _googleMapController;
  Directions? _info;
  LatLng? _currentPosition;
  bool _isLoading = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initialCameraPosition = CameraPosition(
      target: _currentPosition ?? const LatLng(0, 0),
      zoom: 14.5,
    );
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _selectLocation() async {
    if (_currentPosition == null) {
      return;
    }

      try {
        final LatLngBounds bounds = await _googleMapController!.getVisibleRegion();
        
        final LatLng selectedLocation = LatLng(
          (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
          (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
        );

        if (!mounted) return;
        Navigator.of(context).pop(selectedLocation);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to select location'),
          ),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        centerTitle: false,
        title: const Text('Google Maps'),
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
            onPressed: _selectLocation,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              textStyle: GoogleFonts.poppins(),
            ),
            child: const Text('Select'),
          )
        ],
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
          ),
          const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 36,
          ),
          if (_isLoading) 
            const CircularProgressIndicator()
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
}