// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, no_leading_underscores_for_local_identifiers, must_be_immutable

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/pages/mapPage.dart';
import 'package:veterinary_app/utils/addPetDialogue.dart';
import 'package:veterinary_app/utils/homePetTile.dart';

class HomePage extends StatefulWidget {
  String switchValue;
  String currentUserId;
  Database db;
  HomePage(
      {super.key,
      required this.switchValue,
      required this.currentUserId,
      required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> petList = [];
  late double latitude;
  late double longitude;
  bool isLoading = true;
  String? errorMessage;

  TextEditingController landmark = TextEditingController();
  TextEditingController town = TextEditingController();
  TextEditingController district = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pincode = TextEditingController();

  String? addressDetails;

  void submitAddress() {
    setState(() {
      addressDetails = "${landmark.text} ,"
          "${town.text} ,"
          "${district.text} ,"
          "${state.text} ,"
          "${pincode.text}";
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    widget.db.addListener(onDbChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      petList = widget.db.petList;
      fetchLocation();
    });
  }

  void onDbChanged() {
    setState(() {
      petList = widget.db.petList;
    });
  }

  Future<void> fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String _currentUserId = widget.currentUserId;
    if (widget.switchValue == "true") {}

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            // height: 700,
            decoration: BoxDecoration(
              color: Color.fromRGBO(240, 232, 213, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(16, 42, 66, 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => (),
                                child: Container(
                                  child: isLoading
                                      ? CircularProgressIndicator()
                                      : errorMessage != null
                                          ? Text(
                                              errorMessage!,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16),
                                            )
                                          : GestureDetector(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Mappage(
                                                            lati: latitude,
                                                            longi: longitude),
                                                  )),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.location_on,
                                                      color: Colors.blue,
                                                      size: 28),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    "$latitude, $longitude",
                                                    style:
                                                        GoogleFonts.secularOne(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .keyboard_double_arrow_down_outlined,
                                                    size: 22,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              ),
                                            ),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                  onPressed: () => showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20.0)),
                                        ),
                                        builder: (context) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                              left: 16,
                                              right: 16,
                                              top: 20,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Enter Address',
                                                  style: GoogleFonts.secularOne(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                _buildTextField(
                                                    landmark, 'Landmark'),
                                                _buildTextField(town, 'Town'),
                                                _buildTextField(
                                                    district, 'District'),
                                                _buildTextField(state, 'State'),
                                                _buildTextField(
                                                    pincode, 'Pin Code',
                                                    isNumber: true),
                                                SizedBox(height: 20),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.brown,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: GestureDetector(
                                                    onTap: () =>
                                                        submitAddress(),
                                                    child: Text('Submit',
                                                        style: GoogleFonts
                                                            .secularOne(
                                                                fontSize: 18)),
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                  icon: addressDetails != null
                                      ? Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 24,
                                        )
                                      : Icon(
                                          Icons.add_box_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ))
                            ],
                          ),
                          addressDetails != null
                              ? Text(
                                  addressDetails!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.secularOne(
                                      fontSize: 16, color: Colors.white),
                                )
                              : Text('No Address Entered',
                                  style: GoogleFonts.secularOne(
                                      fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(16, 42, 66, 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              "Nearby Doctors  📍",
                              style: GoogleFonts.secularOne(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(16, 42, 66, 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              "Emergency service  🚨",
                              style: GoogleFonts.secularOne(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // "My Pets" text on the left
                      Text(
                        "My Pets",
                        style: GoogleFonts.sahitya(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Three dots (more_vert icon) on the right
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'add_pet') {
                            // Show the dialog when "Add New Pet" is selected
                            showDialog(
                              context: context,
                              builder: (context) => ShowPetInfoDialog(
                                currentUserId: _currentUserId,
                                onPetAdded: () => widget.db.petList,
                                db: widget.db,
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'add_pet',
                            child: Text("Add New Pet"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                petList.isEmpty
                    ? CircularProgressIndicator()
                    : Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: petList.length,
                          itemBuilder: (context, index) {
                            final pet = petList[index];
                            return homePageTile(
                              name: pet['name'] ?? "Unknown",
                              animalType: pet['animalType'] ?? "Unknown",
                              age: pet['age'] ?? "Unknown",
                              height: pet['height'] ?? "Unknown",
                              weight: pet['weight'] ?? "Unknown",
                              breed: pet['breed'] ?? "Unknown",
                              currentUserId: _currentUserId,
                              status: pet['status'] ?? "Unknown",
                              petId: pet['petId'] ?? "Unknown",
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildTextField(TextEditingController mycontroller, String label,
    {bool isNumber = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: mycontroller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.secularOne(fontSize: 16),
        filled: true,
        fillColor: Color.fromRGBO(240, 232, 213, 1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    ),
  );
}
