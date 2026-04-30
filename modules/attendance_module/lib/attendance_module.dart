import 'package:flutter/material.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'view/attendance_history_screen.dart';
import 'view/camera_action_screen.dart';
import 'entity/store.dart';
import 'output/attendance_output.dart';
import 'input/attendance_input.dart';

export 'input/attendance_input.dart';
export 'output/attendance_output.dart';

class AttendanceScreen extends StatelessWidget {
  final AttendanceInput input;
  final Function(AttendanceOutput) onOutput;
  final VoidCallback onBack;

  const AttendanceScreen({
    super.key,
    required this.input,
    required this.onOutput,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final user = get<AppStorage>().get<Map<String, dynamic>>('user');
    final role = user?['role'] ?? 'Sale';

    if (role == 'Manager') {
      return AttendanceHistoryScreen(onBack: onBack);
    } else {
      return CameraActionScreen(
        store: Store(
          id: input.storeId,
          name: input.storeName,
          distance: '0m',
          route: input.routeName ?? '',
          routeId: input.routeId,
          lastVisited: 'Chưa có',
          latitude: input.latitude,
          longitude: input.longitude,
        ),
        onOutput: onOutput,
        onBack: onBack,
      );
    }
  }
}
