import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class Cliniclocationprovider with ChangeNotifier {
  final fbStoreInstance = FirebaseFirestore.instance;
  StreamSubscription? _urgentDoctorsSubscription;

  List<DocumentSnapshot> _nearbyClinics = [];
  List<DocumentSnapshot> get nearbyClinics => _nearbyClinics;

  List<DocumentSnapshot> _urgentDoctors = [];
  List<DocumentSnapshot> get urgentDoctors => _urgentDoctors;

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

  void listenToUrgentDoctors(double lat, double lng) {
    final collectionRef = fbStoreInstance
        .collection('locations')
        .doc('urgentLocations')
        .collection('urgent_locations');

    final geoCollection = GeoCollectionReference(collectionRef);
    final center = GeoFirePoint(GeoPoint(lat, lng));

    _urgentDoctorsSubscription?.cancel();

    _urgentDoctorsSubscription = geoCollection
        .subscribeWithinWithDistance(
      center: center,
      radiusInKm: 10,
      field: 'geo',
      geopointFrom: (doc) =>
          (doc['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
    )
        .listen((geoDocs) {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(Duration(minutes: 5));
      final filteredDocs = geoDocs.where((geoDoc) {
        final doc = geoDoc.documentSnapshot;
        final createdAt = doc['createdAt'];
        if (createdAt is Timestamp) {
          return createdAt.toDate().isAfter(fiveMinutesAgo);
        } else if (createdAt is DateTime) {
          return createdAt.isAfter(fiveMinutesAgo);
        }
        return false;
      }).toList();
      _urgentDoctors =
          filteredDocs.map((geoDoc) => geoDoc.documentSnapshot).toList();
      notifyListeners(); // update UI
    });
  }
}
