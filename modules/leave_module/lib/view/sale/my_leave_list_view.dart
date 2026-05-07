import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entity/leave_request_entity.dart';
import '../../entity/leave_status.dart';
import '../../logic_data/leave_data.dart';
import '../../logic_uc/fetch_leave_list_uc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class MyLeaveListState {
  final List<LeaveRequestEntity> leaves;
  final bool isLoading;
  final String? errorMessage;
  final LeaveStatus? filterStatus;
  final int filterYear;

  const MyLeaveListState({
    this.leaves = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterStatus,
    required this.filterYear,
  });

  MyLeaveListState copyWith({
    List<LeaveRequestEntity>? leaves,
    bool? isLoading,
    String? errorMessage,
    LeaveStatus? filterStatus,
    bool clearFilter = false,
    bool clearError = false,
    int? filterYear,
  }) {
    return MyLeaveListState(
      leaves: leaves ?? this.leaves,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      filterStatus: clearFilter ? null : filterStatus ?? this.filterStatus,
      filterYear: filterYear ?? this.filterYear,
    );
  }

  /// Danh sách sau khi lọc theo trạng thái (nếu có)
  List<LeaveRequestEntity> get filtered {
    if (filterStatus == null) return leaves;
    return leaves.where((l) => l.status == filterStatus).toList();
  }

  int get approvedCount =>
      leaves.where((l) => l.status == LeaveStatus.approved).length;
  int get pendingCount =>
      leaves.where((l) => l.status == LeaveStatus.pending).length;
  int get totalApprovedDays => leaves
      .where((l) => l.status == LeaveStatus.approved)
      .fold(0, (sum, l) => sum + l.totalDays);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class MyLeaveListNotifier extends StateNotifier<MyLeaveListState> {
  final FetchLeaveListUc _fetchUc;
  final String userId;

  MyLeaveListNotifier({
    required FetchLeaveListUc fetchUc,
    required this.userId,
  })  : _fetchUc = fetchUc,
        super(MyLeaveListState(filterYear: DateTime.now().year)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _fetchUc(
        userId: userId,
        role: 'Sale',
        filterYear: state.filterYear,
      );
      state = state.copyWith(leaves: list, isLoading: false);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }

  void setYear(int year) {
    state = state.copyWith(filterYear: year);
    _load();
  }

  void setFilterStatus(LeaveStatus? status) {
    state = state.copyWith(
      filterStatus: status,
      clearFilter: status == null,
    );
  }

  Future<void> refresh() => _load();
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final myLeaveListNotifierProvider =
    StateNotifierProvider.autoDispose<MyLeaveListNotifier, MyLeaveListState>(
  (ref) => throw UnimplementedError(
    'myLeaveListNotifierProvider phải được override trong Leave_Module.',
  ),
);

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Màn hình lịch sử đơn nghỉ phép của Sale.
/// Layout theo Figma: header + stats row + filter year tabs + leave list.
class MyLeaveListView extends ConsumerWidget {
  final VoidCallback? onAddLeave;
  final VoidCallback? onBack;

  const MyLeaveListView({
    super.key,
    this.onAddLeave,
    this.onBack,
  });

  // ── helpers ─────────────────────────────────────────────────────────────────

  String _formatDateLabel(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';

  String _monthLabel(DateTime dt) =>
      'TH${dt.month.toString().padLeft(2, '0')}';

  String _dayRange(LeaveRequestEntity leave) {
    final start = _formatDateLabel(leave.startDate);
    final end = _formatDateLabel(leave.endDate);
    return '${leave.totalDays} ngày ($start - $end)';
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myLeaveListNotifierProvider);
    final notifier = ref.read(myLeaveListNotifierProvider.notifier);
    final currentYear = DateTime.now().year;

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
                    // ── Header ─────────────────────────────────────────────
                    _buildHeader(context, state, notifier),
                    const SizedBox(height: 48),

                    // ── Stats cards ────────────────────────────────────────
                    _buildStatsRow(state),
                    const SizedBox(height: 32),

                    // ── Section header + year filter ───────────────────────
                    _buildSectionHeader(state, notifier, currentYear),
                    const SizedBox(height: 16),

                    // ── Status filter pills ────────────────────────────────
                    _buildStatusFilter(state, notifier),
                    const SizedBox(height: 16),

                    // ── List ───────────────────────────────────────────────
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

  Widget _buildHeader(
    BuildContext context,
    MyLeaveListState state,
    MyLeaveListNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nghỉ phép',
          style: TextStyle(
            color: Color(0xFF0F3c8f),
            fontSize: 30,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            letterSpacing: -1.08,
            height: 1.11,
          ),
        ),
       
          
        
      ],
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow(MyLeaveListState state) {
    final balance = 12 - state.totalApprovedDays;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 31, left: 32, right: 32, bottom: 32),
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
              // SỐ DƯ HIỆN TẠI
              const Text(
                'SỐ DƯ HIỆN TẠI',
                style: TextStyle(
                  color: Color(0x99434651),
                  fontSize: 11,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.10,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$balance ',
                    style: const TextStyle(
                      color: Color(0xFF0F3c8f),
                      fontSize: 48,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'Ngày',
                    style: TextStyle(
                      color: Color(0xFF434651),
                      fontSize: 20,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Số ngày còn lại trong năm ${DateTime.now().year} của bạn.',
                      style: const TextStyle(
                        color: Color(0xFF434651),
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.63,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddLeave,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F3c8f),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Đăng\nký\nnghỉ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // TỔNG NGÀY ĐÃ NGHỈ + ĐANG CHỜ DUYỆT
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'TỔNG NGÀY ĐÃ NGHỈ',
                value: state.totalApprovedDays.toString().padLeft(2, '0'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                label: 'ĐANG CHỜ DUYỆT',
                value: state.pendingCount.toString().padLeft(2, '0'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: const Color(0xFFF3F3F3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0x99434651),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.10,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F3c8f),
              fontSize: 30,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.20,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header + year filter ─────────────────────────────────────────────

  Widget _buildSectionHeader(
    MyLeaveListState state,
    MyLeaveListNotifier notifier,
    int currentYear,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Chi tiết lịch sử',
          style: TextStyle(
            color: Color(0xFF0F3c8f),
            fontSize: 24,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.60,
            height: 1.33,
          ),
        ),
        Row(
          children: [currentYear, currentYear - 1].map((year) {
            final isSelected = state.filterYear == year;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                key: Key('year_filter_$year'),
                onTap: () => notifier.setYear(year),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF001D4E)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF434651),
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Status filter pills ───────────────────────────────────────────────────────

  Widget _buildStatusFilter(
    MyLeaveListState state,
    MyLeaveListNotifier notifier,
  ) {
    final filters = <LeaveStatus?>[null, ...LeaveStatus.values];
    final labels = {
      null: 'Tất cả',
      LeaveStatus.pending: 'Đang chờ',
      LeaveStatus.approved: 'Đã duyệt',
      LeaveStatus.rejected: 'Từ chối',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((status) {
          final isSelected = state.filterStatus == status;
          Color dotColor = const Color(0xFF434651);
          if (status == LeaveStatus.pending) dotColor = const Color(0xFFF59E0B);
          if (status == LeaveStatus.approved) dotColor = const Color(0xFF22C55E);
          if (status == LeaveStatus.rejected) dotColor = const Color(0xFFEF4444);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              key: Key('status_filter_${status?.name ?? 'all'}'),
              onTap: () => notifier.setFilterStatus(status),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF001D4E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status != null) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      labels[status]!,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF434651),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Body (loading / error / list) ─────────────────────────────────────────────

  Widget _buildBody(MyLeaveListState state) {
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

    final list = state.filtered;

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(
          child: Column(
            children: const [
              Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF434651)),
              SizedBox(height: 12),
              Text(
                'Không có đơn nghỉ phép nào.',
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
      children: list.map((leave) => _buildLeaveCard(leave)).toList(),
    );
  }

  // ── Leave card ────────────────────────────────────────────────────────────────

  Widget _buildLeaveCard(LeaveRequestEntity leave) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        key: Key('leave_card_${leave.id}'),
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
            // Top row: date box + title
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
                // Title + date range
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.reason.length > 30
                            ? '${leave.reason.substring(0, 30)}…'
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

            // Bottom row: status badge + chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRẠNG THÁI',
                      style: const TextStyle(
                        color: Color(0x99434651),
                        fontSize: 10,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.50,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildStatusBadge(leave.status),
                  ],
                ),
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
      ),
    );
  }

  Widget _buildStatusBadge(LeaveStatus status) {
    final Color color;
    switch (status) {
      case LeaveStatus.approved:
        color = const Color(0xFF22C55E);
      case LeaveStatus.rejected:
        color = const Color(0xFFEF4444);
      case LeaveStatus.pending:
        color = const Color(0xFFF59E0B);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}
