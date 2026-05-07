import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import 'package:core/storage/app_storage.dart';

import 'output/leave_event.dart';

import 'logic_data/leave_data.dart';

import 'logic_uc/approve_leave_uc.dart';
import 'logic_uc/fetch_leave_list_uc.dart';
import 'logic_uc/leave_history_uc.dart';
import 'logic_uc/submit_leave_uc.dart';

import 'view/manager/approve_detail_view.dart';
import 'view/manager/leave_history_view.dart';
import 'view/manager/pending_list_view.dart';

import 'view/sale/leave_form_view.dart';
import 'view/sale/my_leave_list_view.dart';

export 'output/leave_event.dart';

/// Entry point duy nhất của Leave_Module.
/// Pattern giống UserScreen: nhận [onEvent] + [view] param.
/// Đọc user từ SessionManager (AppStorage) — không nhận userId từ ngoài.
class LeaveScreen extends StatelessWidget {
  final Function(LeaveEvent) onEvent;

  /// Tên view cần render:
  /// - ''               → Sale mặc định (MyLeaveListView) hoặc Manager (PendingListView)
  /// - 'SALE_FORM'      → Form đăng ký nghỉ
  /// - 'MANAGER_PENDING'→ Danh sách đơn chờ duyệt
  /// - 'MANAGER_HISTORY'→ Lịch sử nghỉ phép nhân viên
  final String view;

  const LeaveScreen({
    super.key,
    required this.onEvent,
    this.view = '',
  });

  @override
  Widget build(BuildContext context) {
    // ── Đọc user từ AppStorage (đã lưu sau login) ────────────────────────────
    final storage = get<AppStorage>();
    final userMap = storage.get<Map<String, dynamic>>('user');

    if (userMap == null) {
      return const Scaffold(
        body: Center(child: Text('Chưa đăng nhập')),
      );
    }

    final userId = (userMap['id'] ?? '').toString();
    final userRole = (userMap['role'] ?? '').toString();
    final groupId = (userMap['groupId'] ?? userMap['group_id'] ?? '').toString();

    // ── Lấy SupabaseClient từ DI ─────────────────────────────────────────────
    final supabase = get<SupabaseConnect>().client!;

    // ── Khởi tạo Data / UC ───────────────────────────────────────────────────
    final leaveData = LeaveData(supabase);

    final fetchUc = FetchLeaveListUc(leaveData);
    final submitUc = SubmitLeaveUc(leaveData);
    final approveUc = ApproveLeaveUc(leaveData, supabase);
    final historyUc = LeaveHistoryUc(leaveData);

    // ── Xác định widget cần render ────────────────────────────────────────────
    final Widget child;

    switch (view) {
      case 'SALE_FORM':
        child = LeaveFormView(
          onBack: () => onEvent(LeaveEvent.close()),
          onSubmitSuccess: () => onEvent(LeaveEvent.submitted()),
        );
        break;

      case 'MANAGER_PENDING':
        child = _ManagerWithApproveNavigator(
          onEvent: onEvent,
          groupId: groupId,
          managerId: userId,
        );
        break;

      case 'MANAGER_HISTORY':
        child = LeaveHistoryView(
          onBack: () => onEvent(LeaveEvent.close()),
        );
        break;

      default:
        // Mặc định: Sale → MyLeaveListView (với internal navigator cho form)
        // Manager → PendingListView
        if (userRole.toLowerCase() == 'sale') {
          child = _SaleWithFormNavigator(onEvent: onEvent);
        } else {
          child = _ManagerWithApproveNavigator(
            onEvent: onEvent,
            groupId: groupId,
            managerId: userId,
          );
        }
        break;
    }

    // ── Wrap trong ProviderScope với đầy đủ overrides ─────────────────────────
    return ProviderScope(
      overrides: [
        // --- SALE ---
        myLeaveListNotifierProvider.overrideWith(
          (ref) => MyLeaveListNotifier(
            fetchUc: fetchUc,
            userId: userId,
          ),
        ),
        leaveFormNotifierProvider.overrideWith(
          (ref) => LeaveFormNotifier(
            submitLeaveUc: submitUc,
            userId: userId,
          ),
        ),

        // --- MANAGER ---
        pendingListNotifierProvider.overrideWith(
          (ref) => PendingListNotifier(
            fetchUc: fetchUc,
            managerId: userId,
            groupId: groupId,
          ),
        ),
        approveDetailNotifierProvider.overrideWith(
          (ref) => ApproveDetailNotifier(
            approveUc: approveUc,
            approverId: userId,
            groupId: groupId,
          ),
        ),
        leaveHistoryViewNotifierProvider.overrideWith(
          (ref) => LeaveHistoryViewNotifier(
            historyUc: historyUc,
            leaveData: leaveData,
            groupId: groupId,
          ),
        ),
      ],
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Sale internal navigator — MyLeaveListView → LeaveFormView
// ---------------------------------------------------------------------------

/// Widget nội bộ cho Sale: danh sách đơn + navigate vào form tạo đơn mới.
class _SaleWithFormNavigator extends StatefulWidget {
  final Function(LeaveEvent) onEvent;

  const _SaleWithFormNavigator({required this.onEvent});

  @override
  State<_SaleWithFormNavigator> createState() => _SaleWithFormNavigatorState();
}

class _SaleWithFormNavigatorState extends State<_SaleWithFormNavigator> {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/sale/form':
            page = LeaveFormView(
              onBack: () => _navKey.currentState?.pop(),
              onSubmitSuccess: () {
                widget.onEvent(LeaveEvent.submitted());
                _navKey.currentState?.pop();
              },
            );
            break;
          default: // '/'
            page = MyLeaveListView(
              onAddLeave: () => _navKey.currentState?.pushNamed('/sale/form'),
              onBack: () => widget.onEvent(LeaveEvent.close()),
            );
            break;
        }
        return MaterialPageRoute(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Manager internal navigator — PendingListView → ApproveDetailView
// ---------------------------------------------------------------------------

/// Widget nội bộ: dùng Navigator để từ PendingListView push sang ApproveDetailView.
class _ManagerWithApproveNavigator extends StatefulWidget {
  final Function(LeaveEvent) onEvent;
  final String groupId;
  final String managerId;

  const _ManagerWithApproveNavigator({
    required this.onEvent,
    required this.groupId,
    required this.managerId,
  });

  @override
  State<_ManagerWithApproveNavigator> createState() =>
      _ManagerWithApproveNavigatorState();
}

class _ManagerWithApproveNavigatorState
    extends State<_ManagerWithApproveNavigator> {
  final _navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = PendingListView(
              onTapLeave: (leave) {
                _navKey.currentState?.pushNamed(
                  '/manager/approve',
                  arguments: leave,
                );
              },
              onBack: () => widget.onEvent(LeaveEvent.close()),
            );
            break;

          case '/manager/approve':
            final leave = settings.arguments;
            page = ApproveDetailView(
              leave: leave as dynamic,
              onBack: () => _navKey.currentState?.pop(),
              onDecisionSuccess: () {
                widget.onEvent(LeaveEvent.approved());
                _navKey.currentState?.pop();
              },
            );
            break;

          default:
            page = const Scaffold(
              body: Center(child: Text('Route không tồn tại')),
            );
        }

        return MaterialPageRoute(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }
}
