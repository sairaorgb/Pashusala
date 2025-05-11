import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class DoctorBookingRequests extends StatelessWidget {
  final String doctorId;

  const DoctorBookingRequests({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  Future<void> _handleBookingRequest(
      BuildContext context, String requestId, String status,
      {DateTime? date, String? time}) async {
    try {
      // Get the request data first
      final requestDoc = await FirebaseFirestore.instance
          .collection('doctors_data')
          .doc(doctorId)
          .collection('pending_requests')
          .doc(requestId);

      final requestData = await requestDoc.get();
      if (!requestData.exists) {
        throw Exception('Request not found');
      }

      final request = requestData.data() as Map<String, dynamic>;
      final typeOfRequest = request['typeOfRequest'] ?? 'appointment';

      // Prepare chat room ID
      List<String> ids = [request['userId'], doctorId];
      ids.sort();
      String chatRoomId = ids.join('_');

      final doctorEmail = context.read<Database>().userEmail;

      // Format the timestamp as a string
      final now = DateTime.now();
      final formattedTimestamp =
          DateFormat("d MMMM y 'at' HH:mm:ss 'UTC'Z").format(now);

      // Prepare the message text
      final messageText = typeOfRequest == 'pet_verification'
          ? '''
Pet Verification Request ${status.toUpperCase()}
🕒 Date: ${DateFormat('MMM dd, yyyy').format((request['date'] as Timestamp).toDate())}
🐾 Pet: ${request['petName']} (${request['animalType']}, ${request['breed']})
📍 Address: ${request['address']}
👤 Doctor: ${context.read<Database>().userName ?? 'Unknown Doctor'}
📋 Status: ${status == 'accepted' ? 'Accepted ✅' : 'Declined ❌'}
'''
          : '''
Appointment Request ${status.toUpperCase()}
🕒 Date & Time: ${DateFormat('MMM dd, yyyy').format(date ?? (request['date'] as Timestamp).toDate())} at ${time ?? request['time']}
🐾 Pet: ${request['petName']} (${request['animalType']}, ${request['breed']})
👤 Doctor: ${context.read<Database>().userName ?? 'Unknown Doctor'}
📋 Status: ${status == 'accepted' ? 'Accepted ✅' : 'Declined ❌'}
''';

      // Prepare the message data
      final messageData = {
        'message': messageText,
        'receiverID': request['userId'],
        'senderEmail': doctorEmail,
        'senderID': doctorId,
        'timestamp': formattedTimestamp,
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
        'participants': [request['userId'], doctorId],
        'lastMessage': messageText,
        'lastMessageTime': formattedTimestamp,
        'lastMessageSender': doctorId,
      }, SetOptions(merge: true));

      // Move to completed_requests or delete from pending_requests
      if (status == 'accepted') {
        // Move to completed_requests with only required fields
        await FirebaseFirestore.instance
            .collection('doctors_data')
            .doc(doctorId)
            .collection('completed_requests')
            .doc(requestId)
            .set({
          'petId': request['petId'],
          'petName': request['petName'],
          'date': request['date'],
          'time': request['time'],
          'userId': request['userId'],
          'userName': request['userName'],
          'animalType': request['animalType'],
          'breed': request['breed'],
          'typeOfRequest': request['typeOfRequest'],
          'address': request['address'],
          'status': 'accepted',
          'acceptedAt': now,
          'createdAt': request['createdAt'],
        });

        // If it's an appointment, update the time slot
        if (typeOfRequest == 'appointment' && date != null && time != null) {
          await FirebaseFirestore.instance
              .collection('doctors_data')
              .doc(doctorId)
              .collection('timeSlots')
              .doc(DateFormat('yyyy-MM-dd').format(date))
              .set({
            time: false,
          }, SetOptions(merge: true));
        }
      }

      // Delete from pending_requests
      await requestDoc.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${typeOfRequest == 'pet_verification' ? 'Pet verification' : 'Booking'} request $status successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Requests',
          style: GoogleFonts.secularOne(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF9CAF88),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors_data')
            .doc(doctorId)
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
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;
              final date = (request['date'] as Timestamp).toDate();
              final time = request['time'] as String;
              final petName = request['petName'] as String;
              final userName = request['userName'] as String;
              final breed = (request['breed'] ?? '') as String;
              final animalType = (request["animalType"] ?? '') as String;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              getImagePath(animalType, breed),
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  petName,
                                  style: GoogleFonts.secularOne(
                                    fontSize: 18,
                                    color: const Color(0xFF9CAF88),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Owner: $userName',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateFormat('MMM dd, yyyy').format(date)} at $time',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _handleBookingRequest(
                              context,
                              requestId,
                              'rejected',
                              date: date,
                              time: time,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Decline'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _handleBookingRequest(
                              context,
                              requestId,
                              'accepted',
                              date: date,
                              time: time,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9CAF88),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
