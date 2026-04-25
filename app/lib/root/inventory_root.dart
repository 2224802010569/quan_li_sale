import 'package:flutter/material.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:inventory_module/inventory_module_export.dart';

class InventoryRoot {
  static Widget openInventory(VoidCallback onBack, Function(dynamic) onOutput) {
    final storage = get<AppStorage>();
    final userId = storage.get<String>('userId') ?? '';
    final currentStoreId = storage.get<String>('currentStoreId') ?? '';
    final auditProductIds = storage.get<List<int>>('auditProductIds') ?? [1, 2, 3];

    final input = InventoryInput(
      userId: userId,
      storeId: currentStoreId,
      productIds: auditProductIds,
    );

    return InventoryModule(
      input: input,
      onBack: onBack,
      onOutput: onOutput,
    );
  }
}
