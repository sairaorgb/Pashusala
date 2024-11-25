import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/utils/homePetTile.dart';
import 'package:veterinary_app/utils/petTile.dart';

class storePage extends StatefulWidget {
  String currentUserId;
  storePage({super.key, required this.currentUserId});

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
          'name': data['petType'] ?? 'Unknown',
          'breed': data['breed'] ?? 'UnKnown',
          'age': data['age'] ?? 0,
          'height': data['height'] ?? 0.0,
          'weight': data['weight'] ?? 0.0,
          'petId': data['petId'],
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
    return Column(children: [
      Container(
        padding: const EdgeInsetsDirectional.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Search", style: TextStyle(color: Colors.grey)),
            Icon(Icons.search, color: Colors.grey)
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Text("Everyone flies... some fly longer than others",
            style: TextStyle(color: Colors.grey[600])),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Pets Waiting For You',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "See All",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      const SizedBox(
        height: 10,
      ),
      Expanded(
          child: ListView.builder(
              itemCount: petList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final pet = petList[index];
                return petTile(
                  breed: pet['breed'],
                  animalType: pet['name'],
                  age: pet['age'],
                  height: pet['height'],
                  weight: pet['weight'],
                  CurrentUserId: widget.currentUserId,
                  PetId: pet['petId'],
                );
              })),
    ]);
  }
}
