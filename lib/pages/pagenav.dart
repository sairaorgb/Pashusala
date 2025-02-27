// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, sort_child_properties_last

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:veterinary_app/pages/cartPage.dart';
import 'package:veterinary_app/pages/chatPage.dart';
import 'package:veterinary_app/pages/homepage.dart';
import 'package:veterinary_app/pages/storePage.dart';
import 'package:veterinary_app/utils/chatText.dart';

class pageNav extends StatefulWidget {
  int CurrentPageIndex;
  String CurrentUserId;
  bool SwitchValue;
  pageNav(
      {super.key,
      required this.CurrentPageIndex,
      required this.CurrentUserId,
      required this.SwitchValue});

  @override
  State<pageNav> createState() => _pageNavState();
}

class _pageNavState extends State<pageNav> {
  late int currentPageIndex;
  late bool switchValue;
  late String currentUserId;

  void logout(BuildContext context) async {
    var authinstance = FirebaseAuth.instance;

    try {
      await authinstance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/loginpage', // Replace with your desired route name
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPageIndex = widget.CurrentPageIndex;
    currentUserId = widget.CurrentUserId;
    switchValue = widget.SwitchValue;
  }

  void onTabchange(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments != null) {
      Map<String, String> args =
          ModalRoute.of(context)?.settings.arguments as Map<String, String>;
      currentUserId = args['userId']!;

      if (args['switchValue'] == "true") {
        switchValue = true;
      }
    }
    List<Widget> pages = [
      storePage(
        currentUserId: currentUserId,
        switchValue: switchValue.toString(),
      ),
      homePage(
          switchValue: switchValue.toString(), currentUserId: currentUserId),
      cartPage(
        UserId: currentUserId,
        switchValue: switchValue.toString(),
      ),
      chatModule(
        currentUserId: currentUserId,
        switchValue: switchValue.toString(),
      )
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
          switchValue ? Colors.green[300] : Color.fromRGBO(2, 16, 36, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(16, 42, 66, 1),
        toolbarHeight: 130,
        title: Row(
          children: [
            SizedBox(
              width: 40,
            ),
            SizedBox(
              child: Text(
                "Pashushala",
                style: GoogleFonts.sansita(
                  fontSize: 42,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              size: 26,
              color: Colors.white,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  child: Center(child: Image.asset('assets/images/logo.png')),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: ChatText(
                      text: 'Home',
                      size: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    leading: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => pageNav(
                                  CurrentPageIndex: 1,
                                  CurrentUserId: currentUserId,
                                  SwitchValue: switchValue,
                                )),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: ChatText(
                      text: 'Store Page',
                      size: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    leading: Icon(
                      Icons.shopping_cart,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => pageNav(
                                  CurrentPageIndex: 0,
                                  CurrentUserId: currentUserId,
                                  SwitchValue: switchValue,
                                )),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: ChatText(
                      text: 'Wish List',
                      size: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    leading: Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => pageNav(
                                CurrentPageIndex: 2,
                                CurrentUserId: currentUserId,
                                SwitchValue: switchValue)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: ChatText(
                      text: 'Chat',
                      size: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    leading: Icon(
                      Icons.forum,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => pageNav(
                                CurrentPageIndex: 3,
                                CurrentUserId: currentUserId,
                                SwitchValue: switchValue)),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
              child: ListTile(
                title: ChatText(
                  text: 'logout',
                  size: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade300,
                  // color: Theme.of(context).colorScheme.tertiary,
                ),
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onTap: () => logout(context),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: pages[currentPageIndex]),
      bottomNavigationBar: GNav(
          backgroundColor: Color.fromRGBO(240, 232, 213, 1),
          activeColor: Color.fromRGBO(41, 52, 72, 1),
          mainAxisAlignment: MainAxisAlignment.center,
          color: Colors.grey.shade500,
          tabBorderRadius: 16,
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
            ),
            GButton(
              icon: Icons.chat,
              text: "Chat",
            )
          ]),
    );
  }
}
