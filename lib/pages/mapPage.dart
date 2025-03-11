import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mappage extends StatefulWidget {
  final double lati;
  final double longi;
  const Mappage({super.key, required this.lati, required this.longi});

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  late double latu;
  late double longu;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final List<LatLng> doctorLocations = [
    LatLng(10.7945, 76.7286), // Dummy data
    LatLng(10.806579, 76.725187),
    LatLng(10.803846, 76.728103),
  ];

  @override
  void initState() {
    super.initState();
    latu = widget.lati;
    longu = widget.longi;
  }

  CameraPosition get _initialPosition => CameraPosition(
        target: LatLng(latu, longu),
        zoom: 14.0,
      );

  CameraPosition get _closeUpPosition => CameraPosition(
        target: LatLng(latu, longu),
        zoom: 19.0,
        tilt: 59.0,
      );

  Future<void> _goToCloseUp() async {
    final GoogleMapController controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_closeUpPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
            markerId: MarkerId('current_location'),
            position: LatLng(latu, longu),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: "Your Location"),
          ),
          ...doctorLocations.map(
            (loc) => Marker(
              markerId: MarkerId(loc.toString()),
              position: loc,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(title: "Doctor Location"),
            ),
          ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCloseUp,
        label: const Text('Closer Look!'),
        icon: const Icon(Icons.zoom_in_map),
      ),
    );
  }
}
