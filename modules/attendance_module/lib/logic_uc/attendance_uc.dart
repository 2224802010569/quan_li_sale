import '../entity/attendance.dart';
import '../entity/store.dart';
import '../entity/user.dart';
import '../repository/attendance_repository.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceUseCase {
  final AttendanceRepository _repository = AttendanceRepository();

  Future<List<Attendance>> getAttendanceHistory({String? userId, DateTime? month}) async {
    final user = await getCurrentUser();
    if (user.role == 'Manager') {
      if (userId != null) {
        return await _repository.getAttendanceHistory(userId: userId, month: month);
      } else {
        return await _repository.getAttendanceHistory(groupId: user.groupId, month: month);
      }
    } else {
      return await _repository.getAttendanceHistory(userId: user.id, month: month);
    }
  }


  Future<User> getCurrentUser() async {
    final user = await _repository.getCurrentUser();
    
    // Check if the user has >= 5 checkins today
    final checkInCount = await _repository.getCheckInCountForToday(user.id);
    final isEnoughWorkingDays = checkInCount >= 5;
    
    return user.copyWith(isEnoughWorkingDays: isEnoughWorkingDays);
  }

  Future<List<User>> getUsersByGroup(String groupId, String excludeUserId) async {
    final users = await _repository.getUsersByGroup(groupId, excludeUserId);
    final updatedUsers = <User>[];
    for (var u in users) {
      final checkInCount = await _repository.getCheckInCountForToday(u.id);
      updatedUsers.add(u.copyWith(isEnoughWorkingDays: checkInCount >= 5));
    }
    return updatedUsers;
  }

  Future<bool> hasOngoingCheckIn(int storeId) async {
    final user = await getCurrentUser();
    return await _repository.hasOngoingCheckIn(user.id, storeId);
  }

  Future<List<Store>> getSortedStores() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Dịch vụ định vị bị tắt.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí bị từ chối.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn.');
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    final user = await getCurrentUser();
    final stores = await _repository.getAssignedStores(user.id);
    final completedStoreIds = await _repository.getCompletedStoresForToday(user.id);
    
    for (var store in stores) {
      if (completedStoreIds.contains(store.id)) {
        store.isCompleted = true;
      }
    }
    
    stores.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      
      if (a.latitude == null || a.longitude == null) return 1;
      if (b.latitude == null || b.longitude == null) return -1;
      
      final d1 = Geolocator.distanceBetween(pos.latitude, pos.longitude, a.latitude!, a.longitude!);
      final d2 = Geolocator.distanceBetween(pos.latitude, pos.longitude, b.latitude!, b.longitude!);
      return d1.compareTo(d2);
    });
    
    return stores;
  }

  Future<bool> submitCheckIn(int storeId, String imageUrl, {int? routeId}) async {
    try {
      final user = await _repository.getCurrentUser();
      final publicUrl = await _repository.uploadImage(imageUrl);
      await _repository.saveAttendance(
        userId: user.id,
        storeId: storeId,
        routeId: routeId,
        imageUrl: publicUrl,
      );
      return true;
    } catch (e) {
      throw Exception('Lỗi Check-in: $e');
    }
  }

  Future<bool> submitCheckOut(int storeId, String imageUrl) async {
    try {
      final user = await _repository.getCurrentUser();
      // Upload ảnh checkout lên Storage (giống flow check-in)
      final publicUrl = await _repository.uploadImage(imageUrl);
      await _repository.submitCheckOut(
        userId: user.id,
        storeId: storeId,
        checkoutImageUrl: publicUrl,
      );
      return true;
    } catch (e) {
      throw Exception('Lỗi Check-out: $e');
    }
  }

  Future<String> checkLocationAndCapture({
    required CameraController cameraController,
    required double destLat,
    required double destLng,
    bool isCheckIn = true,
  }) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dịch vụ định vị đang bị tắt.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destLat,
      destLng,
    );

    if (distance > 15.0) {
      throw Exception(
        'Ngoài phạm vi chấm công. Cần cách cửa hàng dưới 15m.\n'
        'Khoảng cách hiện tại: ${distance.toStringAsFixed(1)} m',
      );
    }

    final XFile file = await cameraController.takePicture();
    return file.path;
  }
}
