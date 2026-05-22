import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/theme/theme.dart';

import '../../entity/leave_request_entity.dart';
import '../../entity/leave_status.dart';
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

/// Màn hình lịch sử đơn nghỉ phép của Sale — Marine Precision Design System.
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
                onPressed: onBack,
              )
            : null,
        title: Text(
          'Nghỉ phép',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        backgroundColor: AppColors.white,
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                AppSpacing.lg,
                AppSpacing.containerMargin,
                AppSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Stats cards ────────────────────────────────────────
                  _buildStatsRow(state),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Section header + year filter ───────────────────────
                  _buildSectionHeader(state, notifier, currentYear),
                  const SizedBox(height: AppSpacing.md),

                  // ── Status filter pills ────────────────────────────────
                  _buildStatusFilter(state, notifier),
                  const SizedBox(height: AppSpacing.md),

                  // ── List ───────────────────────────────────────────────
                  _buildBody(state),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow(MyLeaveListState state) {
    final balance = 12 - state.totalApprovedDays;

    return Column(
      children: [
        // ── Balance card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.level1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SỐ DƯ HIỆN TẠI',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
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
                      color: AppColors.primary,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'BeVietnamPro',
                      height: 1,
                    ),
                  ),
                  Text(
                    'Ngày',
                    style: AppTextStyles.headlineSm.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Số ngày còn lại trong năm ${DateTime.now().year} của bạn.',
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // FAB — Đăng ký nghỉ
                  GestureDetector(
                    onTap: onAddLeave,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.level2,
                      ),
                      child: Center(
                        child: Text(
                          'Đăng\nký\nnghỉ',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.white,
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

        // ── Mini stat cards row ──
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'TỔNG NGÀY ĐÃ NGHỈ',
                value: state.totalApprovedDays.toString().padLeft(2, '0'),
                valueColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                label: 'ĐANG CHỜ DUYỆT',
                value: state.pendingCount.toString().padLeft(2, '0'),
                valueColor: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              fontFamily: 'BeVietnamPro',
              height: 1.2,
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
        Text(
          'Chi tiết lịch sử',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Text(
                    year.toString(),
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
    final dotColors = {
      LeaveStatus.pending: const Color(0xFFF59E0B),
      LeaveStatus.approved: const Color(0xFF22C55E),
      LeaveStatus.rejected: AppColors.error,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((status) {
          final isSelected = state.filterStatus == status;
          final dotColor = status != null
              ? dotColors[status]!
              : AppColors.onSurfaceVariant;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              key: Key('status_filter_${status?.name ?? 'all'}'),
              onTap: () => notifier.setFilterStatus(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.outlineVariant, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status != null) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.white.withValues(alpha: 0.8) : dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      labels[status]!,
                      style: AppTextStyles.labelLg.copyWith(
                        color: isSelected ? AppColors.white : AppColors.onSurface,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
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

    final list = state.filtered;

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 56,
                color: AppColors.outlineVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Không có đơn nghỉ phép nào.',
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

    return Column(
      children: list.map((leave) => _buildLeaveCard(leave)).toList(),
    );
  }

  // ── Leave card ────────────────────────────────────────────────────────────────

  Widget _buildLeaveCard(LeaveRequestEntity leave) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
      child: Container(
        key: Key('leave_card_${leave.id}'),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: date box + reason/range ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date box
                Container(
                  width: 64,
                  height: 64,
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
                        _monthLabel(leave.startDate),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Title + date range
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dayRange(leave),
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Divider ──
            Divider(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
              height: 1,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Bottom row: status + chevron ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRẠNG THÁI',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(leave.status),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant,
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
    final String label;
    switch (status) {
      case LeaveStatus.approved:
        color = const Color(0xFF16a34a);
        label = status.label;
      case LeaveStatus.rejected:
        color = AppColors.error;
        label = status.label;
      case LeaveStatus.pending:
        color = const Color(0xFFF59E0B);
        label = status.label;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
