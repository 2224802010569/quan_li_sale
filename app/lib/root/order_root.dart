import 'package:flutter/material.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:oder_module/order_module_export.dart';

class OrderRoot {
  static Widget openOrder(VoidCallback onBack) {
    final storage = get<AppStorage>();
    final role = storage.get<String>('role') ?? '';
    final userId = storage.get<String>('userId') ?? '';

    final action = role == 'Sale' ? 'CREATE' : 'HISTORY';

    final input = OrderInput(
      action: action,
      userId: userId,
      role: role,
    );

    return OrderModule(
      input: input,
      onBack: onBack,
    );
  }
}
