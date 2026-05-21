import 'package:app/root/app_output.dart';
import 'package:flutter/material.dart';
import 'package:route_store_module/route_store_module.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:app/root/store_home_screen.dart';

class RouteStoreRoot {
  Widget build(Function(AppOutput) onNavigate) {
    final storage = get<AppStorage>();
    return DailyRouteView(
      onCheckin: (store, route) {
        // Lưu thông tin cửa hàng vào storage để AttendanceRoot đọc
        storage.set('current_store_id', store.id);
        storage.set('current_store_name', store.storeName);
        storage.set('current_store_lat', store.latitude);
        storage.set('current_store_lng', store.longitude);
        
        // Lưu thông tin tuyến vào storage
        storage.set('current_route_id', route.id);
        storage.set('current_route_name', route.routeName);
        
        // Navigate sang màn hình chấm công (check-in)
        onNavigate(AppOutput(toModule: 'ATTENDANCE'));
      },
    );
  }

  Widget buildStoreManager(Function(AppOutput) onNavigate) {
    return StoreListView(
      onAdd: () => onNavigate(AppOutput(toModule: 'CREATE_STORE')),
      onEdit: (store) => onNavigate(AppOutput(toModule: 'EDIT_STORE', data: {'store': store})),
    );
  }

  Widget buildRouteManager(Function(AppOutput) onNavigate) {
    return RouteListView(
      onAdd: () => onNavigate(AppOutput(toModule: 'CREATE_ROUTE')),
      onEdit: (route) => onNavigate(AppOutput(toModule: 'EDIT_ROUTE', data: {'route': route})),
    );
  }



  Widget buildCreateStore(Function(AppOutput) onNavigate, VoidCallback onBack) {
    return CreateStoreView(onBack: onBack);
  }

  Widget buildEditStore(Function(AppOutput) onNavigate, VoidCallback onBack) {
    final storage = get<AppStorage>();
    final store = storage.get<StoreEntity>('store');
    if (store == null) return const Scaffold(body: Center(child: Text('Không tìm thấy thông tin cửa hàng')));
    return CreateStoreView(onBack: onBack, store: store);
  }

  Widget buildCreateRoute(Function(AppOutput) onNavigate, VoidCallback onBack) {
    return CreateRouteView(onBack: onBack);
  }

  Widget buildEditRoute(Function(AppOutput) onNavigate, VoidCallback onBack) {
    final storage = get<AppStorage>();
    final route = storage.get<RouteEntity>('route');
    if (route == null) return const Scaffold(body: Center(child: Text('Không tìm thấy thông tin tuyến')));
    return EditRouteView(route: route, onBack: onBack);
  }

  Widget buildStoreHome(Function(AppOutput) onNavigate) {
    return StoreHomeScreen(onNavigate: onNavigate);
  }
}
