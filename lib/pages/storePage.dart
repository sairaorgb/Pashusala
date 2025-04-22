// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/cartStoreProvider.dart';
import 'package:veterinary_app/utils/petTile.dart';

class storePage extends StatefulWidget {
  String currentUserId;
  String switchValue;
  storePage(
      {super.key, required this.currentUserId, required this.switchValue});

  @override
  State<storePage> createState() => _storePageState();
}

class _storePageState extends State<storePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          // height: 700,
          decoration: BoxDecoration(
            color: Color.fromRGBO(240, 232, 213, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pets Waiting For You',
                  style: GoogleFonts.dmSerifDisplay(
                      fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 12),
                  child: TextField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search",
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 450,
                child: Expanded(child: Consumer<CartStoreProvider>(
                    builder: (context, cartStore, child) {
                  if (cartStore.petStoreList.isEmpty) {
                    return CircularProgressIndicator();
                  }
                  return ListView.builder(
                      itemCount: cartStore.petStoreList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final pet = cartStore.petStoreList[index];
                        return petTile(
                          switchValue: widget.switchValue,
                          name: pet['name'],
                          breed: pet['breed'],
                          animalType: pet['animalType'],
                          age: pet['age'],
                          height: pet['height'],
                          weight: pet['weight'],
                          CurrentUserId: widget.currentUserId,
                          PetId: pet['petId'],
                          PetPrice: pet['petPrice'],
                          ownerName: pet['ownerName'],
                          ownerEmail: pet['ownerEmail'],
                          ownerId: pet['ownerId'],
                        );
                      });
                })),
              ),
            ]),
          ),
        )
      ],
    );
  }
}
