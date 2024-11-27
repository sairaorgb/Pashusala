// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class homePageTile extends StatefulWidget {
  final String name;

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
      {required String userid,
      required String petid,
      required String petprice}) async {
    try {
      // Reference to your Firestore collection
      CollectionReference pets =
          FirebaseFirestore.instance.collection('petStore');
      var snapshot = await pets.where('petId', isEqualTo: petid).get();
      var userid = await FirebaseAuth.instance.currentUser?.uid;
      var username = '';
      var useremail = '';
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(userid)
          .get();
      if (documentSnapshot.exists) {
        // Extract the username field
        username = documentSnapshot.data()?['userName'] as String;
        useremail = documentSnapshot.data()?['userEmail'] as String;
      } else {
        print('Document does not exist');
      }
      if (snapshot.docs.isEmpty) {
        await pets.add({
          'name': widget.name,
          'animalType': widget.animalType,
          'breed': widget.breed,
          'age': widget.age,
          'height': widget.height,
          'weight': widget.weight,
          'petId': widget.petId,
          'petPrice': petprice,
          'ownerId': userid,
          'ownerName': username,
          'ownerEmail': useremail
        });
      }

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

  Future<String> removePetFromCart(
      {required String petid, required String userid}) async {
    CollectionReference pets =
        FirebaseFirestore.instance.collection('petStore');
    var snapshot = await pets.where('petId', isEqualTo: petid).get();
    FirebaseFirestore.instance
        .collection('users_data')
        .doc(userid)
        .collection('petsOwned')
        .doc(petid)
        .update({'status': "PUT ON SALE"});
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      await pets.doc(doc.id).delete();
    }

    setState(() {
      statusState = "PUT ON SALE";
    });
    return "PUT ON SALE";
  }

  Widget build(BuildContext context) {
    TextEditingController priceController = TextEditingController();
    var status = (statusState == "") ? widget.status : statusState;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              // Image section
              Container(
                margin: const EdgeInsets.all(10),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // Background color for image container
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    getImagePath(widget.animalType, widget.breed),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Details section
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.male, // Gender icon
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      Text(
                        widget.animalType,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          // Text(
                          //   '${widget.location} (${widget.distance})',
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Expand/Collapse Button
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ],
          ),
          // Expanded Details Section
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoBox("Age", "${widget.age}"),
                      _infoBox("Height", "${widget.height}"),
                      _infoBox("Breed", widget.breed),
                      _infoBox("Weight", "${widget.weight}"),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Call, Chat, and Adopt Button row
                  Row(
                    children: [
                      // Call icon button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue[50],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            print("Call button pressed");
                          },
                          child: Icon(
                            Icons.call,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chat icon button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue[50],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            print("Chat button pressed");
                          },
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                          flex: 2,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: status == "ON SALE"
                                    ? Colors.red
                                    : Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () async {
                                if (status != "ON SALE") {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Set a Price for your pet'),
                                        content: TextField(
                                          controller: priceController,
                                          keyboardType: TextInputType.number,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              status = await addPetToCart(
                                                  userid: widget.currentUserId,
                                                  petid: widget.petId,
                                                  petprice:
                                                      priceController.text);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Put for Sale'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  status = await removePetFromCart(
                                      petid: widget.petId,
                                      userid: widget.currentUserId);
                                }
                              },
                              child: Container(
                                child: Text(
                                  status,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _infoBox(String title, String value) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}
