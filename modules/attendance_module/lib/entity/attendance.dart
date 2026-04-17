enum AttendanceType { checkIn, checkOut }

class Attendance {
  final int id;
  final String userId;
  final int storeId;
  final String storeName;
  final String distance;
  final DateTime time;
  final AttendanceType attendanceType;
  final String checkinImage;
  final String checkoutImage;
  final String locationAddress;
  final String status;

  Attendance({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.storeName,
    required this.distance,
    required this.time,
    required this.attendanceType,
    required this.checkinImage,
    required this.checkoutImage,
    required this.locationAddress,
    required this.status,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    DateTime parsedTime = DateTime.tryParse(map['checkin_time']?.toString() ?? '') ?? DateTime.now();
    // Logic to distinguish checkIn vs checkOut if needed, 
    // for now sticking to DB values or defaulting to checkIn
    AttendanceType type = map['checkout_time'] != null ? AttendanceType.checkOut : AttendanceType.checkIn;

    return Attendance(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      userId: map['user_id']?.toString() ?? '',
      storeId: map['store_id'] is int ? map['store_id'] : int.tryParse(map['store_id'].toString()) ?? 0,
      storeName: map['stores'] != null ? (map['stores']['store_name'] ?? '') : '',
      distance: map['distance']?.toString() ?? '0m',
      time: parsedTime,
      attendanceType: type,
      checkinImage: map['checkin_image'] ?? '',
      checkoutImage: map['checkout_image'] ?? '',
      locationAddress: map['routes'] != null ? (map['routes']['route_name'] ?? '') : '',
      status: map['status'] ?? 'Incomplete',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'store_id': storeId,
      'checkin_time': time.toIso8601String(),
      'checkin_image': checkinImage,
      'checkout_image': checkoutImage,
      'status': status,
    };
  }
}
