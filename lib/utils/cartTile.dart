// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/pages/soloChat.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class cartTile extends StatelessWidget {
  final String switchValue;
  final String UserId;
  final String PetId;
  final int Price;
  final String breed;
  final String PetName;
  final String animalType;
  final String PetPrice;
  final String ownerName;
  final String ownerEmail;
  final String ownerId;
  final Future<void> Function(String, String) removeItemFromCart;
  cartTile(
      {super.key,
      required this.switchValue,
      required this.UserId,
      required this.PetId,
      required this.PetName,
      required this.breed,
      required this.Price,
      required this.animalType,
      required this.PetPrice,
      required this.ownerName,
      required this.ownerEmail,
      required this.ownerId,
      required this.removeItemFromCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      // margin: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 80,
        child: ListTile(
          leading: Container(
            // margin: const EdgeInsets.all(2),
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Background color for image container
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                getImagePath(animalType, breed),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            PetName,
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(animalType),
          trailing: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "₹ " + PetPrice,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                    switchValue: switchValue,
                                    recieverRole: "customer",
                                    receiverName: ownerName,
                                    receiverEmail: ownerEmail,
                                    receiverID: ownerId),
                              ),
                            ),
                        icon: const Icon(
                          Icons.forum,
                          size: 28,
                        )),
                    IconButton(
                        onPressed: () {
                          removeItemFromCart(UserId, PetId);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 28,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
