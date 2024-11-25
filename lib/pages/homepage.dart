// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:veterinary_app/pages/cartPage.dart';
import 'package:veterinary_app/pages/storePage.dart';
import 'package:veterinary_app/utils/addPetDialogue.dart';
import 'package:veterinary_app/utils/homePetTile.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class homePage extends StatefulWidget {
  String switchValue;
  String currentUserId;
  homePage({super.key, required this.switchValue, required this.currentUserId});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  List<Map<String, dynamic>> petList = [];
  String? _currentUserId;
  bool _switchValue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPets(widget.currentUserId);
    });
  }

  Future<void> fetchPets(String currentUserId) async {
    try {
      // Fetch pets from the "pets" collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(currentUserId)
          .collection('petsOwned')
          .get();

      // Map the fetched data to a list of pet details
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

      // Update the petList state
      setState(() {
        petList = fetchedPets;
      });
    } catch (e) {
      print('Error fetching pets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, String> args =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    // String? currentUserId = args['userId'];

    // if (args['switchValue'] == "true") {
    //   switchValue = true;
    // }
    String _currentUserId = widget.currentUserId;
    if (widget.switchValue == "true") {
      _switchValue = true;
    }

    return Stack(
      children: [
        Container(
          height: 700,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // "My Pets" text on the left
                    Text(
                      "My Pets",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Three dots (more_vert icon) on the right
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'add_pet') {
                          // Show the dialog when "Add New Pet" is selected
                          showDialog(
                            context: context,
                            builder: (context) => ShowPetInfoDialog(
                              currentUserId: _currentUserId,
                              onPetAdded: () => fetchPets(_currentUserId),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'add_pet',
                          child: Text("Add New Pet"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: petList.length,
                  itemBuilder: (context, index) {
                    final pet = petList[index];
                    return homePageTile(
                      name: pet['name'],
                      animalType: pet['animalType'],
                      age: pet['age'],
                      height: pet['height'],
                      weight: pet['weight'],
                      breed: pet['breed'],
                      currentUserId: _currentUserId,
                      status: pet['status'],
                      petId: pet['petId'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
