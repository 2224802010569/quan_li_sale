import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/theme/theme.dart';

import '../../entity/leave_request_entity.dart';
import '../../entity/leave_status.dart';
import '../../logic_uc/approve_leave_uc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum ApproveAction { none, approving, rejecting }

class ApproveDetailState {
  final bool isLoading;
  final ApproveAction action;
  final String? errorMessage;
  final bool isDone;

  const ApproveDetailState({
    this.isLoading = false,
    this.action = ApproveAction.none,
    this.errorMessage,
    this.isDone = false,
  });

  ApproveDetailState copyWith({
    bool? isLoading,
    ApproveAction? action,
    String? errorMessage,
    bool? isDone,
    bool clearError = false,
  }) {
    return ApproveDetailState(
      isLoading: isLoading ?? this.isLoading,
      action: action ?? this.action,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isDone: isDone ?? this.isDone,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ApproveDetailNotifier extends StateNotifier<ApproveDetailState> {
  final ApproveLeaveUc _approveUc;
  final String approverId;
  final String groupId;

  ApproveDetailNotifier({
    required ApproveLeaveUc approveUc,
    required this.approverId,
    required this.groupId,
  })  : _approveUc = approveUc,
        super(const ApproveDetailState());

  Future<bool> decide({
    required int leaveId,
    required String decision,
  }) async {
    final action =
        decision == 'Approved' ? ApproveAction.approving : ApproveAction.rejecting;

    state = state.copyWith(isLoading: true, action: action, clearError: true);
    try {
      await _approveUc(
        leaveId: leaveId,
        decision: decision,
        approverId: approverId,
        groupId: groupId,
      );
      state = state.copyWith(
          isLoading: false, isDone: true, action: ApproveAction.none);
      return true;
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
          isLoading: false, action: ApproveAction.none, errorMessage: msg);
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final approveDetailNotifierProvider = StateNotifierProvider.autoDispose<
    ApproveDetailNotifier, ApproveDetailState>(
  (ref) => throw UnimplementedError(
    'approveDetailNotifierProvider phải được override trong Leave_Module.',
  ),
);

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Màn hình chi tiết đơn nghỉ + nút Duyệt / Từ chối (Manager) — Marine Precision.
class ApproveDetailView extends ConsumerWidget {
  final LeaveRequestEntity leave;
  final VoidCallback? onDecisionSuccess;
  final VoidCallback? onBack;

  const ApproveDetailView({
    super.key,
    required this.leave,
    this.onDecisionSuccess,
    this.onBack,
  });

  // ── helpers ──────────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  String _monthLabel(DateTime dt) =>
      'TH${dt.month.toString().padLeft(2, '0')}';

  String _dayRange() {
    final start = _formatDate(leave.startDate);
    final end = _formatDate(leave.endDate);
    if (leave.totalDays == 1) return '1 ngày ($start)';
    return '${leave.totalDays} ngày ($start – $end)';
  }

  Color _statusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return const Color(0xFF16a34a);
      case LeaveStatus.rejected:
        return AppColors.error;
      case LeaveStatus.pending:
        return const Color(0xFFF59E0B);
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approveDetailNotifierProvider);
    final notifier = ref.read(approveDetailNotifierProvider.notifier);

    ref.listen<ApproveDetailState>(approveDetailNotifierProvider, (_, next) {
      if (next.isDone) {
        onDecisionSuccess?.call();
      }
    });

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
          'Chi tiết đơn nghỉ phép',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerMargin,
          AppSpacing.lg,
          AppSpacing.containerMargin,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Leave detail card ──────────────────────────────────────────
            _buildDetailCard(),
            const SizedBox(height: AppSpacing.lg),

            // ── Reason card ────────────────────────────────────────────────
            _buildReasonCard(),
            const SizedBox(height: AppSpacing.xxl),

            // ── Error message ──────────────────────────────────────────────
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  width: double.infinity,
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
              ),

            // ── Action buttons ─────────────────────────────────────────────
            if (leave.status == LeaveStatus.pending)
              _buildActionButtons(state, notifier, context)
            else
              _buildAlreadyProcessed(),
          ],
        ),
      ),
    );
  }

  // ── Detail card ──────────────────────────────────────────────────────────────

  Widget _buildDetailCard() {
    return Container(
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
          // Date box + reason row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
                      leave.userName ?? 'Nhân viên',
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.reason.length > 32
                          ? '${leave.reason.substring(0, 32)}…'
                          : leave.reason,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dayRange(),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Info rows
          _buildInfoRow('NGÀY BẮT ĐẦU', _formatDate(leave.startDate)),
          const SizedBox(height: 12),
          _buildInfoRow('NGÀY KẾT THÚC', _formatDate(leave.endDate)),
          const SizedBox(height: 12),
          _buildInfoRow('SỐ NGÀY NGHỈ', '${leave.totalDays} ngày'),
          const SizedBox(height: 12),
          _buildInfoRow(
            'TRẠNG THÁI',
            leave.status.label,
            valueColor: _statusColor(leave.status),
          ),
          if (leave.approvedBy != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'DUYỆT BỞI',
              leave.approvedBy!.substring(0, 8).toUpperCase(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            color: valueColor ?? AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Reason card ───────────────────────────────────────────────────────────────

  Widget _buildReasonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LÝ DO CHI TIẾT',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            leave.reason,
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────────

  Widget _buildActionButtons(
    ApproveDetailState state,
    ApproveDetailNotifier notifier,
    BuildContext context,
  ) {
    final isApproving = state.action == ApproveAction.approving;
    final isRejecting = state.action == ApproveAction.rejecting;
    final busy = state.isLoading;

    return Column(
      children: [
        // DUYỆT button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Material(
            color: busy ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: InkWell(
              key: const Key('approve_button'),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              onTap: busy
                  ? null
                  : () async {
                      final ok = await notifier.decide(
                        leaveId: leave.id,
                        decision: 'Approved',
                      );
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.errorMessage ?? 'Đã xảy ra lỗi.',
                              style: AppTextStyles.bodyMd
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radius),
                            ),
                            margin: const EdgeInsets.all(
                                AppSpacing.containerMargin),
                          ),
                        );
                      }
                    },
              child: Center(
                child: isApproving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              color: AppColors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Duyệt đơn',
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // TỪ CHỐI button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            key: const Key('reject_button'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: busy
                    ? AppColors.error.withValues(alpha: 0.4)
                    : AppColors.error,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            onPressed: busy
                ? null
                : () async {
                    final confirmed = await _showRejectConfirm(context);
                    if (!confirmed) return;
                    await notifier.decide(
                      leaveId: leave.id,
                      decision: 'Rejected',
                    );
                  },
            child: isRejecting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.error,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: busy
                            ? AppColors.error.withValues(alpha: 0.4)
                            : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Từ chối',
                        style: AppTextStyles.labelLg.copyWith(
                          color: busy
                              ? AppColors.error.withValues(alpha: 0.4)
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<bool> _showRejectConfirm(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            title: Text(
              'Xác nhận từ chối',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Bạn có chắc muốn từ chối đơn nghỉ này không?',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Huỷ',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                key: const Key('confirm_reject_button'),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Từ chối',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ── Already processed banner ──────────────────────────────────────────────────

  Widget _buildAlreadyProcessed() {
    final color = _statusColor(leave.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            'Đơn này đã được xử lý: ${leave.status.label}',
            style: AppTextStyles.bodyMd.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
