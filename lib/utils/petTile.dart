// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veterinary_app/pages/soloChat.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class petTile extends StatefulWidget {
  final String switchValue;
  final String breed;
  final double height;
  final double weight;
  final int age;
  final String name;
  final String animalType;
  final String CurrentUserId;
  final String PetId;
  final String PetPrice;
  final String ownerName;
  final String ownerEmail;
  final String ownerId;

  petTile(
      {super.key,
      required this.switchValue,
      required this.name,
      required this.breed,
      required this.animalType,
      required this.age,
      required this.height,
      required this.weight,
      required this.CurrentUserId,
      required this.PetId,
      required this.PetPrice,
      required this.ownerName,
      required this.ownerEmail,
      required this.ownerId});

  @override
  State<petTile> createState() => _petTileState();
}

class _petTileState extends State<petTile> {
  bool addedToWishList = false;
  Future<String> addPetToCart(
      {required String userid, required String petid}) async {
    try {
      // Reference to your Firestore collection
      var snapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(userid)
          .collection('userCart')
          .where('petId', isEqualTo: petid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return "already added";
      } else {
        CollectionReference userCart = FirebaseFirestore.instance
            .collection('users_data')
            .doc(userid)
            .collection('userCart');
        userCart.add({'petId': petid});
        return "success";
      }
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 18),
      width: 280,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(children: [
              GestureDetector(
                onDoubleTap: () async {
                  var response = await addPetToCart(
                    userid: widget.CurrentUserId,
                    petid: widget.PetId,
                  );
                  if (response == "success") {
                    addedToWishList = true;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text('Successfully added!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(), // Close the dialog
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    addedToWishList = true;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text('Already added in your Cart!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(), // Close the dialog
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Image.asset(
                  getImagePath(widget.animalType, widget.breed),
                  height: 250,
                  width: 280,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: addedToWishList
                      ? Icon(
                          Icons.favorite,
                          size: 28,
                          color: Colors.red,
                        )
                      : Icon(
                          Icons.favorite_border_outlined,
                          size: 28,
                          color: Colors.white,
                        ),
                ),
              )
            ]),
          ),
          SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              "${widget.name} is a ${widget.age}-year-old ${widget.animalType} of ${widget.breed} breed ready to bring joy and love to your life!",
              style: GoogleFonts.inter(color: Colors.grey[800], fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.breed,
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  "₹ " + widget.PetPrice,
                  style: GoogleFonts.dmSerifDisplay(
                      fontWeight: FontWeight.w500, fontSize: 24),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                          switchValue: widget.switchValue,
                          recieverRole: "customer",
                          receiverName: widget.ownerName,
                          receiverEmail: widget.ownerEmail,
                          receiverID: widget.ownerId),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.forum,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
