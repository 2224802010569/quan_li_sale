import 'package:app/root/app_output.dart';
import 'package:attendance_module/attendance_module.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:flutter/material.dart';

class AttendanceRoot {
  Widget build(Function(AppOutput) onNavigate) {
    return AttendanceScreen(
      input: AttendanceInput(
        storeId: get<AppStorage>().get<int>('current_store_id') ?? 0,
        storeName: get<AppStorage>().get<String>('current_store_name') ?? 'Không rõ',
        routeId: get<AppStorage>().get<int>('current_route_id'),
        routeName: get<AppStorage>().get<String>('current_route_name') ?? '',
        latitude: get<AppStorage>().get<double>('current_store_lat'),
        longitude: get<AppStorage>().get<double>('current_store_lng'),
      ),
      onOutput: (output) {
        if (output.success && output.storeId != null) {
          // Lưu thông tin cửa hàng vào storage
          get<AppStorage>().set('current_store_id', output.storeId);
          get<AppStorage>().set('current_store_name', output.storeName ?? '');
          get<AppStorage>().set('current_route_id', output.routeId);
          // Chuyển sang trang chủ cửa hàng
          onNavigate(AppOutput(toModule: 'STORE_HOME'));
        }
        // Nếu Manager xem lịch sử thì không cần navigate
      },
      onBack: () {
        final storage = get<AppStorage>();
        storage.remove('current_store_id');
        storage.remove('current_store_name');
        storage.remove('current_store_lat');
        storage.remove('current_store_lng');
        storage.remove('current_route_id');
        storage.remove('current_route_name');
        onNavigate(AppOutput(toModule: 'ROUTE_STORE'));
      },
    );
  }

  Widget buildCheckout(Function(AppOutput) onNavigate) {
    final storage = get<AppStorage>();
    return AttendanceScreen(
      input: AttendanceInput(
        storeId: storage.get<int>('current_store_id') ?? 0,
        storeName: storage.get<String>('current_store_name') ?? '',
        routeId: storage.get<int>('current_route_id'),
        routeName: storage.get<String>('current_route_name') ?? '',
        latitude: storage.get<double>('current_store_lat'),
        longitude: storage.get<double>('current_store_lng'),
        forceCheckout: true,
      ),
      onOutput: (output) {
        if (output.success) {
          // Xoá session cửa hàng hiện tại để cho phép Sale chọn cửa hàng mới
          storage.remove('current_store_id');
          storage.remove('current_store_name');
          storage.remove('current_store_lat');
          storage.remove('current_store_lng');
          storage.remove('current_route_id');
          storage.remove('current_route_name');
          onNavigate(AppOutput(toModule: 'ROUTE_STORE'));
        }
      },
      onBack: () => onNavigate(AppOutput(toModule: 'STORE_HOME')),
    );
  }
}
