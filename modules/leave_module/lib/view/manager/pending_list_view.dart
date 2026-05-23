import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/theme/theme.dart';

import '../../entity/leave_request_entity.dart';
import '../../entity/leave_status.dart';
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

/// Màn hình danh sách đơn nghỉ phép đang chờ duyệt (Manager) — Marine Precision.
class PendingListView extends ConsumerWidget {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.onSurface, size: 20),
                onPressed: onBack,
              )
            : null,
        title: Text(
          'Duyệt đơn nghỉ phép',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          if (!state.isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.pendingCount} đơn chờ',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
                  _buildBody(state),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────────

  Widget _buildBody(PendingListState state) {
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

    if (state.leaves.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 56),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFdcfce7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    size: 36, color: Color(0xFF16a34a)),
              ),
              const SizedBox(height: 16),
              Text(
                'Không có đơn nào cần duyệt.',
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label + count badge
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đang chờ duyệt',
                style: AppTextStyles.headlineSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${state.pendingCount}',
                  style: AppTextStyles.labelLg.copyWith(
                    color: const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...state.leaves.map((leave) => _buildPendingCard(leave)),
      ],
    );
  }

  // ── Pending card ──────────────────────────────────────────────────────────────

  Widget _buildPendingCard(LeaveRequestEntity leave) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
      child: GestureDetector(
        key: Key('pending_card_${leave.id}'),
        onTap: () => onTapLeave?.call(leave),
        child: Container(
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
              // Top row: date box + reason/range
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.reason.length > 28
                              ? '${leave.reason.substring(0, 28)}…'
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

              Divider(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                height: 1,
              ),
              const SizedBox(height: AppSpacing.md),

              // Bottom row: status + employee chip + chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status
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
                      Row(
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
                          const SizedBox(width: 6),
                          Text(
                            'Đang chờ',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w700,
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
                        constraints: const BoxConstraints(maxWidth: 120),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          leave.userName ?? (leave.userId.length > 8
                              ? '#${leave.userId.substring(0, 8)}'
                              : '#${leave.userId}'),
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chevron
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
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
            ],
          ),
        ),
      ),
    );
  }
}
