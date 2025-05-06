// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/cartStoreProvider.dart';
import 'package:veterinary_app/pages/soloChat.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class CartTile extends StatelessWidget {
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

  const CartTile({
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(250, 243, 235, 1),
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
              width: 100,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(width: 17), // Space between image & content

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Name
                Text(
                  PetName,
                  style: GoogleFonts.sansita(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                // Animal Type
                Text(
                  breed,
                  style: GoogleFonts.sahitya(
                      fontSize: 16, color: Colors.grey[700]),
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
                                receiverID: ownerId,
                              ),
                            ),
                          ),
                          icon: Icon(Icons.forum, size: 26),
                        ),
                        IconButton(
                            onPressed: () => context
                                .read<CartStoreProvider>()
                                .removePetFromCart(PetId),
                            icon: Icon(
                              Icons.delete_outline,
                              size: 26,
                              color: Colors.red,
                            ))
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
