import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HomepetsProvider extends ChangeNotifier {
  var tempBox = Hive.box('myBox');
  late User? user;
  late FirebaseFirestore fbStoreInstance;

  List<Map<String, dynamic>> petList = [];

  Future<void> initDatabase() async {
    user = FirebaseAuth.instance.currentUser;
    fbStoreInstance = FirebaseFirestore.instance;
    if (petList.isEmpty) {
      if (tempBox.containsKey('petList')) {
        var rawList = tempBox.get("petList") as List<dynamic>? ?? [];
        petList = rawList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        var docsnap =
            await fbStoreInstance.collection("users_data").doc(user?.uid).get();
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

  Future<List<Map<String, dynamic>>?> fetchPets(String currentUserId) async {
    try {
      QuerySnapshot snapshot = await fbStoreInstance
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
      CollectionReference pets = fbStoreInstance
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
      notifyListeners();
    } catch (e) {
      print('Error saving pet details: $e');
    }
  }
}
