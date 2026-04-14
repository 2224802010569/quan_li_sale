enum AttendanceType { checkIn, checkOut }

class Attendance {
  final String id;
  final String userId;
  final String storeName;
  final String distance;
  final DateTime time;
  final AttendanceType attendanceType;
  final String imageUrl;
  final String locationAddress;

  Attendance({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.distance,
    required this.time,
    required this.attendanceType,
    required this.imageUrl,
    required this.locationAddress,
  });
}
