import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CartStoreProvider extends ChangeNotifier {
  var tempBox = Hive.box('myBox');
  List<Map<String, dynamic>> petStoreList = [];
  List<Map<String, dynamic>> userWishList = [];
  late User? currentUser;
  late FirebaseFirestore fbStoreInstance;

  void initCSP() async {
    currentUser = FirebaseAuth.instance.currentUser;
    fbStoreInstance = FirebaseFirestore.instance;

    await fetchOnSalePets();

    if (userWishList.isEmpty) {
      if (tempBox.containsKey('userWishList')) {
        var rawList = tempBox.get("userWishList") as List<dynamic>? ?? [];
        userWishList = rawList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        var docsnap = await fbStoreInstance
            .collection("users_data")
            .doc(currentUser?.uid)
            .get();
        if (!docsnap.exists) tempBox.put("userWishList", []);
        if (docsnap.exists) {
          userWishList = await fetchUserCart() ?? [];
          updateDatabase("userWishList", userWishList);
        }
      }
      notifyListeners();
    }
  }

  void updateDatabase(String key, var value) {
    tempBox.put(key, value);
  }

  Future<void> fetchOnSalePets() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('petStore').get();

      final fetchedPets = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Unknown',
          'animalType': data['animalType'] ?? 'Unknown',
          'breed': data['breed'] ?? 'UnKnown',
          'age': data['age'] ?? 0,
          'height': data['height'] ?? 0.0,
          'weight': data['weight'] ?? 0.0,
          'petId': data['petId'],
          'petPrice': data['petPrice'] ?? '0',
          'ownerEmail': data['ownerEmail'],
          'ownerId': data['ownerId'],
          'ownerName': data['ownerName'],
        };
      }).toList();

      petStoreList = fetchedPets;
      updateDatabase("petStoreList", petStoreList);
    } catch (e) {
      print('Error fetching pets: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> fetchUserCart() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(currentUser?.uid)
          .collection('userCart')
          .get();

      var userCartIds = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['petId'];
      }).toList();

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('petStore')
          .where('petId', whereIn: userCartIds)
          .get();

      final fetchedPets = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Unknown',
          'animalType': data['animalType'] ?? 'Unknown',
          'breed': data['breed'] ?? 'UnKnown',
          'age': data['age'] ?? 0,
          'height': data['height'] ?? 0.0,
          'weight': data['weight'] ?? 0.0,
          'petId': data['petId'],
          'petPrice': data['petPrice'] ?? '',
          'ownerEmail': data['ownerEmail'],
          'ownerId': data['ownerId'],
          'ownerName': data['ownerName'],
        };
      }).toList();
      notifyListeners();
      return fetchedPets;
    } catch (e) {
      print('Error fetching pets: $e');
    }
    return null;
  }

  Future<String> addPetToCart({required String petid}) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(currentUser?.uid)
          .collection('userCart')
          .where('petId', isEqualTo: petid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return "already added";
      } else {
        await FirebaseFirestore.instance
            .collection('users_data')
            .doc(currentUser?.uid)
            .collection('userCart')
            .add({'petId': petid});
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection('petStore')
            .where('petId', isEqualTo: petid)
            .get();

        Map<String, dynamic> fetchedPet = {};

        if (snap.docs.isNotEmpty) {
          final data = snap.docs.first.data() as Map<String, dynamic>;
          fetchedPet = {
            'name': data['name'] ?? 'Unknown',
            'animalType': data['animalType'] ?? 'Unknown',
            'breed': data['breed'] ?? 'Unknown',
            'age': data['age'] ?? 0,
            'height': data['height'] ?? 0.0,
            'weight': data['weight'] ?? 0.0,
            'petId': data['petId'],
            'petPrice': data['petPrice'] ?? '',
            'ownerEmail': data['ownerEmail'],
            'ownerId': data['ownerId'],
            'ownerName': data['ownerName'],
          };
        }

        userWishList.add(fetchedPet);
        updateDatabase("userWishList", userWishList);
        notifyListeners();
        return "success";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> removePetFromCart(String petid) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(currentUser?.uid)
          .collection('userCart')
          .where('petId', isEqualTo: petid)
          .get();

      final cartInstance = snapshot.docs.map((doc) {
        return doc.id;
      }).toList();

      if (cartInstance.isNotEmpty) {
        String petId = cartInstance[0];

        await FirebaseFirestore.instance
            .collection('users_data')
            .doc(currentUser?.uid)
            .collection('userCart')
            .doc(petId)
            .delete();
        print(petid);
        print(petId);
        userWishList.removeWhere((pet) => pet['petId'] == petid);
        updateDatabase("userWishList", userWishList);
        notifyListeners();
      } else {
        print('No matching pet found in cart.');
      }
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }
}
