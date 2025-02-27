// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veterinary_app/utils/cartTile.dart';

class cartPage extends StatefulWidget {
  final String UserId;
  final String switchValue;
  cartPage({super.key, required this.UserId, required this.switchValue});

  @override
  State<cartPage> createState() => _cartPageState();
}

class _cartPageState extends State<cartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserCart();
    });
  }

  List<Map<String, dynamic>> petList = [];
  Future<void> fetchUserCart() async {
    try {
      // Fetch pets from the "pets" collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(widget.UserId)
          .collection('userCart')
          .get();

      // Map the fetched data to a list of pet details
      var userCartIds = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['petId'];
      }).toList();

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('petStore')
          .where('petId', whereIn: userCartIds)
          .get();
      print(snap.docs.length);

      // Map the fetched data to a list of pet details
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

      setState(() {
        petList = fetchedPets;
      });
    } catch (e) {
      print('Error fetching pets: $e');
    }
  }

  Future<void> removeItemFromCart(String userid, String petid) async {
    try {
      // Fetch pets from the "userCart" collection where petId matches
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(userid)
          .collection('userCart')
          .where('petId', isEqualTo: petid)
          .get();

      // Map through the snapshot to get the document IDs
      final cartInstance = snapshot.docs.map((doc) {
        return doc.id; // Get the document ID
      }).toList();

      // Check if there's any document to remove
      if (cartInstance.isNotEmpty) {
        String cartId = cartInstance[
            0]; // Get the first document ID (you can handle multiple matches as needed)

        // Delete the specific document
        await FirebaseFirestore.instance
            .collection('users_data')
            .doc(userid)
            .collection('userCart')
            .doc(cartId) // Use the fetched doc ID to remove the document
            .delete();
        setState(() {
          fetchUserCart();
        });

        print('Item successfully removed from cart!');
      } else {
        print('No matching pet found in cart.');
      }
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(240, 232, 213, 1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My WishList",
                style: GoogleFonts.dmSerifDisplay(
                    fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                  child: petList.isEmpty
                      ? const Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Your WishList is empty.",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: petList.length,
                          itemBuilder: (context, index) {
                            final pet = petList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: cartTile(
                                  switchValue: widget.switchValue,
                                  UserId: widget.UserId,
                                  PetId: pet['petId'],
                                  PetName: pet['name'],
                                  animalType: pet['animalType'],
                                  Price: pet['age'],
                                  breed: pet['breed'],
                                  PetPrice: pet['petPrice'],
                                  ownerName: pet['ownerName'],
                                  ownerEmail: pet['ownerEmail'],
                                  ownerId: pet['ownerId'],
                                  removeItemFromCart:
                                      (String userid, String petId) async {
                                    removeItemFromCart(
                                        widget.UserId, pet['petId']);
                                  }),
                            );
                          },
                        ))
            ],
          ),
        ),
      ),
    ]);
  }
}
