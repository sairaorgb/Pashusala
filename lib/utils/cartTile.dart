// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class cartTile extends StatelessWidget {
  final String UserId;
  final String PetId;
  final int Price;
  final String PetName;
  cartTile(
      {super.key,
      required this.UserId,
      required this.PetId,
      required this.PetName,
      required this.Price});

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
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Image.asset('assets/images/logo.png'),
        title: Text(PetName),
        subtitle: Text(PetName),
        trailing: IconButton(
            onPressed: () {
              removeItemFromCart(UserId, PetId);
            },
            icon: const Icon(Icons.delete)),
      ),
    );
  }
}
