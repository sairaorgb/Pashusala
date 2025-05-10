import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class DoctorBookingRequests extends StatelessWidget {
  final String doctorId;

  const DoctorBookingRequests({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  Future<void> _handleBookingRequest(
    BuildContext context,
    String requestId,
    String status,
  ) async {
    try {
      // Update the request status
      await FirebaseFirestore.instance
          .collection('doctors_data')
          .doc(doctorId)
          .collection('requests')
          .doc(requestId)
          .update({'status': status});

      // If accepted, update the time slot availability
      if (status == 'accepted') {
        final requestDoc = await FirebaseFirestore.instance
            .collection('doctors_data')
            .doc(doctorId)
            .collection('requests')
            .doc(requestId)
            .get();

        final data = requestDoc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final time = data['time'] as String;

        // Update the time slot in the doctor's time slots
        await FirebaseFirestore.instance
            .collection('doctors_data')
            .doc(doctorId)
            .collection('timeSlots')
            .doc(DateFormat('yyyy-MM-dd').format(date))
            .set({
          time: false,
        }, SetOptions(merge: true));
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
            .collection('requests')
            .where('status', isEqualTo: 'pending')
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
