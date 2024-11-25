import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class petTile extends StatelessWidget {
  final String breed;
  final double height;
  final double weight;
  final int age;
  final String name;
  final String animalType;
  final String CurrentUserId;
  final String PetId;

  petTile(
      {super.key,
      required this.name,
      required this.breed,
      required this.animalType,
      required this.age,
      required this.height,
      required this.weight,
      required this.CurrentUserId,
      required this.PetId});

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
      margin: const EdgeInsets.only(left: 25),
      width: 280,
      height: 250, // Set your desired height here
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              getImagePath(animalType, breed),
              height: 300, // Adjust the height of the image as needed
              width: 300,
              // width: double.infinity, // Make the image fill the width
              fit: BoxFit.cover, // Adjust the image to fit within its container
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              "$name is a $age-year-old $breed $animalType ready to bring joy and love to your life!",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animalType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      breed,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    var response = await addPetToCart(
                      userid: CurrentUserId,
                      petid: PetId,
                    );
                    if (response == "success") {
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
                      Icons.add,
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
