import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/theme/theme.dart';

import '../../logic_data/leave_data.dart';
import '../../logic_uc/leave_history_uc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class LeaveHistoryViewState {
  final List<Map<String, dynamic>> employees;
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

  Future<void> _loadEmployees() async {
    try {
      final list = await _leaveData.getUsersInGroup(groupId);
      state = state.copyWith(employees: list);
    } catch (_) {}
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

class LeaveHistoryView extends ConsumerWidget {
  final VoidCallback? onBack;

  const LeaveHistoryView({super.key, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaveHistoryViewNotifierProvider);
    final notifier = ref.read(leaveHistoryViewNotifierProvider.notifier);
    final currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: Text(
          'Báo cáo nghỉ phép nhân viên',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerMargin,
            AppSpacing.md,
            AppSpacing.containerMargin,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.xxl),
              _buildSelectors(state, notifier, currentYear),
              const SizedBox(height: AppSpacing.xxl),
              _buildBody(state),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Text(
      'Chọn nhân viên và năm để xem thống kê',
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
    );
  }

  // ── Selectors ──────────────────────────────────────────────────────────────

  Widget _buildSelectors(
    LeaveHistoryViewState state,
    LeaveHistoryViewNotifier notifier,
    int currentYear,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Employee dropdown label
        Text(
          'NHÂN VIÊN',
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Employee dropdown container
        Container(
          key: const Key('employee_dropdown'),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedEmployeeId,
              hint: Text(
                'Chọn nhân viên...',
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              ),
              isExpanded: true,
              dropdownColor: AppColors.white,
              style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
              items: state.employees.map((e) {
                final id = e['id'] as String;
                final name = e['name'] as String? ?? id.substring(0, 8);
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(name, style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) notifier.selectEmployee(v);
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Year selector label
        Text(
          'NĂM',
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Year pill tabs
        Row(
          children: [currentYear, currentYear - 1, currentYear - 2].map((year) {
            final isSelected = state.selectedYear == year;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                key: Key('year_tab_$year'),
                onTap: () => notifier.selectYear(year),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: isSelected ? null : Border.all(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Text(
                    '$year',
                    style: AppTextStyles.labelLg.copyWith(
                      color: isSelected ? AppColors.white : AppColors.onSurface,
                      fontWeight: FontWeight.w700,
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

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(LeaveHistoryViewState state) {
    if (state.selectedEmployeeId == null) {
      return _buildEmptyPrompt();
    }

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    if (state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Text(
            state.errorMessage!,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
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
          children: [
            const Icon(Icons.person_search_outlined, size: 56, color: AppColors.outlineVariant),
            const SizedBox(height: 12),
            Text(
              'Chọn nhân viên để xem\nthống kê nghỉ phép.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Results ────────────────────────────────────────────────────────────────

  Widget _buildResults(LeaveHistoryResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Stats Row (3 columns) ──
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'NGÀY ĐÃ NGHỈ',
                value: '${result.totalApprovedDays}',
                unit: 'ngày',
                valueColor: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                label: 'ĐANG CHỜ',
                value: '${result.pendingCount}',
                unit: 'đơn',
                valueColor: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                label: 'TỪ CHỐI',
                value: '${result.rejectedCount}',
                unit: 'đơn',
                valueColor: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Total days card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.level1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'TỔNG NGÀY NGHỈ ĐƯỢC DUYỆT',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circle chart
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CustomPaint(
                      painter: _CircleProgressPainter(
                        progress: (result.totalApprovedDays / 12).clamp(0.0, 1.0),
                      ),
                      child: Center(
                        child: Text(
                          '${result.totalApprovedDays}',
                          style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right side text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngày',
                        style: AppTextStyles.headlineMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Năm ${result.year} • ${result.approvedCount} đơn đã duyệt',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Approved leave list ──
        if (result.approvedLeaves.isNotEmpty) ...[
          Text(
            'Chi tiết đơn đã duyệt',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...result.approvedLeaves.map((leave) {
            final start =
                '${leave.startDate.day.toString().padLeft(2, '0')}/${leave.startDate.month.toString().padLeft(2, '0')}';
            final end =
                '${leave.endDate.day.toString().padLeft(2, '0')}/${leave.endDate.month.toString().padLeft(2, '0')}';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
              child: Container(
                key: Key('history_card_${leave.id}'),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: AppShadows.level1,
                ),
                child: Row(
                  children: [
                    // Date box
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${leave.startDate.day}',
                            style: AppTextStyles.headlineSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'TH${leave.startDate.month.toString().padLeft(2, '0')}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Reason + duration
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leave.reason.length > 30
                                ? '${leave.reason.substring(0, 30)}…'
                                : leave.reason,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${leave.totalDays} ngày ($start – $end)',
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFdcfce7),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        'Đã duyệt',
                        style: AppTextStyles.labelMd.copyWith(
                          color: const Color(0xFF16a34a),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headlineSm.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            unit,
            style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circle Progress Painter
// ---------------------------------------------------------------------------

class _CircleProgressPainter extends CustomPainter {
  final double progress;

  const _CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;
    const strokeWidth = 6.0;

    final trackPaint = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Track
    canvas.drawCircle(center, radius, trackPaint);

    // Fill
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) => oldDelegate.progress != progress;
}
