// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veterinary_app/utils/homePetTile.dart';
import 'package:veterinary_app/utils/petTile.dart';

class storePage extends StatefulWidget {
  String currentUserId;
  String switchValue;
  storePage(
      {super.key, required this.currentUserId, required this.switchValue});

  @override
  State<storePage> createState() => _storePageState();
}

class _storePageState extends State<storePage> {
  List<Map<String, dynamic>> petList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchOnSalePets();
    });
  }

  Future<void> fetchOnSalePets() async {
    try {
      // Fetch pets from the "pets" collection
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('petStore').get();

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
          'petId': data['petId'],
          'petPrice': data['petPrice'] ?? '0',
          'ownerEmail': data['ownerEmail'],
          'ownerId': data['ownerId'],
          'ownerName': data['ownerName'],
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
    return Stack(
      children: [
        Container(
          // height: 700,
          decoration: BoxDecoration(
            color: Color.fromRGBO(240, 232, 213, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pets Waiting For You',
                  style: GoogleFonts.dmSerifDisplay(
                      fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 12),
                child: TextField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)))),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 450,
                child: Expanded(
                    child: ListView.builder(
                        itemCount: petList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final pet = petList[index];
                          return petTile(
                            switchValue: widget.switchValue,
                            name: pet['name'],
                            breed: pet['breed'],
                            animalType: pet['animalType'],
                            age: pet['age'],
                            height: pet['height'],
                            weight: pet['weight'],
                            CurrentUserId: widget.currentUserId,
                            PetId: pet['petId'],
                            PetPrice: pet['petPrice'],
                            ownerName: pet['ownerName'],
                            ownerEmail: pet['ownerEmail'],
                            ownerId: pet['ownerId'],
                          );
                        })),
              ),
            ]),
          ),
        )
      ],
    );
  }
}
