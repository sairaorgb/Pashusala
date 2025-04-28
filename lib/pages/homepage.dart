// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, no_leading_underscores_for_local_identifiers, must_be_immutable

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/homePetsProvider.dart';
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
  // late double latitude;
  // late double longitude;
  double? homeLatitude;
  double? homeLongitude;
  // double? currLatitude;
  // double? currLongitude;

  String? homeAddress;
  bool isLoading = true;
  String? errorMessage;

  TextEditingController landmark = TextEditingController();
  TextEditingController town = TextEditingController();
  TextEditingController district = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pincode = TextEditingController();

  bool isHomeExpanded = false;

  void submitAddress() {
    widget.db.isAddressModified = true;
    setState(() {
      widget.db.currLandmark = landmark.text;
      widget.db.currTown = town.text;
      widget.db.currDistrict = district.text;
      widget.db.currPinCode = state.text;
      widget.db.currPinCode = pincode.text;
      widget.db.currAddress = "${landmark.text} ,"
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
    if (widget.db.tempBox.containsKey("homeAddress")) {
      homeAddress = widget.db.tempBox.get("homeAddress");
      homeLatitude = widget.db.tempBox.get("userLatitude");
      homeLongitude = widget.db.tempBox.get("userLongitude");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!widget.db.isAddressModified)
        await fetchLocation();
      else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0]; // Get the first result
      if (!(place.name!.isNotEmpty && place.name!.contains('+'))) {
        landmark.text = place.name!;
        widget.db.currLandmark = place.name;
      }
      if (!(place.locality!.isNotEmpty && place.locality!.contains('+'))) {
        town.text = place.locality!;
        widget.db.currTown = place.locality;
      }
      if (!(place.postalCode!.isNotEmpty && place.postalCode!.contains('+'))) {
        pincode.text = place.postalCode!;
        widget.db.currPinCode = place.postalCode;
      }
      if (!(place.administrativeArea!.isNotEmpty &&
          place.administrativeArea!.contains('+'))) {
        state.text = place.administrativeArea!;
        widget.db.currState = place.administrativeArea;
      }

      widget.db.currAddress = [
        widget.db.currLandmark,
        widget.db.currTown,
        widget.db.currDistrict,
        widget.db.currState,
        widget.db.currPinCode
      ]
          .where((element) => element != null && element.trim().isNotEmpty)
          .join(', ');

      setState(() {
        widget.db.currLatitude = position.latitude;
        widget.db.currLongitude = position.longitude;
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
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(16, 42, 66, 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: isLoading
                                    ? CircularProgressIndicator()
                                    : errorMessage != null
                                        ? Text(
                                            errorMessage!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16),
                                          )
                                        : SizedBox(
                                            width: 330,
                                            // height: 80,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.location_on,
                                                    color: Colors.blue,
                                                    size: 30),
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    widget.db.currAddress,
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.secularOne(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                              ],
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
                                          _buildTextField(landmark, 'Landmark'),
                                          _buildTextField(town, 'Town'),
                                          _buildTextField(district, 'District'),
                                          _buildTextField(state, 'State'),
                                          _buildTextField(pincode, 'Pin Code',
                                              isNumber: true),
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.brown,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: GestureDetector(
                                              onTap: () => submitAddress(),
                                              child: Text('Submit',
                                                  style: GoogleFonts.secularOne(
                                                      fontSize: 18)),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                icon: Icon(
                                  Icons.edit,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 0),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              shape: Border(),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Use Home Address',
                                    style: GoogleFonts.secularOne(
                                      color: Colors.white, // Title text color
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        isHomeExpanded
                                            ? Icons.arrow_drop_up
                                            : Icons
                                                .arrow_drop_down, // Toggle arrow
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Your button action here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical:
                                                  0), // Even smaller button

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // Rounded button
                                          ),
                                        ),
                                        child: Text(
                                          (widget.db.usingHomeAddress)
                                              ? 'using'
                                              : 'use',
                                          style: TextStyle(
                                            fontSize: 18, // Smaller font size
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onExpansionChanged: (bool expanding) {
                                setState(() {
                                  isHomeExpanded =
                                      expanding; // Update expansion state
                                });
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(
                                    textAlign: TextAlign.start,
                                    homeAddress ??
                                        "Home Address is not added yet",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 0),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              shape: Border(),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Use Current Address',
                                    style: GoogleFonts.secularOne(
                                      color: Colors.white, // Title text color
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        isHomeExpanded
                                            ? Icons.arrow_drop_up
                                            : Icons
                                                .arrow_drop_down, // Toggle arrow
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Your button action here
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical:
                                                  0), // Even smaller button

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // Rounded button
                                          ),
                                        ),
                                        child: Text(
                                          widget.db.usingHomeAddress
                                              ? 'use'
                                              : 'using',
                                          style: GoogleFonts.secularOne(
                                            fontSize: 16, // Smaller font size
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onExpansionChanged: (bool expanding) {
                                setState(() {
                                  isHomeExpanded =
                                      expanding; // Update expansion state
                                });
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.db.currAddress,
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 50,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          widget.db.setUserLocation(
                                              widget.db.currLandmark,
                                              widget.db.currTown,
                                              widget.db.currDistrict,
                                              widget.db.currState,
                                              widget.db.currPinCode,
                                              widget.db.currLatitude,
                                              widget.db.currLongitude);
                                          homeAddress = [
                                            widget.db.currLandmark,
                                            widget.db.currTown,
                                            widget.db.currDistrict,
                                            widget.db.currPinCode,
                                            widget.db.currState,
                                          ]
                                              .where((element) =>
                                                  element != null &&
                                                  element.trim().isNotEmpty)
                                              .join(', ');
                                          setState(() {
                                            homeLatitude =
                                                widget.db.currLatitude;
                                            homeLongitude =
                                                widget.db.currLongitude;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 2,
                                              vertical:
                                                  0), // Even smaller button

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // Rounded button
                                          ),
                                        ),
                                        child: Text(
                                          'Set as Home',
                                          style: TextStyle(
                                            fontSize: 13, // Smaller font size
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                            showDialog(
                              context: context,
                              builder: (context) => ShowPetInfoDialog(
                                currentUserId: _currentUserId,
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
                Consumer<HomepetsProvider>(builder: (context, homePets, child) {
                  return homePets.petList.isEmpty
                      ? CircularProgressIndicator()
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: homePets.petList.length,
                            itemBuilder: (context, index) {
                              final pet = homePets.petList[index];
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
                        );
                }),
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
