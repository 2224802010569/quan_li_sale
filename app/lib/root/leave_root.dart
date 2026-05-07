import 'package:app/root/app_output.dart';
import 'package:flutter/material.dart';
import 'package:leave_module/leave_module.dart';

/// LeaveRoot kết nối Leave_Module vào App.
/// Pattern giống UserRoot: mỗi hàm build*() trả về 1 LeaveScreen với view cụ thể.
class LeaveRoot {
  // ── Sale ────────────────────────────────────────────────────────────────────

  /// Sale xem danh sách đơn nghỉ của mình.
  Widget build(Function(AppOutput) onNavigate) {
    return LeaveScreen(
      onEvent: (event) => _handleEvent(event, onNavigate),
    );
  }

  /// Sale tạo đơn nghỉ mới.
  Widget buildForm(Function(AppOutput) onNavigate) {
    return LeaveScreen(
      view: 'SALE_FORM',
      onEvent: (event) => _handleEvent(event, onNavigate),
    );
  }

  // ── Manager ─────────────────────────────────────────────────────────────────

  /// Manager xem danh sách đơn chờ duyệt.
  Widget buildManagerPending(Function(AppOutput) onNavigate) {
    return LeaveScreen(
      view: 'MANAGER_PENDING',
      onEvent: (event) => _handleEvent(event, onNavigate),
    );
  }

  /// Manager xem lịch sử nghỉ phép nhân viên.
  Widget buildManagerHistory(Function(AppOutput) onNavigate) {
    return LeaveScreen(
      view: 'MANAGER_HISTORY',
      onEvent: (event) => _handleEvent(event, onNavigate),
    );
  }

  // ── Event handler ────────────────────────────────────────────────────────────

  void _handleEvent(LeaveEvent event, Function(AppOutput) onNavigate) {
    switch (event.type) {
      case LeaveEventType.submitted:
        // Sau khi nộp đơn → quay về danh sách đơn của Sale
        onNavigate(AppOutput(toModule: 'LEAVE'));
        break;

      case LeaveEventType.approved:
      case LeaveEventType.rejected:
        // Sau khi duyệt/từ chối → refresh danh sách đơn Pending
        onNavigate(AppOutput(toModule: 'LEAVE_MANAGER_PENDING'));
        break;

      case LeaveEventType.close:
        // Quay về màn trước (ROUTE_STORE là màn home mặc định)
        onNavigate(AppOutput(toModule: 'ROUTE_STORE'));
        break;
    }
  }
}
