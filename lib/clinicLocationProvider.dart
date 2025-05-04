import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cliniclocationprovider with ChangeNotifier {
  final fbStoreInstance = FirebaseFirestore.instance;

  List<DocumentSnapshot> _nearbyClinics = [];
  List<DocumentSnapshot> get nearbyClinics => _nearbyClinics;

  Future<void> fetchNearbyClinics(double lat, double lng) async {
    final collectionRef = fbStoreInstance
        .collection('locations')
        .doc('clinicLocations')
        .collection('clinic_locations');

    final geoCollection = GeoCollectionReference(collectionRef);
    final center = GeoFirePoint(GeoPoint(lat, lng));

    final geoDocs = await geoCollection.fetchWithinWithDistance(
      center: center,
      radiusInKm: 10,
      field: 'geo',
      geopointFrom: (doc) =>
          (doc['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
    );

    _nearbyClinics = geoDocs.map((geoDoc) => geoDoc.documentSnapshot).toList();

    notifyListeners(); // notifies widgets listening to this provider
  }
}

class ClinicMarkerData {
  final String doctorId;
  final LatLng location;

  ClinicMarkerData({
    required this.doctorId,
    required this.location,
  });
}
