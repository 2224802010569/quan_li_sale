import '../entity/attendance.dart';
import '../entity/store.dart';
import '../entity/user.dart';

class MockData {
  static final User currentUser = User(
    id: 'u1',
    name: 'Nguyễn Văn A',
    employeeCode: '9502',
    avatarUrl: 'https://i.pravatar.cc/150?img=11', // Dummy avatar
    currentRoute: 'Tuyến HCM',
    isEnoughWorkingDays: true,
    lastUpdated: '05:30 PM hôm nay',
  );

  static final List<User> allUsers = [
    currentUser,
    User(
      id: 'u2',
      name: 'Trần Thị B',
      employeeCode: '9503',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      currentRoute: 'Tuyến Hà Nội',
      isEnoughWorkingDays: false,
      lastUpdated: '09:00 AM hôm qua',
    ),
  ];

  static final Store currentStore = Store(
    id: 's1',
    name: 'Cửa hàng Tạp hóa Lan Anh',
    distance: '3m',
    route: 'Quận 1 - T2',
    lastVisited: '3 ngày trước',
  );

  static List<Attendance> currentSessionHistory = [];
}
