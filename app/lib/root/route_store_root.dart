import 'package:app/root/app_output.dart';
import 'package:flutter/material.dart';
import 'package:route_store_module/route_store_module.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';

class RouteStoreRoot {
  Widget build(Function(AppOutput) onNavigate) {
    // TODO: Connect DailyRouteView outputs to AppOutput
    return DailyRouteView();
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
      onAssign: () => onNavigate(AppOutput(toModule: 'ASSIGN_ROUTE')),
    );
  }

  Widget buildAssignRoute(Function(AppOutput) onNavigate, VoidCallback onBack) {
    return AssignRouteView(onBack: onBack);
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
    // Thêm một trang tạm cho Store Home
    return Scaffold(
      appBar: AppBar(title: const Text('Store Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                onNavigate(AppOutput(toModule: 'CREATE_ORDER'));
              },
              child: const Text('Lên đơn hàng (ORDER)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onNavigate(AppOutput(toModule: 'INVENTORY'));
              },
              child: const Text('Tồn kho (INVENTORY)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onNavigate(AppOutput(toModule: 'ROUTE_STORE'));
              },
              child: const Text('Quay lại lộ trình (BACK)'),
            ),
          ],
        ),
      ),
    );
  }
}
