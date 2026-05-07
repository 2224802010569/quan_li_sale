import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic_data/leave_data.dart';
import '../../logic_uc/leave_history_uc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class LeaveHistoryViewState {
  final List<Map<String, dynamic>> employees; // [{id, name}]
  final String? selectedEmployeeId;
  final int selectedYear;
  final bool isLoading;
  final LeaveHistoryResult? result;
  final String? errorMessage;

  const LeaveHistoryViewState({
    this.employees = const [],
    this.selectedEmployeeId,
    required this.selectedYear,
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  LeaveHistoryViewState copyWith({
    List<Map<String, dynamic>>? employees,
    String? selectedEmployeeId,
    int? selectedYear,
    bool? isLoading,
    LeaveHistoryResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return LeaveHistoryViewState(
      employees: employees ?? this.employees,
      selectedEmployeeId: selectedEmployeeId ?? this.selectedEmployeeId,
      selectedYear: selectedYear ?? this.selectedYear,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class LeaveHistoryViewNotifier extends StateNotifier<LeaveHistoryViewState> {
  final LeaveHistoryUc _historyUc;
  final LeaveData _leaveData;
  final String groupId;

  LeaveHistoryViewNotifier({
    required LeaveHistoryUc historyUc,
    required LeaveData leaveData,
    required this.groupId,
  })  : _historyUc = historyUc,
        _leaveData = leaveData,
        super(LeaveHistoryViewState(selectedYear: DateTime.now().year)) {
    _loadEmployees();
  }

  /// Load danh sách nhân viên trong nhóm để populate dropdown.
  Future<void> _loadEmployees() async {
    try {
      final list = await _leaveData.getUsersInGroup(groupId);
      state = state.copyWith(employees: list);
    } catch (_) {
      // Không block UI nếu load employee list fail
    }
  }

  void selectEmployee(String employeeId) {
    state = state.copyWith(
      selectedEmployeeId: employeeId,
      clearResult: true,
      clearError: true,
    );
    _fetch();
  }

  void selectYear(int year) {
    state = state.copyWith(
      selectedYear: year,
      clearResult: true,
      clearError: true,
    );
    if (state.selectedEmployeeId != null) _fetch();
  }

  Future<void> _fetch() async {
    if (state.selectedEmployeeId == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _historyUc(
        employeeId: state.selectedEmployeeId!,
        year: state.selectedYear,
      );
      state = state.copyWith(isLoading: false, result: result);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final leaveHistoryViewNotifierProvider = StateNotifierProvider.autoDispose<
    LeaveHistoryViewNotifier, LeaveHistoryViewState>(
  (ref) => throw UnimplementedError(
    'leaveHistoryViewNotifierProvider phải được override trong Leave_Module.',
  ),
);

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Màn hình thống kê lịch sử nghỉ phép của nhân viên — dành cho Manager.
/// Layout: header + selectors (nhân viên + năm) + stats cards + leave list.
class LeaveHistoryView extends ConsumerWidget {
  final VoidCallback? onBack;

  const LeaveHistoryView({super.key, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaveHistoryViewNotifierProvider);
    final notifier = ref.read(leaveHistoryViewNotifierProvider.notifier);
    final currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
              top: 24, left: 24, right: 24, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              _buildHeader(),
              const SizedBox(height: 32),

              // ── Selectors ───────────────────────────────────────────
              _buildSelectors(state, notifier, currentYear),
              const SizedBox(height: 32),

              // ── Body ────────────────────────────────────────────────
              _buildBody(state),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        
        SizedBox(height: 4),
        Text(
          'Báo cáo nghỉ phép\nnhân viên',
          style: TextStyle(
            color: Color(0xFF0F3c8f),
            fontSize: 30,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            letterSpacing: -0.75,
            height: 1.20,
          ),
        ),
        SizedBox(height: 4),
        Opacity(
          opacity: 0.80,
          child: Text(
            'Chọn nhân viên và năm để xem thống kê',
            style: TextStyle(
              color: Color(0xFF434651),
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
        ),
      ],
    );
  }

  // ── Selectors ─────────────────────────────────────────────────────────────────

  Widget _buildSelectors(
    LeaveHistoryViewState state,
    LeaveHistoryViewNotifier notifier,
    int currentYear,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Employee dropdown
        const Text(
          'NHÂN VIÊN',
          style: TextStyle(
            color: Color(0xFF434651),
            fontSize: 12,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.20,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownField(
          key: const Key('employee_dropdown'),
          hint: 'Chọn nhân viên...',
          value: state.selectedEmployeeId,
          items: state.employees.map((e) {
            final id = e['id'] as String;
            final name = e['name'] as String? ?? id.substring(0, 8);
            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF1A1C1C),
                  fontSize: 16,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) notifier.selectEmployee(v);
          },
        ),
        const SizedBox(height: 16),

        // Year tabs
        const Text(
          'NĂM',
          style: TextStyle(
            color: Color(0xFF434651),
            fontSize: 12,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.20,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [currentYear, currentYear - 1, currentYear - 2]
              .map((year) {
            final isSelected = state.selectedYear == year;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                key: Key('year_tab_$year'),
                onTap: () => notifier.selectYear(year),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
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
                    '$year',
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

  Widget _buildDropdownField({
    required Key key,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: Color(0x7F747782),
              fontSize: 16,
              fontFamily: 'Manrope',
            ),
          ),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Color(0xFF1A1C1C),
            fontSize: 16,
            fontFamily: 'Manrope',
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF434651)),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────────

  Widget _buildBody(LeaveHistoryViewState state) {
    if (state.selectedEmployeeId == null) {
      return _buildEmptyPrompt();
    }

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
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            state.errorMessage!,
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

    if (state.result == null) return const SizedBox();

    return _buildResults(state.result!);
  }

  Widget _buildEmptyPrompt() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.person_search_outlined,
                size: 56, color: Color(0xFF434651)),
            SizedBox(height: 12),
            Text(
              'Chọn nhân viên để xem\nthống kê nghỉ phép.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF434651),
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                height: 1.63,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────────

  Widget _buildResults(LeaveHistoryResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Stats cards row ──
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'NGÀY ĐÃ NGHỈ',
                value: '${result.totalApprovedDays}',
                unit: 'ngày',
                color: const Color(0xFF0F3c8f),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                label: 'ĐANG CHỜ',
                value: '${result.pendingCount}',
                unit: 'đơn',
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                label: 'TỪ CHỐI',
                value: '${result.rejectedCount}',
                unit: 'đơn',
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Approved count card ──
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
              const Text(
                'TỔNG NGÀY NGHỈ ĐƯỢC DUYỆT',
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
                    '${result.totalApprovedDays} ',
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
              const SizedBox(height: 4),
              Text(
                'Năm ${result.year} • ${result.approvedCount} đơn đã duyệt',
                style: const TextStyle(
                  color: Color(0xFF434651),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              // Progress bar (tỷ lệ so với 12 ngày phép/năm)
              if (result.totalApprovedDays > 0) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: (result.totalApprovedDays / 12).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE8E8E8),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0F3c8f),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.totalApprovedDays}/12 ngày phép năm đã sử dụng',
                  style: const TextStyle(
                    color: Color(0x99434651),
                    fontSize: 12,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Approved leave list ──
        if (result.approvedLeaves.isNotEmpty) ...[
          const Text(
            'Chi tiết đơn đã duyệt',
            style: TextStyle(
              color: Color(0xFF0F3c8f),
              fontSize: 24,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.60,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 16),
          ...result.approvedLeaves.map((leave) {
            final start =
                '${leave.startDate.day.toString().padLeft(2, '0')}/${leave.startDate.month.toString().padLeft(2, '0')}';
            final end =
                '${leave.endDate.day.toString().padLeft(2, '0')}/${leave.endDate.month.toString().padLeft(2, '0')}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                key: Key('history_card_${leave.id}'),
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
                child: Row(
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
                            ),
                          ),
                          Text(
                            'TH${leave.startDate.month.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Color(0xFF0F3c8f),
                              fontSize: 10,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
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
                              fontSize: 16,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              height: 1.40,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${leave.totalDays} ngày ($start – $end)',
                            style: const TextStyle(
                              color: Color(0xFF434651),
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Đã duyệt',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 12,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 9,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.80,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: const TextStyle(
                  color: Color(0xFF434651),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
