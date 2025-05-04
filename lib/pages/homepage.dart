// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, no_leading_underscores_for_local_identifiers, must_be_immutable

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/clinicLocationProvider.dart';
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
  String? selectedAddress;

  bool isLoading = true;
  String? errorMessage;

  TextEditingController label = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController town = TextEditingController();
  TextEditingController district = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pincode = TextEditingController();

  bool isHomeExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.read<HomepetsProvider>().isAddressModified) {
        await fetchLocation();
        if (!widget.db.switchValue) {
          await changeIndexParameters('Current');
        } else {
          await changeIndexParameters(
              context.read<HomepetsProvider>().selectedIndex);
        }
      } else {
        setState(() {
          changeIndexParameters(context.read<HomepetsProvider>().selectedIndex);
          isLoading = false;
        });
      }
    });
  }

  Future<void> submitAddress() async {
    context.read<HomepetsProvider>().isAddressModified = true;
    await context.read<HomepetsProvider>().saveAddressToFirestore(
        label: label.text,
        landmark: landmark.text,
        town: town.text,
        district: district.text,
        state: state.text,
        pincode: pincode.text,
        latitude: context.read<HomepetsProvider>().selectedLatitude!,
        longitude: context.read<HomepetsProvider>().selectedLongitude!);

    context.read<HomepetsProvider>().selectedIndex = label.text;
    changeIndexParameters(label.text);
    setState(() {
      selectedAddress =
          context.read<HomepetsProvider>().savedAddress[label.text]!['address'];
    });
    Navigator.pop(context);
  }

  // modifies controllers ,selected variables and triggers cloud change
  Future<void> changeIndexParameters(String newLabel) async {
    context.read<HomepetsProvider>().isAddressModified = true;
    label.text = newLabel;
    context.read<HomepetsProvider>().tempBox.put("selectedIndex", newLabel);
    context.read<HomepetsProvider>().selectedIndex = newLabel;
    landmark.text =
        context.read<HomepetsProvider>().savedAddress[newLabel]!['landmark'] ??
            '';
    town.text =
        context.read<HomepetsProvider>().savedAddress[newLabel]!['town'] ?? '';
    district.text =
        context.read<HomepetsProvider>().savedAddress[newLabel]!['district'] ??
            '';
    pincode.text =
        context.read<HomepetsProvider>().savedAddress[newLabel]!['pincode'] ??
            '';
    state.text =
        context.read<HomepetsProvider>().savedAddress[newLabel]!['state'] ?? '';
    context.read<HomepetsProvider>().selectedLatitude =
        context.read<HomepetsProvider>().savedAddress[newLabel]!['latitude']!;
    context.read<HomepetsProvider>().selectedLongitude =
        context.read<HomepetsProvider>().savedAddress[newLabel]!['longitude']!;
    selectedAddress =
        context.read<HomepetsProvider>().savedAddress[newLabel]!['address']!;

    await context.read<HomepetsProvider>().setUsedAddress();
  }

  Future<void> fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      context.read<HomepetsProvider>().selectedLatitude = position.latitude;
      context.read<HomepetsProvider>().selectedLongitude = position.longitude;

      List addList = [];
      String concatAddress = "";
      String currentLandmark = "";
      String currentTown = "";
      String currentDistrict = "";
      String currentPincode = "";
      String currentState = "";

      Placemark place = placemarks[0]; // Get the first result
      if (!(place.name!.isNotEmpty && place.name!.contains('+'))) {
        currentLandmark = place.name!;
        addList.add(place.name);
      }
      if (!(place.locality!.isNotEmpty && place.locality!.contains('+'))) {
        currentTown = place.locality!;
        addList.add(place.locality);
      }
      if (!(place.postalCode!.isNotEmpty && place.postalCode!.contains('+'))) {
        currentPincode = place.postalCode!;
        addList.add(place.postalCode);
      }
      if (!(place.administrativeArea!.isNotEmpty &&
          place.administrativeArea!.contains('+'))) {
        currentState = place.administrativeArea!;
        addList.add(place.administrativeArea);
      }

      concatAddress = addList
          .where((element) => element != null && element.trim().isNotEmpty)
          .join(', ');

      // context.read<HomepetsProvider>().currentAddress = concatAddress;

      await context.read<HomepetsProvider>().saveAddressToFirestore(
            label: "Current",
            landmark: currentLandmark,
            district: currentDistrict,
            town: currentTown,
            state: currentState,
            pincode: currentPincode,
            latitude: context.read<HomepetsProvider>().selectedLatitude!,
            longitude: context.read<HomepetsProvider>().selectedLongitude!,
          );

      setState(() {
        isLoading = false;
        selectedAddress = concatAddress;
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
                          horizontal: 8.0, vertical: 10),
                      child: Column(
                        children: [
                          Row(
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      AddressBottomSheet.show(
                                                          context,
                                                          context
                                                              .read<
                                                                  HomepetsProvider>()
                                                              .savedAddress,
                                                          changeIndexParameters,
                                                          widget
                                                              .db.switchValue),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    6.0),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .location_on,
                                                                color:
                                                                    Colors.red,
                                                                size: 30),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              context
                                                                  .read<
                                                                      HomepetsProvider>()
                                                                  .selectedIndex,
                                                              style: GoogleFonts
                                                                  .secularOne(
                                                                      fontSize:
                                                                          22,
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                            SizedBox(
                                                              width: 6,
                                                            ),
                                                            Icon(
                                                                Icons
                                                                    .arrow_drop_down_outlined,
                                                                color: Colors
                                                                    .white,
                                                                size: 38),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      SizedBox(
                                                        width: 330,
                                                        child: Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15.0),
                                                            child: Text(
                                                              selectedAddress!,
                                                              softWrap: true,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .secularOne(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                          _buildTextField(
                                              label, 'Address Label'),
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
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                if (!widget.db.switchValue)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            var lat = context
                                .read<HomepetsProvider>()
                                .selectedLatitude!;
                            var long = context
                                .read<HomepetsProvider>()
                                .selectedLongitude!;
                            print(lat);
                            print(long);
                            await context
                                .read<Cliniclocationprovider>()
                                .fetchNearbyClinics(lat, long);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Mappage(
                                      userLatitude: lat, userLongitude: long),
                                ));
                          },
                          child: Container(
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
                if (!widget.db.switchValue)
                  Column(
                    children: [
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
                    ],
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

class AddressBottomSheet {
  static void show(
      BuildContext context,
      Map<String, Map<String, dynamic>> savedAddresses,
      void Function(String) ontap,
      bool isDoctor) {
    savedAddresses = savedAddresses;
    // ..addAll(context.read<HomepetsProvider>().currentMap!);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            var indexToMark = context.read<HomepetsProvider>().selectedIndex;
            return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3EB), // Light background
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child:
                    StatefulBuilder(builder: (context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: savedAddresses.length,
                          itemBuilder: (context, index) {
                            final label = savedAddresses.keys.elementAt(index);
                            String addressString =
                                savedAddresses[label]!['address']!;
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xFFF1E8D9), // Slightly darker cream
                                border: (label == indexToMark)
                                    ? Border.all(
                                        color: Colors.brown,
                                        width: 2,
                                        style: BorderStyle.solid)
                                    : Border.all(width: 0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                title: Text(
                                  label,
                                  style: GoogleFonts.secularOne(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    addressString,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    indexToMark = label;
                                  });
                                  // ontap(label);
                                  // Navigator.pop(context, label);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          ontap(indexToMark);
                          Navigator.pop(context);
                        },
                        child: Text(
                            (isDoctor)
                                ? 'Set this as Clinic'
                                : 'Use this Address',
                            style: GoogleFonts.secularOne(fontSize: 18)),
                      ),
                    ],
                  );
                }));
          },
        );
      },
    );
  }

  static String _buildAddressString(Map<String, String?> fields) {
    List<String> parts = [];
    if (fields['Landmark'] != null && fields['Landmark']!.isNotEmpty) {
      parts.add(fields['Landmark']!);
    }
    if (fields['Town'] != null && fields['Town']!.isNotEmpty) {
      parts.add(fields['Town']!);
    }
    if (fields['District'] != null && fields['District']!.isNotEmpty) {
      parts.add(fields['District']!);
    }
    if (fields['State'] != null && fields['State']!.isNotEmpty) {
      parts.add(fields['State']!);
    }
    if (fields['Pin Code'] != null && fields['Pin Code']!.isNotEmpty) {
      parts.add(fields['Pin Code']!);
    }
    return parts.join(", ");
  }
}
