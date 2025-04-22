// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/cartStoreProvider.dart';
import 'package:veterinary_app/utils/cartTile.dart';

class CartPage extends StatefulWidget {
  final String UserId;
  final String switchValue;
  const CartPage({super.key, required this.UserId, required this.switchValue});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
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
          padding: const EdgeInsets.only(top: 35.0, left: 18, right: 18),
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
              Expanded(child: Consumer<CartStoreProvider>(
                  builder: (context, cartStore, child) {
                return cartStore.userWishList.isEmpty
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
                        itemCount: cartStore.userWishList.length,
                        itemBuilder: (context, index) {
                          final pet = cartStore.userWishList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: CartTile(
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
                                ownerId: pet['ownerId']),
                          );
                        },
                      );
              }))
            ],
          ),
        ),
      ),
    ]);
  }
}
