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
import 'package:veterinary_app/pages/doctorBookingRequests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

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
  bool isDoctorAvailable = false;

  TextEditingController label = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController town = TextEditingController();
  TextEditingController district = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pincode = TextEditingController();

  bool isHomeExpanded = false;

  void toggleUrgency(bool value) {
    setState(() {
      if (value) {
        context.read<HomepetsProvider>().startUrgentAvailabilityUpdates();
      } else {
        context.read<HomepetsProvider>().stopUrgentAvailabilityUpdates();
      }
      isDoctorAvailable = value;
    });
  }

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

    // Check if newLabel is a valid key in savedAddress
    if (!context.read<HomepetsProvider>().savedAddress.containsKey(newLabel)) {
      // Handle the case where newLabel is not a valid key
      print('Invalid address label: $newLabel');
    }

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
    setState(() {});
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
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(240, 232, 213, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 30),
                // Address Section
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(16, 42, 66, 1),
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
                      child: _buildAddressSection(),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Doctor's Urgent Availability Switch
                if (widget.db.switchValue) _buildUrgentAvailabilityToggle(),
                // User's Action Buttons
                if (!widget.db.switchValue)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                          "Nearby Doctors  📍",
                          () async {
                            var lat = context
                                .read<HomepetsProvider>()
                                .selectedLatitude!;
                            var long = context
                                .read<HomepetsProvider>()
                                .selectedLongitude!;
                            await context
                                .read<Cliniclocationprovider>()
                                .fetchNearbyClinics(lat, long);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mappage(
                                  userLatitude: lat,
                                  userLongitude: long,
                                  mapType: "nearbyClinics",
                                ),
                              ),
                            );
                          },
                        ),
                        _buildActionButton(
                          "Emergency service  🚨",
                          () async {
                            var lat = context
                                .read<HomepetsProvider>()
                                .selectedLatitude!;
                            var long = context
                                .read<HomepetsProvider>()
                                .selectedLongitude!;
                            context
                                .read<Cliniclocationprovider>()
                                .listenToUrgentDoctors(lat, long);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mappage(
                                  userLatitude: lat,
                                  userLongitude: long,
                                  mapType: "urgentDoctors",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 10),
                // Main Content Section
                Expanded(
                  child: widget.db.switchValue
                      ? _buildDoctorView()
                      : _buildUserView(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Row(
      children: [
        Container(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    )
                  : SizedBox(
                      width: 330,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => AddressBottomSheet.show(
                              context,
                              context.read<HomepetsProvider>().savedAddress,
                              changeIndexParameters,
                              widget.db.switchValue,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.red, size: 30),
                                      SizedBox(width: 10),
                                      Text(
                                        context
                                            .read<HomepetsProvider>()
                                            .selectedIndex,
                                        style: GoogleFonts.secularOne(
                                          fontSize: 22,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.arrow_drop_down_outlined,
                                          color: Colors.white, size: 38),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: 330,
                                  child: Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Text(
                                        selectedAddress!,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.secularOne(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
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
          onPressed: () => _showAddressInputSheet(),
          icon: Icon(
            Icons.edit,
            size: 28,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(16, 42, 66, 1),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.secularOne(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Booking Requests",
                style: GoogleFonts.secularOne(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(16, 42, 66, 1),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors_data')
                .doc(widget.currentUserId)
                .collection('pending_requests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = snapshot.data?.docs ?? [];

              if (requests.isEmpty) {
                return Center(
                  child: Text(
                    'No pending requests',
                    style: GoogleFonts.secularOne(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request =
                      requests[index].data() as Map<String, dynamic>;
                  final requestId = requests[index].id;
                  final typeOfRequest =
                      request['typeOfRequest'] ?? 'appointment';
                  final petName = request['petName'] ?? '';
                  final userName = request['userName'] ?? '';
                  final breed = request['breed'] ?? '';
                  final animalType = request['animalType'] ?? '';
                  final dateRaw = request['date'];
                  DateTime? date;
                  if (dateRaw is Timestamp) {
                    date = dateRaw.toDate();
                  } else if (dateRaw is DateTime) {
                    date = dateRaw;
                  }
                  final time = request['time'];
                  final address = request['address'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color.fromRGBO(240, 232, 213, 0.5),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              typeOfRequest == 'pet_verification'
                                  ? 'Pet Verification'
                                  : 'Appointment',
                              style: GoogleFonts.secularOne(
                                fontWeight: FontWeight.bold,
                                color: typeOfRequest == 'pet_verification'
                                    ? Colors.orange
                                    : Color(0xFF9CAF88),
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      getImagePath(animalType, breed),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        petName,
                                        style: GoogleFonts.secularOne(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF9CAF88),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Owner: $userName',
                                        style: GoogleFonts.secularOne(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (typeOfRequest == 'pet_verification' &&
                                          address != null)
                                        Text('Address: $address'),
                                      if (typeOfRequest == 'appointment' &&
                                          time != null)
                                        Text('Slot: $time'),
                                      if (date != null)
                                        Text(
                                            'Date: ${DateFormat('MMM dd, yyyy').format(date)}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _handleBookingRequest(
                                      requestId, 'rejected'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  child: Text(
                                    'Decline',
                                    style: GoogleFonts.secularOne(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => _handleBookingRequest(
                                      requestId, 'accepted',
                                      date: date, time: time),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9CAF88),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Accept',
                                    style: GoogleFonts.secularOne(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Pets",
                style: GoogleFonts.sahitya(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'add_pet') {
                    showDialog(
                      context: context,
                      builder: (context) => ShowPetInfoDialog(
                        currentUserId: widget.currentUserId,
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
        Expanded(
          child: Consumer<HomepetsProvider>(
            builder: (context, homePets, child) {
              return homePets.petList.isEmpty
                  ? CircularProgressIndicator()
                  : ListView.builder(
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
                          currentUserId: widget.currentUserId,
                          status: pet['status'] ?? "Unknown",
                          petId: pet['petId'] ?? "Unknown",
                        );
                      },
                    );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleBookingRequest(String requestId, String status,
      {DateTime? date, String? time}) async {
    try {
      // Get the request data first
      final requestDoc = await FirebaseFirestore.instance
          .collection('doctors_data')
          .doc(widget.currentUserId)
          .collection('pending_requests')
          .doc(requestId);

      final requestData = await requestDoc.get();
      if (!requestData.exists) {
        throw Exception('Request not found');
      }

      final request = requestData.data() as Map<String, dynamic>;

      if (status == 'accepted') {
        // Move to completed_requests
        await FirebaseFirestore.instance
            .collection('doctors_data')
            .doc(widget.currentUserId)
            .collection('completed_requests')
            .doc(requestId)
            .set({
          ...request,
          'status': 'accepted',
          'acceptedAt': DateTime.now(),
        });

        // If it's an appointment, update the time slot
        if (request['typeOfRequest'] == 'appointment' &&
            date != null &&
            time != null) {
          await FirebaseFirestore.instance
              .collection('doctors_data')
              .doc(widget.currentUserId)
              .collection('timeSlots')
              .doc(DateFormat('yyyy-MM-dd').format(date))
              .set({
            time: false,
          }, SetOptions(merge: true));
        }

        // Create chat room ID
        List<String> ids = [widget.currentUserId, request['userId']];
        ids.sort();
        String chatRoomId = ids.join('_');
        // Create the acceptance message
        final messageData = {
          'message': '''
Appointment Request ${status.toUpperCase()}
🕒 Date & Time: ${DateFormat('MMM dd, yyyy').format(date!)} at $time
🐾 Pet: ${request['petName']} (${request['animalType']}, ${request['breed']})
👤 Doctor: ${context.read<Database>().userName ?? 'Unknown Doctor'}
📋 Status: Accepted ✅
''',
          'receiverID': request['userId'],
          'senderEmail': context.read<Database>().userEmail,
          'senderID': widget.currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Add message to chat room
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .add(messageData);

        // Update chat room metadata
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(chatRoomId)
            .set({
          'participants': [request['userId'], widget.currentUserId],
          'lastMessage': messageData['message'],
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSender': widget.currentUserId,
        }, SetOptions(merge: true));

        // Delete from pending_requests
        await requestDoc.delete();
      } else if (status == 'rejected') {
        // Create chat room ID
        List<String> ids = [widget.currentUserId, request['userId']];
        ids.sort();
        String chatRoomId = ids.join('_');
        // Create the rejection message
        final messageData = {
          'message': '''
Appointment Request ${status.toUpperCase()}
🕒 Date & Time: ${DateFormat('MMM dd, yyyy').format((request['date'] as Timestamp).toDate())} at ${request['time']}
🐾 Pet: ${request['petName']} (${request['animalType']}, ${request['breed']})
👤 Doctor: ${context.read<Database>().userName ?? 'Unknown Doctor'}
📋 Status: Declined ❌
''',
          'receiverID': request['userId'],
          'senderEmail': context.read<Database>().userEmail,
          'senderID': widget.currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Add message to chat room
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .add(messageData);

        // Update chat room metadata
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(chatRoomId)
            .set({
          'participants': [request['userId'], widget.currentUserId],
          'lastMessage': messageData['message'],
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSender': widget.currentUserId,
        }, SetOptions(merge: true));

        // Delete from pending_requests
        await requestDoc.delete();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking request $status successfully'),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddressInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
              _buildTextField(label, 'Address Label'),
              _buildTextField(landmark, 'Landmark'),
              _buildTextField(town, 'Town'),
              _buildTextField(district, 'District'),
              _buildTextField(state, 'State'),
              _buildTextField(pincode, 'Pin Code', isNumber: true),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: submitAddress,
                child:
                    Text('Submit', style: GoogleFonts.secularOne(fontSize: 18)),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUrgentAvailabilityToggle() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(16, 42, 66, 1),
          borderRadius: BorderRadius.all(Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emergency,
                    color: isDoctorAvailable ? Colors.red : Colors.grey,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Urgent Availability',
                    style: GoogleFonts.secularOne(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDoctorAvailable
                      ? Colors.red.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                ),
                child: Switch(
                  value: isDoctorAvailable,
                  onChanged: toggleUrgency,
                  activeColor: Colors.red,
                  activeTrackColor: Colors.red.withOpacity(0.5),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
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
}

Future<void> setUrgentAvailability(
    bool isAvailable, String doctorId, Map<String, dynamic> data) async {
  final urgentDocRef = FirebaseFirestore.instance
      .collection('locations')
      .doc('urgentLocations')
      .collection('urgent_locations')
      .doc(doctorId);

  if (isAvailable) {
    await urgentDocRef.set({
      ...data,
      'createdAt': DateTime.now(),
    });
  } else {
    await urgentDocRef.delete();
  }
}
