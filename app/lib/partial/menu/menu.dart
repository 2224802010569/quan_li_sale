import 'package:app/partial/menu/menu_widget/menu_config.dart';
import 'package:app/partial/menu/menu_widget/menu_item.dart';
import 'package:app/root/app_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final Function(AppOutput) onOutput;
  final String currentModule;

  const Menu({super.key, required this.onOutput, required this.currentModule});
  static const List<MenuConfig> _allMenus = [
    // Không cần login
    MenuConfig(
      title: 'Đăng nhập',
      icon: Icons.login,
      module: 'USER',
      roles: [],
    ),

    // Sale
    MenuConfig(
      title: 'Danh sách cửa hàng',
      icon: Icons.store,
      module: 'ROUTE_STORE',
      roles: ['Sale'],
    ),
    //  MenuConfig(title: 'Chấm công',            icon: Icons.check_circle_outline, module: 'ATTENDANCE',          roles: ['Sale']),
    MenuConfig(
      title: 'Lịch sử đơn hàng',
      icon: Icons.history,
      module: 'ORDER',
      roles: ['Sale'],
    ),
    MenuConfig(
      title: 'Đăng ký nghỉ phép',
      icon: Icons.event_busy,
      module: 'LEAVE',
      roles: ['Sale'],
    ),
    MenuConfig(
      title: 'Profile',
      icon: Icons.person,
      module: 'USER_PROFILE',
      roles: ['Sale', 'Manager'],
    ),

    // Manager
    MenuConfig(
      title: 'Quản lý cửa hàng',
      icon: Icons.store_mall_directory,
      module: 'STORE_MANAGER',
      roles: ['Manager'],
    ),

    MenuConfig(
      title: 'Quản lý tuyến',
      icon: Icons.route,
      module: 'ROUTE_STORE_MANAGER',
      roles: ['Manager'],
    ),
    MenuConfig(
      title: 'Lịch sử chấm công',
      icon: Icons.access_time,
      module: 'ATTENDANCE',
      roles: ['Manager'],
    ),
    MenuConfig(
      title: 'Lịch sử đơn hàng',
      icon: Icons.history,
      module: 'ORDER',
      roles: ['Manager'],
    ),
    MenuConfig(
      title: 'Quản lý nhân sự',
      icon: Icons.group,
      module: 'USER_MANAGER_VIEW',
      roles: ['Manager'],
    ),
    MenuConfig(
      title: 'Duyệt đơn nghỉ phép',
      icon: Icons.approval,
      module: 'LEAVE_MANAGER_PENDING',
      roles: ['Manager'],
    ),
    MenuConfig(
      title: 'Lịch sử nghỉ phép',
      icon: Icons.history_edu,
      module: 'LEAVE_MANAGER_HISTORY',
      roles: ['Manager'],
    ),
  ];

  void _navigate(BuildContext context, String module) {
    Navigator.pop(context);
    onOutput(AppOutput(toModule: module));
  }

  List<MenuConfig> get menus {
    final storage = get<AppStorage>();
    final user = storage.get<Map<String, dynamic>>('user');
    if (user == null) {
      return _allMenus.where((m) => m.roles.isEmpty).toList();
    }

    final role = (user['role'] ?? '').toString().trim().toLowerCase();
    return _allMenus.where((m) {
      if (m.roles.isEmpty) return true;
      return m.roles.any(
        (allowedRole) => allowedRole.trim().toLowerCase() == role,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF5F6FA),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Menu",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),
            ...menus.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MenuItem(
                  title: item.title,
                  icon: item.icon,
                  isActive: currentModule == item.module,
                  onTap: () => _navigate(context, item.module),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
