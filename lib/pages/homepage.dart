// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:veterinary_app/utils/addPetDialogue.dart';
import 'package:veterinary_app/utils/homePetTile.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  List<Map<String, dynamic>> petList = [];
  String? currentUserId;
  bool switchValue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
      currentUserId = args?['userId']; // Retrieve userId from arguments

      if (args?['switchValue'] == "true") {
        switchValue = true;
      }
      if (currentUserId != null) {
        fetchPets(currentUserId!);
      }
    });
  }

  Future<void> fetchPets(String currentUserId) async {
    try {
      // Fetch pets from the "pets" collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users_data')
          .doc(currentUserId)
          .collection('petsOwned')
          .get();

      // Map the fetched data to a list of pet details
      final fetchedPets = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['petType'] ?? 'Unknown',
          'breed': data['breed'] ?? 'UnKnown',
          'age': data['age'] ?? 0,
          'height': data['height'] ?? 0.0,
          'weight': data['weight'] ?? 0.0,
        };
      }).toList();

      // Update the petList state
      setState(() {
        petList = fetchedPets;
      });
    } catch (e) {
      print('Error fetching pets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>;

    return Scaffold(
      backgroundColor: switchValue ? Colors.green[300] : Colors.blue[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 130,
        title: Row(
          children: [
            SizedBox(
              width: 40,
            ),
            SizedBox(
              child: Text(
                "E-Veterinary",
                style: TextStyle(
                    fontSize: 38,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue[200],
        child: ListView(children: [
          DrawerHeader(
            padding: EdgeInsets.all(30),
            child: Text(
              "Quick Access",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            decoration: BoxDecoration(
              color: Colors.blue[200],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              size: 25,
            ),
            title: Text(
              "Home",
              style: TextStyle(fontSize: 20),
            ),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text(
              "Our Story",
              style: TextStyle(fontSize: 20),
            ),
          ),
          ListTile(
            leading: Icon(Icons.miscellaneous_services_rounded),
            title: Text(
              "Services",
              style: TextStyle(fontSize: 20),
            ),
          )
        ]),
      ),
      body: Stack(
        children: [
          Container(),
          Positioned(
              top: 0,
              right: 20,
              child: ShowPetInfoDialog(
                currentUserId: currentUserId!,
                onPetAdded: () => fetchPets(currentUserId!),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 700,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: petList.length,
                          itemBuilder: (context, index) {
                            final pet = petList[index];
                            return homePageTile(
                              name: pet['name'],
                              imagePath: "assets/images/logo.png",
                              age: pet['age'],
                              height: pet['height'],
                              weight: pet['weight'],
                            );
                          },
                        ),
                      ),
                      GNav(
                          activeColor: Colors.black,
                          mainAxisAlignment: MainAxisAlignment.center,
                          color: Colors.grey.shade500,
                          tabBorderRadius: 16,
                          tabs: [
                            GButton(
                              icon: Icons.shopping_cart,
                              text: "shop",
                            ),
                            GButton(
                              icon: Icons.home,
                              text: "home",
                            ),
                            GButton(
                              icon: Icons.menu,
                              text: "menu",
                            )
                          ]),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
