// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veterinary_app/pages/mapPage.dart';
import 'package:veterinary_app/utils/addPetDialogue.dart';
import 'package:veterinary_app/utils/homePetTile.dart';

class homePage extends StatefulWidget {
  String switchValue;
  String currentUserId;
  homePage({super.key, required this.switchValue, required this.currentUserId});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  List<Map<String, dynamic>> petList = [];
  String? _currentUserId;
  bool _switchValue = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPets(widget.currentUserId);
      fetchLocation();
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
          'name': data['name'] ?? 'Unknown',
          'animalType': data['animalType'] ?? 'Unknown',
          'breed': data['breed'] ?? 'UnKnown',
          'age': data['age'] ?? 0,
          'height': data['height'] ?? 0.0,
          'weight': data['weight'] ?? 0.0,
          'petId': doc.id,
          'status': data['status']
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
    if (widget.switchValue == "true") {
      _switchValue = true;
    }

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
                                                  builder: (context) => Mappage(
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
                                                  style: GoogleFonts.secularOne(
                                                      fontSize: 18,
                                                      color: Colors.white),
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.brown,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: GestureDetector(
                                                  onTap: () => submitAddress(),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
              // builder: (context) {
              // if (snapshot.connectionState ==
              //     ConnectionState.waiting) {
              //   return CircularProgressIndicator();
              // } else if (snapshot.hasError) {
              //   return Text(
              //     "Error: ${snapshot.error}",
              //     style: TextStyle(color: Colors.white),
              //   );
              // } else {
              //   return Row(
              //     children: [
              //       Icon(
              //         Icons.location_on,
              //         color: Colors.white,
              //         size: 28,
              //       ),
              //       Text(
              //         "${snapshot.data!.latitude}, ${snapshot.data!.longitude}",
              //         style: TextStyle(
              //             fontSize: 18, color: Colors.white),
              //       ),
              // IconButton(
              //     onPressed: () => Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => Mappage(
              //             lati: latitude,
              //             longi: longitude,
              //           ),
              //         )),
              //     icon: Icon(
              //       Icons.add,
              //       color: Colors.white,
              //       size: 20,
              //     ))

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
                              onPetAdded: () => fetchPets(_currentUserId),
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: petList.length,
                  itemBuilder: (context, index) {
                    final pet = petList[index];
                    return homePageTile(
                      name: pet['name'],
                      animalType: pet['animalType'],
                      age: pet['age'],
                      height: pet['height'],
                      weight: pet['weight'],
                      breed: pet['breed'],
                      currentUserId: _currentUserId,
                      status: pet['status'],
                      petId: pet['petId'],
                    );
                  },
                ),
              ),
            ],
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
