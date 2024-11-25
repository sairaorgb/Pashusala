// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class cartTile extends StatelessWidget {
  final String UserId;
  final String PetId;
  final int Price;
  final String breed;
  final String PetName;
  final String animalType;
  final Future<void> Function(String, String) removeItemFromCart;
  cartTile(
      {super.key,
      required this.UserId,
      required this.PetId,
      required this.PetName,
      required this.breed,
      required this.Price,
      required this.animalType,
      required this.removeItemFromCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 80,
        child: ListTile(
          leading: Image.asset(
            getImagePath(animalType, breed),
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
          title: Text(
            PetName,
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(animalType),
          trailing: IconButton(
              onPressed: () {
                removeItemFromCart(UserId, PetId);
              },
              icon: const Icon(
                Icons.delete_outline,
                size: 28,
              )),
        ),
      ),
    );
  }
}
