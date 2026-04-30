import 'package:app/root/app_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:oder_module/order_module.dart';
import 'package:oder_module/input/order_input.dart';
import 'package:flutter/material.dart';

class OrderRoot {
  Widget build(Function(AppOutput) onNavigate) {
    return _buildInternal(onNavigate, isCreate: false);
  }

  Widget buildCreate(Function(AppOutput) onNavigate) {
    return _buildInternal(onNavigate, isCreate: true);
  }

  Widget _buildInternal(Function(AppOutput) onNavigate, {required bool isCreate}) {
    final storage = get<AppStorage>();
    final user = storage.get<Map<String, dynamic>>('user')!;
    final storeId = storage.get<int>('current_store_id');
    final storeName = storage.get<String>('current_store_name') ?? '';
    final role = user['role'] ?? 'Sale';

    final input = OrderInput(
      action: isCreate ? 'CREATE' : 'HISTORY',
      role: role,
      userId: user['id'],
      employeeName: user['full_name'] ?? '',
      storeId: storeId,
      storeName: storeName,
      groupId: user['groupId'] ?? storage.get<String>('groupId'),
    );

    return OrderModule(
      input: input,
      onBack: () => onNavigate(AppOutput(toModule: isCreate ? 'STORE_HOME' : 'ROUTE_STORE')),
      onOutput: (output) {
        onNavigate(AppOutput(toModule: isCreate ? 'STORE_HOME' : 'ROUTE_STORE'));
      },
    );
  }
}
