import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/clinicLocationProvider.dart';

class Mappage extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  const Mappage(
      {super.key, required this.userLatitude, required this.userLongitude});

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  late double centerLatitude;
  late double centerLongitude;
  LatLng? selectedMarkerPosition;
  DocumentSnapshot? selectedClinic;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  List<DocumentSnapshot> clinics = [];

  @override
  void initState() {
    super.initState();
    centerLatitude = widget.userLatitude;
    centerLongitude = widget.userLongitude;
    clinics = context.read<Cliniclocationprovider>().nearbyClinics;
  }

  CameraPosition get _initialPosition => CameraPosition(
        target: LatLng(centerLatitude, centerLongitude),
        zoom: 14.0,
      );

  CameraPosition get _closeUpPosition => CameraPosition(
        target: LatLng(centerLatitude, centerLongitude),
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
      body: Stack(children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: {
            Marker(
              markerId: MarkerId('current_location'),
              position: LatLng(centerLatitude, centerLongitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: "Your Location"),
            ),
            ...clinics.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final geoPoint = data['geo']['geopoint'] as GeoPoint;
              final doctorId = data['doctorID'] ?? 'Unknown Doctor';

              return Marker(
                markerId: MarkerId(doctorId),
                position: LatLng(geoPoint.latitude, geoPoint.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                onTap: () {
                  setState(() {
                    selectedMarkerPosition =
                        LatLng(geoPoint.latitude, geoPoint.longitude);
                    selectedClinic = doc;
                  });
                },
              );
            }),
          }.toSet(),
        ),
        if (selectedMarkerPosition != null && selectedClinic != null)
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/greenuserdp.jpg',
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // selectedClinic!['clinicName'] ??
                            'Doctor',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Distance: 3.2 km"),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // open chat screen
                      },
                      child: Text("Chat"),
                    ),
                  ],
                ),
              ),
            ),
          )
      ]),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToCloseUp,
      //   label: const Text('Closer Look!'),
      //   icon: const Icon(Icons.zoom_in_map),
      // ),
    );
  }
}
