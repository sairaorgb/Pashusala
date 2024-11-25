// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/utils/cartTile.dart';

class cartPage extends StatefulWidget {
  final String UserId;
  cartPage({super.key, required this.UserId});

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
          'name': data['petType'] ?? 'Unknown',
          'breed': data['breed'] ?? 'UnKnown',
          'age': data['age'] ?? 0,
          'height': data['height'] ?? 0.0,
          'weight': data['weight'] ?? 0.0,
          'petId': data['petId'],
        };
      }).toList();

      setState(() {
        petList = fetchedPets;
      });
    } catch (e) {
      print('Error fetching pets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                        "Your cart is empty.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ))
                : ListView.builder(
                    itemCount: petList.length,
                    itemBuilder: (context, index) {
                      final pet = petList[index];
                      return cartTile(
                        UserId: widget.UserId,
                        PetId: pet['petId'],
                        PetName: pet['name'],
                        Price: pet['age'],
                      );
                    },
                  ))
      ],
    );
  }
}
