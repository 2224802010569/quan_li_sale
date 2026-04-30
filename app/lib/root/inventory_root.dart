import 'package:app/root/app_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:inventory_module/inventory_module.dart';
import 'package:inventory_module/input/inventory_input.dart';
import 'package:flutter/material.dart';

class InventoryRoot {
  Widget build(Function(AppOutput) onNavigate) {
    final storage = get<AppStorage>();
    final user = storage.get<Map<String, dynamic>>('user')!;
    final storeId = storage.get<int>('current_store_id') ?? 0;

    final input = InventoryInput(
      userId: user['id'],
      storeId: storeId.toString(),
      productIds: [], // TODO: lấy danh sách product từ route sau
    );

    return InventoryModule(
      input: input,
      onOutput: (output) {
        if (output.success) {
          onNavigate(AppOutput(toModule: 'STORE_HOME'));
        }
      },
      onBack: () => onNavigate(AppOutput(toModule: 'STORE_HOME')),
    );
  }
}
