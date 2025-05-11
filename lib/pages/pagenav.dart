// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, sort_child_properties_last, must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/cartStoreProvider.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/homePetsProvider.dart';
import 'package:veterinary_app/main.dart';
import 'package:veterinary_app/pages/cartPage.dart';
import 'package:veterinary_app/pages/chatPage.dart';
import 'package:veterinary_app/pages/homepage.dart';
import 'package:veterinary_app/pages/loginPage.dart';
import 'package:veterinary_app/pages/storePage.dart';
import 'package:veterinary_app/utils/chatText.dart';

class PageNav extends StatefulWidget {
  int CurrentPageIndex;
  String CurrentUserId;
  bool SwitchValue;
  PageNav(
      {super.key,
      required this.CurrentPageIndex,
      required this.CurrentUserId,
      required this.SwitchValue});

  @override
  State<PageNav> createState() => _PageNavState();
}

class _PageNavState extends State<PageNav> {
  late int currentPageIndex;
  late bool switchValue;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    Future(() async {
      context.read<HomepetsProvider>().isDoctor = widget.SwitchValue;
      await context.read<HomepetsProvider>().initDatabase();
    });
    Future.microtask(() async {
      context.read<CartStoreProvider>().initCSP();
    });
    currentPageIndex = widget.CurrentPageIndex;
    currentUserId = widget.CurrentUserId;
    switchValue = widget.SwitchValue;
  }

  void logout(BuildContext context, Database DB) async {
    var authinstance = FirebaseAuth.instance;
    try {
      await DB.logOutUser();
      Provider.of<HomepetsProvider>(context, listen: false).logout();
      Provider.of<CartStoreProvider>(context, listen: false).logout();
      await authinstance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => myApp()),
        (Route<dynamic> route) => false,
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

  void onTabchange(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<Database>(context);

    List<Widget> pages = (db.switchValue)
        ? [
            HomePage(
              db: db,
              switchValue: switchValue.toString(),
              currentUserId: currentUserId,
            ),
            chatModule(
              currentUserId: currentUserId,
              switchValue: switchValue.toString(),
            )
          ]
        : [
            StorePage(
              currentUserId: currentUserId,
              switchValue: switchValue.toString(),
            ),
            HomePage(
              db: db,
              switchValue: switchValue.toString(),
              currentUserId: currentUserId,
            ),
            CartPage(
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
      backgroundColor: switchValue
          ? Color.fromRGBO(
              232, 245, 233, 1) // Light sage green for doctor's background
          : Color.fromRGBO(2, 16, 36, 1), // Dark blue for user's background
      appBar: AppBar(
        backgroundColor: switchValue
            ? Color.fromRGBO(44, 78, 46, 1) // Forest green for doctor's app bar
            : Color.fromRGBO(16, 42, 66, 1), // Dark blue for user's app bar
        toolbarHeight: 130,
        title: Row(
          children: [
            SizedBox(width: 40),
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
        backgroundColor: switchValue
            ? Color.fromRGBO(
                232, 245, 233, 1) // Light sage green for doctor's drawer
            : Color.fromRGBO(240, 232, 213, 1), // Khaki for user's drawer
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: switchValue
                        ? Color.fromRGBO(
                            46, 125, 50, 1) // Forest green for doctor's header
                        : Color.fromRGBO(
                            16, 42, 66, 1), // Dark blue for user's header
                  ),
                  child: Center(child: Image.asset('assets/images/logo.png')),
                ),
                if (!db.switchValue) ...[
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
                            builder: (context) => PageNav(
                              CurrentPageIndex: 1,
                              CurrentUserId: currentUserId,
                              SwitchValue: switchValue,
                            ),
                          ),
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
                            builder: (context) => PageNav(
                              CurrentPageIndex: 0,
                              CurrentUserId: currentUserId,
                              SwitchValue: switchValue,
                            ),
                          ),
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
                            builder: (context) => PageNav(
                              CurrentPageIndex: 2,
                              CurrentUserId: currentUserId,
                              SwitchValue: switchValue,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: ChatText(
                      text: 'Chat',
                      size: 18,
                      fontWeight: FontWeight.w500,
                      color: switchValue
                          ? Color.fromRGBO(
                              46, 125, 50, 1) // Forest green for doctor's text
                          : Color.fromRGBO(
                              16, 42, 66, 1), // Dark blue for user's text
                    ),
                    leading: Icon(
                      Icons.forum,
                      color: switchValue
                          ? Color.fromRGBO(
                              46, 125, 50, 1) // Forest green for doctor's icon
                          : Color.fromRGBO(
                              16, 42, 66, 1), // Dark blue for user's icon
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageNav(
                            CurrentPageIndex: db.switchValue ? 1 : 3,
                            CurrentUserId: currentUserId,
                            SwitchValue: switchValue,
                          ),
                        ),
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
                  color: switchValue
                      ? Color.fromRGBO(
                          23, 70, 26, 1) // Forest green for doctor's text
                      : Color.fromRGBO(
                          16, 42, 66, 1), // Dark blue for user's text
                ),
                leading: Icon(
                  Icons.logout,
                  color: switchValue
                      ? Color.fromRGBO(
                          26, 80, 29, 1) // Forest green for doctor's icon
                      : Color.fromRGBO(
                          16, 42, 66, 1), // Dark blue for user's icon
                ),
                onTap: () => logout(context, db),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: pages[currentPageIndex]),
      bottomNavigationBar: GNav(
        backgroundColor: switchValue
            ? Color.fromRGBO(
                232, 245, 233, 1) // Light sage green for doctor's nav bar
            : Color.fromRGBO(240, 232, 213, 1), // Khaki for user's nav bar
        activeColor: switchValue
            ? Color.fromRGBO(
                47, 93, 49, 1) // Forest green for doctor's active items
            : Color.fromRGBO(
                16, 42, 66, 1), // Dark blue for user's active items
        mainAxisAlignment: MainAxisAlignment.center,
        color: Colors.grey.shade600, // Grey for inactive items
        tabBorderRadius: 16,
        onTabChange: (index) => onTabchange(index),
        selectedIndex: currentPageIndex,
        tabs: db.switchValue
            ? [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.forum,
                  text: 'Chat',
                ),
              ]
            : [
                GButton(
                  icon: Icons.shopping_cart,
                  text: 'Store',
                ),
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.favorite,
                  text: 'Wish List',
                ),
                GButton(
                  icon: Icons.forum,
                  text: 'Chat',
                ),
              ],
      ),
    );
  }
}
