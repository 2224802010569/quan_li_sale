import 'package:app/partial/menu/menu_widget/menu_config.dart';
import 'package:app/partial/menu/menu_widget/menu_item.dart';
import 'package:app/root/app_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:core/theme/app_colors.dart';
import 'package:core/theme/app_spacing.dart';
import 'package:core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final Function(AppOutput) onOutput;
  final String currentModule;

  const Menu({super.key, required this.onOutput, required this.currentModule});

  static const List<MenuConfig> _allMenus = [
    MenuConfig(title: 'Đăng nhập', icon: Icons.login, module: 'USER', roles: []),
    // Sale
    MenuConfig(title: 'Danh sách cửa hàng', icon: Icons.store_outlined, module: 'ROUTE_STORE', roles: ['Sale']),
    MenuConfig(title: 'Lịch sử đơn hàng', icon: Icons.receipt_long_outlined, module: 'ORDER', roles: ['Sale']),
    MenuConfig(title: 'Đăng ký nghỉ phép', icon: Icons.event_busy_outlined, module: 'LEAVE', roles: ['Sale']),
    MenuConfig(title: 'Profile', icon: Icons.person_outline_rounded, module: 'USER_PROFILE', roles: ['Sale', 'Manager']),
    // Manager
    MenuConfig(title: 'Báo cáo KPI', icon: Icons.bar_chart_outlined, module: 'KPI_MANAGER', roles: ['Manager']),
    MenuConfig(title: 'Quản lý cửa hàng', icon: Icons.store_mall_directory_outlined, module: 'STORE_MANAGER', roles: ['Manager']),
    MenuConfig(title: 'Quản lý tuyến', icon: Icons.route_outlined, module: 'ROUTE_STORE_MANAGER', roles: ['Manager']),
    MenuConfig(title: 'Lịch sử chấm công', icon: Icons.access_time_outlined, module: 'ATTENDANCE', roles: ['Manager']),
    MenuConfig(title: 'Lịch sử đơn hàng', icon: Icons.receipt_long_outlined, module: 'ORDER', roles: ['Manager']),
    MenuConfig(title: 'Quản lý nhân sự', icon: Icons.group_outlined, module: 'USER_MANAGER_VIEW', roles: ['Manager']),
    MenuConfig(title: 'Duyệt đơn nghỉ phép', icon: Icons.approval_outlined, module: 'LEAVE_MANAGER_PENDING', roles: ['Manager']),
    MenuConfig(title: 'Lịch sử nghỉ phép', icon: Icons.history_edu_outlined, module: 'LEAVE_MANAGER_HISTORY', roles: ['Manager']),
  ];

  void _navigate(BuildContext context, String module) {
    Navigator.pop(context);
    onOutput(AppOutput(toModule: module));
  }

  List<MenuConfig> get menus {
    final storage = get<AppStorage>();
    final user = storage.get<Map<String, dynamic>>('user');
    if (user == null) return _allMenus.where((m) => m.roles.isEmpty).toList();
    final role = (user['role'] ?? '').toString().trim().toLowerCase();
    return _allMenus.where((m) {
      if (m.module == 'USER') return false;
      if (m.roles.isEmpty) return true;
      return m.roles.any((r) => r.trim().toLowerCase() == role);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.white,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin, AppSpacing.xl,
                AppSpacing.containerMargin, AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ska Milk', style: AppTextStyles.headlineMd.copyWith(
                          color: AppColors.white, fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 2),
                        Text('MENU', style: AppTextStyles.caption.copyWith(
                          color: AppColors.onPrimaryContainer,
                        )),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Menu Items ───────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.stackGap,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: menus.map((item) => _buildMenuItem(context, item)).toList(),
                ),
              ),
            ),

            // ── Version footer ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('v1.0.0', style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuConfig item) {
    final isActive = currentModule == item.module;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MenuItem(
        title: item.title,
        icon: item.icon,
        isActive: isActive,
        onTap: () => _navigate(context, item.module),
      ),
    );
  }
}
