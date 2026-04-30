import 'package:app/root/app_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:route_store_module/output/route_store_output.dart';
import 'package:route_store_module/view/screens/sale/store_list_sale_view.dart';
import 'package:route_store_module/entity/store_item.dart';
import 'package:route_store_module/view/screens/sale/store_home_sale_view.dart';

class RouteStoreRoot {
  Widget build(Function(AppOutput) onNavigate) {
    final storage = get<AppStorage>();
    final user = storage.get<Map<String, dynamic>>('user')!;
    final userId = user['id'] as String;

    void handleOutput(RouteStoreOutput output) {
      if (output.action == 'CHECKIN' || output.action == 'ATTENDANCE') {
        storage.set('current_store_id', output.storeId);
        storage.set('current_store_name', output.storeName ?? '');
        storage.set('current_route_id', output.routeId);
        storage.set('current_route_name', output.routeName ?? '');
        if (output.latitude != null) storage.set('current_store_lat', output.latitude);
        if (output.longitude != null) storage.set('current_store_lng', output.longitude);
        onNavigate(AppOutput(toModule: 'ATTENDANCE'));
      } else if (output.action == 'ORDER') {
        storage.set('current_store_id', output.storeId);
        storage.set('current_store_name', output.storeName ?? '');
        onNavigate(AppOutput(toModule: 'ORDER'));
      }
    }

    // Hiện tại chỉ build cho Sale
    return StoreListSaleView(
      userId: userId,
      onOutput: handleOutput,
    );
  }

  Widget buildStoreHome(Function(AppOutput) onNavigate) {
    final storage = get<AppStorage>();
    final storeId = storage.get<int>('current_store_id') ?? 0;
    final storeName = storage.get<String>('current_store_name') ?? '';
    final routeId = storage.get<int>('current_route_id') ?? 0;
    final routeName = storage.get<String>('current_route_name') ?? '';

    final store = StoreItem(
      id: storeId,
      name: storeName,
      routeId: routeId,
      routeName: routeName,
      sequence: 0,
      latitude: storage.get<double>('current_store_lat'),
      longitude: storage.get<double>('current_store_lng'),
      isCompleted: false,
    );

    return StoreHomeSaleView(
      store: store,
      onOutput: (output) {
        switch (output.action) {
          case 'ORDER':
            storage.set('current_store_id', output.storeId);
            storage.set('current_store_name', output.storeName ?? '');
            onNavigate(AppOutput(toModule: 'CREATE_ORDER'));
            break;
          case 'INVENTORY':
            storage.set('current_store_id', output.storeId);
            onNavigate(AppOutput(toModule: 'INVENTORY'));
            break;
          case 'CHECKOUT':
            storage.set('current_store_id', output.storeId);
            storage.set('current_store_name', output.storeName ?? '');
            onNavigate(AppOutput(toModule: 'CHECKOUT'));
            break;
          case 'BACK':
            onNavigate(AppOutput(toModule: 'ROUTE_STORE'));
            break;
        }
      },
    );
  }
}
