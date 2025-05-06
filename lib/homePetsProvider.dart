import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:veterinary_app/database.dart';

class HomepetsProvider extends ChangeNotifier {
  var tempBox = Hive.box('myBox');

  late User? user;
  late FirebaseFirestore? fbStoreInstance;

  double? selectedLatitude;
  double? selectedLongitude;

  bool isAddressModified = false;
  late bool isDoctor;
  late String selectedIndex = "Current";

  // Map<String, Map<String, dynamic>>? currentMap;
  List<Map<String, dynamic>> petList = [];
  Map<String, Map<String, dynamic>> savedAddress = {};

  void logout() {
    user = null;
    fbStoreInstance = null;
    petList = [];
    savedAddress = {};
  }

  Future<void> initDatabase() async {
    user = FirebaseAuth.instance.currentUser;
    fbStoreInstance = FirebaseFirestore.instance;

    if (savedAddress.isEmpty) {
      if (tempBox.containsKey('savedAddress')) {
        final rawMap =
            tempBox.get("savedAddress") as Map<dynamic, dynamic>? ?? {};
        selectedIndex = tempBox.get("selectedIndex");

        savedAddress = rawMap.map((key, value) => MapEntry(
              key.toString(),
              Map<String, dynamic>.from(value as Map),
            ));
      } else {
        if (!isDoctor) {
          var docsnap = await fbStoreInstance!
              .collection("users_data")
              .doc(user?.uid)
              .get();
          if (!docsnap.exists) tempBox.put("savedAddress", []);
          if (docsnap.exists) {
            savedAddress = (await fetchAddress(user!.uid)) ?? {};
            updateDatabase("savedAddress", savedAddress);
          }
        } else {
          var docsnap = await fbStoreInstance!
              .collection("doctors_data")
              .doc(user?.uid)
              .get();
          if (!docsnap.exists) tempBox.put("savedAddress", []);
          if (docsnap.exists) {
            savedAddress = (await fetchAddress(user!.uid)) ?? {};
            updateDatabase("savedAddress", savedAddress);
          }
        }
      }
    }
    if (petList.isEmpty) {
      if (tempBox.containsKey('petList')) {
        var rawList = tempBox.get("petList") as List<dynamic>? ?? [];
        petList = rawList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        var docsnap = await fbStoreInstance!
            .collection("users_data")
            .doc(user?.uid)
            .get();
        if (!docsnap.exists) tempBox.put("petList", []);
        if (docsnap.exists) {
          petList = (await fetchPets(user!.uid)) ?? [];
          updateDatabase("petList", petList);
        }
      }
    }
    notifyListeners();
  }

  void updateDatabase(String key, var value) {
    tempBox.put(key, value);
  }

  Future<Map<String, Map<String, dynamic>>?> fetchAddress(
      String currentUserId) async {
    if (isDoctor) {
      try {
        final CollectionReference addresses = fbStoreInstance!
            .collection('doctors_data')
            .doc(user?.uid)
            .collection('savedAddress');

        final docSnapshot = await fbStoreInstance!
            .collection('doctors_data')
            .doc(user?.uid)
            .get();

        final data = docSnapshot.data();
        if (data!.containsKey('selectedIndex')) {
          selectedIndex = data['selectedIndex'] as String;
        }

        final querySnapshot = await addresses.get();
        Map<String, Map<String, dynamic>> parsed = {};
        for (final doc in querySnapshot.docs) {
          final rawMap = doc.data() as Map<String, dynamic>;
          final mapped = rawMap.map((key, value) {
            return MapEntry(
              key.toString(),
              Map<String, dynamic>.from(value as Map),
            );
          });
          parsed.addAll(mapped);
        }
        return parsed;
      } catch (e) {
        print('Error fetching pets: $e');
      }
    } else {
      try {
        final CollectionReference addresses = fbStoreInstance!
            .collection('users_data')
            .doc(user?.uid)
            .collection('savedAddress');

        final querySnapshot = await addresses.get();
        Map<String, Map<String, dynamic>> parsed = {};
        for (final doc in querySnapshot.docs) {
          final rawMap = doc.data() as Map<String, dynamic>;
          final mapped = rawMap.map((key, value) {
            return MapEntry(
              key.toString(),
              Map<String, dynamic>.from(value as Map),
            );
          });
          parsed.addAll(mapped);
        }
        return parsed;
      } catch (e) {
        print('Error fetching pets: $e');
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> fetchPets(String currentUserId) async {
    try {
      QuerySnapshot snapshot = await fbStoreInstance!
          .collection('users_data')
          .doc(currentUserId)
          .collection('petsOwned')
          .get();

      final fetchedPets = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Unknown',
          'animalType': data['animalType'] ?? 'Unknown',
          'breed': data['breed'] ?? 'UnKnown',
          'age': data['age'] ?? 0,
          'height': data['height'] ?? 0.0,
          'weight': data['weight'] ?? 0.0,
          'petId': doc.id,
          'status': data['status']
        };
      }).toList();
      return fetchedPets;
    } catch (e) {
      print('Error fetching pets: $e');
    }
    return null;
  }

  Future<void> saveAddressToFirestore({
    required String label,
    required String landmark,
    required String town,
    required String district,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
  }) async {
    if (!isDoctor) {
      try {
        CollectionReference addresses = fbStoreInstance!
            .collection('users_data')
            .doc(user?.uid)
            .collection('savedAddress');

        Map<String, Map<String, dynamic>> newAddress = {
          label: {
            'landmark': landmark,
            'town': town,
            'district': district,
            'pincode': pincode,
            'state': state,
            'latitude': latitude,
            'longitude': longitude,
            'address': [landmark, town, district, pincode, state]
                .where((element) => element.trim().isNotEmpty)
                .join(', ')
          }
        };
        await addresses.doc(label).set(newAddress);
        savedAddress.addAll(newAddress);
        updateDatabase('savedAddress', savedAddress);
        notifyListeners();
      } catch (e) {
        print('Error saving pet details: $e');
      }
    } else {
      try {
        var creferenece =
            fbStoreInstance!.collection('doctors_data').doc(user?.uid);

        var addresses = creferenece.collection('savedAddress');

        Map<String, Map<String, dynamic>> newAddress = {
          label: {
            'landmark': landmark,
            'town': town,
            'district': district,
            'pincode': pincode,
            'state': state,
            'latitude': latitude,
            'longitude': longitude,
            'address': [landmark, town, district, pincode, state]
                .where((element) => element.trim().isNotEmpty)
                .join(', ')
          }
        };
        await addresses.doc(label).set(newAddress);
        savedAddress.addAll(newAddress);
        updateDatabase('savedAddress', savedAddress);
        notifyListeners();
      } catch (e) {
        print('Error saving pet details: $e');
      }
    }
  }

  Future<void> savePetDetailsToFirestore({
    required String petType,
    required String breed,
    required String petName,
    required int age,
    required double height,
    required double weight,
    required String userid,
  }) async {
    try {
      CollectionReference pets = fbStoreInstance!
          .collection('users_data')
          .doc(userid)
          .collection('petsOwned');

      Map<String, dynamic> addedPet = {
        'animalType': petType,
        'breed': breed,
        'name': petName,
        'age': age,
        'height': height,
        'weight': weight,
        'status': "Put On Sale"
      };

      await pets.add(addedPet);
      petList.add(addedPet);
      updateDatabase('petList', petList);
      notifyListeners();
    } catch (e) {
      print('Error saving pet details: $e');
    }
  }

  Future<void> setUsedAddress() async {
    try {
      if (!isDoctor) {
        var userdoc =
            await fbStoreInstance!.collection('users_data').doc(user?.uid).set({
          'userLatitude': selectedLatitude,
          'userLongitude': selectedLongitude,
          "selectedIndex": selectedIndex
        }, SetOptions(merge: true));
      } else {
        await fbStoreInstance!.collection('doctors_data').doc(user?.uid).set({
          'userLatitude': selectedLatitude,
          'userLongitude': selectedLongitude,
          "selectedIndex": selectedIndex,
        }, SetOptions(merge: true));

        final geoPoint = GeoPoint(selectedLatitude!, selectedLongitude!);
        final geoFirePoint = GeoFirePoint(geoPoint);

        final clinicLocations = await fbStoreInstance!
            .collection('locations')
            .doc("clinicLocations")
            .collection("clinic_locations")
            .doc(user?.uid);

        await clinicLocations.set(<String, dynamic>{
          'geo': geoFirePoint.data,
          'doctorID': user!.uid,
          'doctorName': tempBox.get('userName'),
          // "doctorName":
        });
      }
    } catch (e) {
      print('Error saving pet details: $e');
    }
  }
}
