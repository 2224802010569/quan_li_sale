import '../entity/attendance.dart';
import '../entity/store.dart';
import '../entity/user.dart';
import '../logic_data/mock_data.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceUseCase {
  Future<List<Attendance>> getAttendanceHistory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.currentSessionHistory;
  }

  Future<Store> getCurrentStoreInfo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.currentStore;
  }

  Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.currentUser;
  }

  Future<List<User>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.allUsers;
  }

  Future<bool> submitCheckIn(String storeId, String imageUrl) async {
    await Future.delayed(const Duration(seconds: 1));
    final store = MockData.currentStore; // In real app, query by storeId
    MockData.currentSessionHistory.insert(0, Attendance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: MockData.currentUser.id,
      storeName: store.name,
      distance: store.distance,
      time: DateTime.now(),
      attendanceType: AttendanceType.checkIn,
      imageUrl: imageUrl,
      locationAddress: store.route, // Mock address using route
    ));
    return true;
  }

  Future<bool> submitCheckOut(String storeId, String imageUrl) async {
    await Future.delayed(const Duration(seconds: 1));
    final store = MockData.currentStore;
    MockData.currentSessionHistory.insert(0, Attendance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: MockData.currentUser.id,
      storeName: store.name,
      distance: store.distance,
      time: DateTime.now(),
      attendanceType: AttendanceType.checkOut,
      imageUrl: imageUrl,
      locationAddress: store.route,
    ));
    return true;
  }

  Future<String> checkLocationAndCapture({
    required CameraController cameraController,
    required double destLat,
    required double destLng,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dịch vụ định vị đang bị tắt.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí bị từ chối.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn.');
    } 

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destLat,
      destLng,
    );

    if (distance > 20.0) {
      throw Exception('Ngoài phạm vi chấm công (Khoảng cách hiện tại: ${distance.toStringAsFixed(1)} m)');
    }

    final XFile file = await cameraController.takePicture();
    return file.path;
  }
}
