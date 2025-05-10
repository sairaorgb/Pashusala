// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:veterinary_app/clinicLocationProvider.dart';
import 'package:veterinary_app/homePetsProvider.dart';
import 'package:veterinary_app/pages/soloChat.dart';
import 'package:veterinary_app/utils/slotBoolkingDialogue.dart';

class Mappage extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  final String mapType;
  const Mappage(
      {super.key,
      required this.userLatitude,
      required this.userLongitude,
      required this.mapType});

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  late double centerLatitude;
  late double centerLongitude;
  LatLng? selectedMarkerPosition;
  DocumentSnapshot? selectedClinic;

  late List<DocumentSnapshot> clinics;
  late List<Map<String, dynamic>> items;

  String? doctorName;
  String? doctorId;
  GeoPoint? geoPoint;
  bool hoverDoctor = false;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    centerLatitude = widget.userLatitude;
    centerLongitude = widget.userLongitude;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      items = context.read<HomepetsProvider>().petList;
    });
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

  void _onMarkerTapped(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      hoverDoctor = true;
      selectedClinic = doc;
      doctorName = data['doctorName'] ?? 'Unknown Doctor';
      doctorId = data['doctorID'] ?? 'Unknown Doctor';
      geoPoint = data['geo']['geopoint'] as GeoPoint;
      selectedMarkerPosition = LatLng(geoPoint!.latitude, geoPoint!.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    clinics = (widget.mapType == "urgentDoctors")
        ? context.watch<Cliniclocationprovider>().urgentDoctors
        : context.watch<Cliniclocationprovider>().nearbyClinics;
    return Scaffold(
      appBar: (hoverDoctor)
          ? AppBar(
              backgroundColor: const Color.fromARGB(255, 76, 99, 51),
              automaticallyImplyLeading: false,
              toolbarHeight: 140,
              titleSpacing: 0,
              title: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/doctordp.png',
                        height: 75,
                        width: 65,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            doctorName ?? 'Unknown Doctor',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Veterinary Specialist',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (geoPoint != null) {
                              final String googleMapsUrl =
                                  "https://www.google.com/maps/dir/?api=1&travelmode=walking&destination=${geoPoint!.latitude},${geoPoint!.longitude}";
                              await canLaunchUrl(Uri.parse(googleMapsUrl))
                                  ? launchUrl(Uri.parse(googleMapsUrl))
                                  : throw 'Could not launch Google Maps';
                            }
                          },
                          icon: const Icon(Icons.navigation),
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {
                            if (doctorName != null && doctorId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    receiverName: doctorName!,
                                    receiverID: doctorId!,
                                    switchValue: "true",
                                    recieverRole: "doctor",
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          color: Colors.white,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (doctorName != null && doctorId != null) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return BookingDialog(
                                    items: items,
                                    doctorName: doctorName!,
                                    doctorId: doctorId!,
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                color: Color(0xFF9CAF88),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : AppBar(),
      body: Stack(children: [
        GoogleMap(
          mapType: MapType.normal,
          mapToolbarEnabled: false,
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
              onTap: () => setState(() {
                selectedClinic = null;
                hoverDoctor = false;
                doctorName = null;
                doctorId = null;
                geoPoint = null;
                selectedMarkerPosition = null;
              }),
            ),
            ...clinics.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final GeoPoint point = data['geo']['geopoint'] as GeoPoint;
              final String docId = data['doctorID'] ?? 'Unknown Doctor';

              return Marker(
                markerId: MarkerId(docId),
                position: LatLng(point.latitude, point.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                onTap: () => _onMarkerTapped(doc),
              );
            }),
          }.toSet(),
        ),
      ]),
    );
  }
}
