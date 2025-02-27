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

  cartTile({
    super.key,
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
    required this.removeItemFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              getImagePath(animalType, breed),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(width: 17), // Space between image & content

          // 📌 Content (Title, Subtitle, Buttons)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Name
                Text(
                  PetName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Animal Type
                Text(
                  animalType,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                SizedBox(height: 6),

                // Price + Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      "₹ $PetPrice",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[700],
                      ),
                    ),

                    // Action Buttons
                    Row(
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
                                receiverID: ownerId,
                              ),
                            ),
                          ),
                          icon: Icon(Icons.forum, size: 26),
                        ),
                        IconButton(
                          onPressed: () {
                            removeItemFromCart(UserId, PetId);
                          },
                          icon: Icon(Icons.delete_outline,
                              size: 26, color: Colors.red),
                        ),
                      ],
                    ),
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
