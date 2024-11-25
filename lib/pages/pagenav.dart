// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:veterinary_app/pages/cartPage.dart';
import 'package:veterinary_app/pages/homepage.dart';
import 'package:veterinary_app/pages/storePage.dart';

class pageNav extends StatefulWidget {
  const pageNav({super.key});

  @override
  State<pageNav> createState() => _pageNavState();
}

class _pageNavState extends State<pageNav> {
  int currentPageIndex = 1;
  bool switchValue = false;

  void onTabchange(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    String? currentUserId = args?['userId'];

    if (args?['switchValue'] == "true") {
      switchValue = true;
    }
    List<Widget> pages = [
      storePage(
        currentUserId: currentUserId!,
      ),
      homePage(
          switchValue: switchValue.toString(), currentUserId: currentUserId!),
      cartPage(
        UserId: currentUserId,
      )
    ];

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
                "Pashushala",
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
      body: pages[currentPageIndex],
      bottomNavigationBar: GNav(
          backgroundColor:
              (currentPageIndex != 1) ? Colors.blue.shade300 : Colors.white,
          activeColor: Colors.black,
          mainAxisAlignment: MainAxisAlignment.center,
          color: Colors.grey.shade500,
          tabBorderRadius: 16,
          // tabBackgroundColor: Colors.grey.shade200,
          onTabChange: (index) => onTabchange(index),
          selectedIndex: currentPageIndex,
          tabs: [
            GButton(
              icon: Icons.shopping_cart,
              text: "Shop",
            ),
            GButton(
              icon: Icons.home,
              text: "Home",
            ),
            GButton(
              icon: Icons.favorite,
              text: "Wishlist",
            )
          ]),
    );
  }
}
