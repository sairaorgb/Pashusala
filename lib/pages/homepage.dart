// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class homePage extends StatelessWidget {
  const homePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool switchValue = ModalRoute.of(context)?.settings.arguments as bool;
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
                      Spacer(),
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
