import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entity/leave_request_entity.dart';
import '../../entity/leave_status.dart';
import '../../logic_data/leave_data.dart';
import '../../logic_uc/fetch_leave_list_uc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PendingListState {
  final List<LeaveRequestEntity> leaves;
  final bool isLoading;
  final String? errorMessage;

  const PendingListState({
    this.leaves = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PendingListState copyWith({
    List<LeaveRequestEntity>? leaves,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PendingListState(
      leaves: leaves ?? this.leaves,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  int get pendingCount => leaves.length;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PendingListNotifier extends StateNotifier<PendingListState> {
  final FetchLeaveListUc _fetchUc;
  final String managerId;
  final String groupId;

  PendingListNotifier({
    required FetchLeaveListUc fetchUc,
    required this.managerId,
    required this.groupId,
  })  : _fetchUc = fetchUc,
        super(const PendingListState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _fetchUc(
        userId: managerId,
        role: 'Manager',
        groupId: groupId,
        filterStatus: LeaveStatus.pending,
      );
      state = state.copyWith(leaves: list, isLoading: false);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  Future<void> refresh() => _load();

  /// Xoá 1 đơn khỏi list local sau khi Manager duyệt/từ chối
  void removeLeave(int leaveId) {
    state = state.copyWith(
      leaves: state.leaves.where((l) => l.id != leaveId).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final pendingListNotifierProvider =
    StateNotifierProvider.autoDispose<PendingListNotifier, PendingListState>(
  (ref) => throw UnimplementedError(
    'pendingListNotifierProvider phải được override trong Leave_Module.',
  ),
);

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Màn hình danh sách đơn nghỉ phép đang chờ duyệt (Manager).
/// Layout theo Figma: header + badge count + list card.
class PendingListView extends ConsumerWidget {
  /// Callback khi Manager tap vào một đơn để xem chi tiết/duyệt.
  final void Function(LeaveRequestEntity leave)? onTapLeave;
  final VoidCallback? onBack;

  const PendingListView({
    super.key,
    this.onTapLeave,
    this.onBack,
  });

  // ── helpers ─────────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}';

  String _monthLabel(DateTime dt) =>
      'TH${dt.month.toString().padLeft(2, '0')}';

  String _dayRange(LeaveRequestEntity leave) {
    final start = _formatDate(leave.startDate);
    final end = _formatDate(leave.endDate);
    if (leave.totalDays == 1) return '1 ngày ($start)';
    return '${leave.totalDays} ngày ($start - $end)';
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pendingListNotifierProvider);
    final notifier = ref.read(pendingListNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0F3c8f),
          onRefresh: notifier.refresh,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(
                    top: 24, left: 24, right: 24, bottom: 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(state),
                    const SizedBox(height: 48),
                    _buildBody(state),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(PendingListState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role label
        
        const SizedBox(height: 4),
        // Title row: heading + pending badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: const Text(
                'Duyệt đơn\nnghỉ phép',
                style: TextStyle(
                  color: Color(0xFF0F3c8f),
                  fontSize: 30,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.75,
                  height: 1.20,
                ),
              ),
            ),
            // Pending count badge
            if (!state.isLoading)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: ShapeDecoration(
                  color: const Color(0xFFE8E8E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${state.pendingCount} đơn\nchờ duyệt',
                      style: const TextStyle(
                        color: Color(0xFF434651),
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────────

  Widget _buildBody(PendingListState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F3c8f)),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    if (state.leaves.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(
          child: Column(
            children: const [
              Icon(Icons.check_circle_outline,
                  size: 48, color: Color(0xFF22C55E)),
              SizedBox(height: 12),
              Text(
                'Không có đơn nào cần duyệt.',
                style: TextStyle(
                  color: Color(0xFF434651),
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label + count
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đang chờ duyệt',
                style: TextStyle(
                  color: Color(0xFF0F3c8f),
                  fontSize: 24,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.60,
                  height: 1.33,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Text(
                  '${state.pendingCount}',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 14,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...state.leaves.map((leave) => _buildPendingCard(leave)).toList(),
      ],
    );
  }

  // ── Pending card ──────────────────────────────────────────────────────────────

  Widget _buildPendingCard(LeaveRequestEntity leave) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        key: Key('pending_card_${leave.id}'),
        onTap: () => onTapLeave?.call(leave),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: date box + info
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Date box
                  Container(
                    width: 64,
                    height: 64,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF3F3F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${leave.startDate.day}',
                          style: const TextStyle(
                            color: Color(0xFF0F3c8f),
                            fontSize: 18,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            height: 1.56,
                          ),
                        ),
                        Text(
                          _monthLabel(leave.startDate),
                          style: const TextStyle(
                            color: Color(0xFF0F3c8f),
                            fontSize: 10,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Info block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reason title
                        Text(
                          leave.reason.length > 28
                              ? '${leave.reason.substring(0, 28)}…'
                              : leave.reason,
                          style: const TextStyle(
                            color: Color(0xFF0F3c8f),
                            fontSize: 18,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            height: 1.56,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Date range
                        Text(
                          _dayRange(leave),
                          style: const TextStyle(
                            color: Color(0xFF434651),
                            fontSize: 14,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bottom row: status badge + employee id chip + chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TRẠNG THÁI label
                      const Text(
                        'TRẠNG THÁI',
                        style: TextStyle(
                          color: Color(0x99434651),
                          fontSize: 10,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.50,
                          height: 1.50,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Pending badge
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Đang chờ',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Employee ID chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF3F3F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        child: Text(
                          // Hiển thị 8 ký tự đầu của userId
                          leave.userId.length > 8
                              ? '#${leave.userId.substring(0, 8)}'
                              : '#${leave.userId}',
                          style: const TextStyle(
                            color: Color(0xFF434651),
                            fontSize: 12,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chevron
                      Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF3F3F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF434651),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
