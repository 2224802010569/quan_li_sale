import 'package:flutter/material.dart';
import 'package:route_store_module/input/route_store_input.dart';

import 'package:route_store_module/view/screens/sale/route_home_sale_view.dart';
import 'package:route_store_module/view/screens/manager/route_home_manager_view.dart';

class RouteStoreRoot {
  static Widget openHome(String role, VoidCallback onBack) {
    final input = RouteStoreInput(role: role);

    if (input.isSale()) {
      return RouteHomeSaleView(onBack: onBack);
    }

    if (input.isManager()) {
      return RouteHomeManagerView(onBack: onBack);
    }

    return const Scaffold(body: Center(child: Text('Không có quyền')));
  }
}
