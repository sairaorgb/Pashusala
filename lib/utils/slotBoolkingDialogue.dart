import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/services/timeSlotsService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingDialog extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String doctorName;
  final String doctorId;

  const BookingDialog(
      {super.key,
      required this.items,
      required this.doctorName,
      required this.doctorId});

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  final List<DateTime> next7Days =
      List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  Map<String, bool> timeSlots = {};
  final TimeSlotsService _timeSlotsService = TimeSlotsService();

  Map<String, dynamic>? selectedPet;
  void onPetSelected(Map<String, dynamic> pet) {
    selectedPet = pet;
  }

  Color sage = const Color(0xFFB2BFA6);

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    // Load all time slots for next 7 days at once
    final allTimeSlots =
        await _timeSlotsService.getTimeSlotsForNext7Days(widget.doctorId);
    final dateString = _formatDate(selectedDate);
    setState(() {
      timeSlots = allTimeSlots[dateString] ?? {};
    });
  }

  void _updateSelectedDate(DateTime date) {
    final dateString = _formatDate(date);
    setState(() {
      selectedDate = date;
      timeSlots = _timeSlotsService.getTimeSlotsForDate(dateString) ?? {};
      selectedTime = null; // Reset selected time when date changes
    });
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timeSlotsService.clearCache();
    super.dispose();
  }

  void _confirmBooking() async {
    if (selectedPet == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final userEmail = user.email ?? 'system';

      final bookingData = {
        'petId': selectedPet!['petId'],
        'petName': selectedPet!['name'],
        'date': selectedDate,
        'time': selectedTime,
        'userId': user.uid,
        'userName': context.read<Database>().userName ?? 'Unknown User',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'animalType': selectedPet!["animalType"] ?? "Unknown",
        'breed': selectedPet!["breed"] ?? "Unknown",
        'typeOfRequest': 'appointment',
      };

      // Add to pending_requests
      await FirebaseFirestore.instance
          .collection('doctors_data')
          .doc(widget.doctorId)
          .collection('pending_requests')
          .add(bookingData);

      // Create chat room ID (combination of user and doctor IDs)
      List<String> ids = [user.uid, widget.doctorId];
      ids.sort();
      String chatRoomId = ids.join('_');

      // Create the message for the chat
      final messageData = {
        'message': '''
New Appointment Request
🕒 Date & Time: ${DateFormat('MMM dd, yyyy').format(selectedDate)} at $selectedTime
🐾 Pet: ${selectedPet!['name']} (${selectedPet!['animalType']}, ${selectedPet!['breed']})
👤 From: ${context.read<Database>().userName ?? 'Unknown User'}
📋 Status: Pending
''',
        'receiverID': widget.doctorId,
        'senderEmail': userEmail,
        'senderID': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add message to chat room
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);

      // Create or update chat room metadata
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .set({
        'participants': [user.uid, widget.doctorId],
        'lastMessage': messageData['message'],
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': widget.doctorId,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF4F7F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: Container(
        height: 460,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Text(
                    "Dr. " + widget.doctorName,
                    style: GoogleFonts.secularOne(
                        fontSize: 24,
                        color: const Color.fromARGB(255, 25, 52, 26)),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            DropdownButton<Map<String, dynamic>>(
              value: selectedPet,
              hint: const Text("Select a Pet of yours"),
              isExpanded: true,
              items: widget.items.map((item) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Text(
                    item["name"] ?? "Unnamed",
                    style: GoogleFonts.secularOne(fontSize: 19),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedPet = value);
                if (value != null) {
                  onPetSelected(value);
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 80,
              width: double.maxFinite,
              child: Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: next7Days.length,
                  itemBuilder: (context, index) {
                    final date = next7Days[index];
                    final isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;

                    return GestureDetector(
                      onTap: () => _updateSelectedDate(date),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? sage : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: sage),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E().format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : sage,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat.d().format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : sage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.entries.map((entry) {
                final time = entry.key;
                final isAvailable = entry.value;
                final isSelected = time == selectedTime;

                return GestureDetector(
                  onTap: isAvailable
                      ? () => setState(() => selectedTime = time)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? (isSelected ? sage : Colors.white)
                          : Colors.grey.shade300,
                      border: Border.all(
                        color: isAvailable ? sage : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isAvailable
                            ? (isSelected ? Colors.white : sage)
                            : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // Confirm Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sage,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              onPressed: selectedTime == null ? null : _confirmBooking,
              child: const Text(
                "Confirm Booking",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
