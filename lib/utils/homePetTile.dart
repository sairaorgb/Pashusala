// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class homePageTile extends StatefulWidget {
  final String name;
  final String imagePath;
  final int age;
  final double height;
  final double weight;
  final String breed;
  final String currentUserId;
  final String petId;
  final String status;
  final String animalType;
  const homePageTile(
      {super.key,
      required this.name,
      required this.animalType,
      required this.imagePath,
      required this.age,
      required this.height,
      required this.weight,
      required this.breed,
      required this.currentUserId,
      required this.status,
      required this.petId});

  @override
  State<homePageTile> createState() => _homePageTileState();
}

class _homePageTileState extends State<homePageTile> {
  bool isExpanded = false;
  String statusState = "";

  Future<String> addPetToCart(
      {required String userid, required String petid}) async {
    try {
      // Reference to your Firestore collection
      CollectionReference pets =
          FirebaseFirestore.instance.collection('petStore');

      // Adding data
      await pets.add({
        'petType': widget.animalType,
        'breed': widget.breed,
        'age': widget.age,
        'height': widget.height,
        'weight': widget.weight,
        'petId': widget.petId
      });

      FirebaseFirestore.instance
          .collection('users_data')
          .doc(userid)
          .collection('petsOwned')
          .doc(petid)
          .update({'status': "ON SALE"});
      setState(() {
        statusState = "ON SALE";
      });

      return "ON SALE";
    } catch (e) {
      return e.toString();
    }
  }

  Widget build(BuildContext context) {
    var status = (statusState == "") ? widget.status : statusState;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(
              widget.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(widget.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age: ${widget.age} years'),
                  Text('Height: ${widget.height} cm'),
                  Text('Weight: ${widget.weight} kg'),
                  ElevatedButton(
                      onPressed: () async {
                        status = await addPetToCart(
                            userid: widget.currentUserId, petid: widget.petId);
                      },
                      child: Container(
                        color: status == "ON SALE" ? Colors.green : Colors.red,
                        child: Text(
                          widget.status,
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                ],
              ),
            ),
        ],
      ),
    );
  }
}
