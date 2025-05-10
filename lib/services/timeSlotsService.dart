import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlotsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, bool>> _cachedTimeSlots = {};

  // Define all possible time slots
  final Map<String, bool> _defaultTimeSlots = {
    "10:00 AM": true,
    "10:30 AM": true,
    "11:00 AM": true,
    "11:30 AM": true,
    "12:00 PM": true,
    "01:00 PM": true,
    "03:00 PM": true,
    "03:30 PM": true,
    "04:00 PM": true
  };

  // Convert time string to DateTime for comparison
  DateTime _parseTimeString(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    // Convert to 24-hour format
    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Check if a time slot is in the past
  bool _isTimeSlotInPast(String timeStr, DateTime date) {
    final slotTime = _parseTimeString(timeStr);
    final slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      slotTime.hour,
      slotTime.minute,
    );
    return slotDateTime.isBefore(DateTime.now());
  }

  Future<Map<String, Map<String, bool>>> getTimeSlotsForNext7Days(
      String doctorId) async {
    // If we already have cached data, return it
    if (_cachedTimeSlots.isNotEmpty) {
      return _cachedTimeSlots;
    }

    final now = DateTime.now();
    final timeSlots = <String, Map<String, bool>>{};

    // Fetch all time slots for next 7 days in parallel
    final futures = List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      final dateString = _formatDate(date);
      return _firestore
          .collection('doctors_data')
          .doc(doctorId)
          .collection('timeSlots')
          .doc(dateString)
          .get()
          .then((doc) {
        // Start with all slots available
        timeSlots[dateString] = Map<String, bool>.from(_defaultTimeSlots);

        // Mark past slots as unavailable
        timeSlots[dateString]!.forEach((time, _) {
          if (_isTimeSlotInPast(time, date)) {
            timeSlots[dateString]![time] = false;
          }
        });

        // Update with booked slots if they exist
        if (doc.exists) {
          final bookedSlots = doc.data() as Map<String, dynamic>;
          bookedSlots.forEach((time, isAvailable) {
            if (timeSlots[dateString]!.containsKey(time)) {
              timeSlots[dateString]![time] = isAvailable as bool;
            }
          });
        }
      });
    });

    await Future.wait(futures);
    _cachedTimeSlots = timeSlots;
    return timeSlots;
  }

  Map<String, bool>? getTimeSlotsForDate(String dateString) {
    return _cachedTimeSlots[dateString];
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void clearCache() {
    _cachedTimeSlots.clear();
  }
}
