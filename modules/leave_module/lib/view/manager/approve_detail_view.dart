import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entity/leave_request_entity.dart';
import '../../entity/leave_status.dart';
import '../../logic_data/leave_data.dart';
import '../../logic_uc/approve_leave_uc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum ApproveAction { none, approving, rejecting }

class ApproveDetailState {
  final bool isLoading;
  final ApproveAction action;
  final String? errorMessage;
  final bool isDone; // true sau khi duyệt/từ chối xong

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
    required String decision, // 'Approved' | 'Rejected'
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
      state = state.copyWith(isLoading: false, isDone: true,
          action: ApproveAction.none);
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

/// Màn hình chi tiết đơn nghỉ + nút Duyệt / Từ chối dành cho Manager.
/// Layout theo design system: dark scaffold + white card + action buttons.
class ApproveDetailView extends ConsumerWidget {
  final LeaveRequestEntity leave;

  /// Callback sau khi Manager duyệt hoặc từ chối thành công.
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

  // ── build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approveDetailNotifierProvider);
    final notifier = ref.read(approveDetailNotifierProvider.notifier);

    // Auto-pop khi done
    ref.listen<ApproveDetailState>(approveDetailNotifierProvider, (_, next) {
      if (next.isDone) {
        onDecisionSuccess?.call();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
              top: 24, left: 24, right: 24, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back + Header ────────────────────────────────────────
              _buildHeader(),
              const SizedBox(height: 32),

              // ── Leave detail card ────────────────────────────────────
              _buildDetailCard(),
              const SizedBox(height: 24),

              // ── Reason card ──────────────────────────────────────────
              _buildReasonCard(),
              const SizedBox(height: 32),

              // ── Error message ────────────────────────────────────────
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    width: double.infinity,
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
                ),

              // ── Action buttons ───────────────────────────────────────
              if (leave.status == LeaveStatus.pending)
                _buildActionButtons(state, notifier, context)
              else
                _buildAlreadyProcessed(),
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
      children: [
        
        const SizedBox(height: 4),
        const Text(
          'Chi tiết đơn\nnghỉ phép',
          style: TextStyle(
            color: Color(0xFF0F3c8f),
            fontSize: 30,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            letterSpacing: -0.75,
            height: 1.20,
          ),
        ),
      ],
    );
  }

  // ── Detail card ──────────────────────────────────────────────────────────────

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
          // Date box + title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF3F3F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${leave.startDate.day}',
                      style: const TextStyle(
                        color: Color(0xFF0F3c8f),
                        fontSize: 22,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        height: 1.20,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.reason.length > 32
                          ? '${leave.reason.substring(0, 32)}…'
                          : leave.reason,
                      style: const TextStyle(
                        color: Color(0xFF0F3c8f),
                        fontSize: 20,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dayRange(),
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
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3F3F3), thickness: 1),
          const SizedBox(height: 20),

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
            _buildInfoRow('DUYỆT BỞI',
                leave.approvedBy!.substring(0, 8).toUpperCase()),
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
          style: const TextStyle(
            color: Color(0x99434651),
            fontSize: 11,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.10,
            height: 1.50,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF0F3c8f),
            fontSize: 14,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
      ],
    );
  }

  Color _statusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return const Color(0xFF22C55E);
      case LeaveStatus.rejected:
        return const Color(0xFFEF4444);
      case LeaveStatus.pending:
        return const Color(0xFFF59E0B);
    }
  }

  // ── Reason card ───────────────────────────────────────────────────────────────

  Widget _buildReasonCard() {
    return Container(
      width: double.infinity,
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
          const Text(
            'LÝ DO CHI TIẾT',
            style: TextStyle(
              color: Color(0x99434651),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.20,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            leave.reason,
            style: const TextStyle(
              color: Color(0xFF1A1C1C),
              fontSize: 16,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
              height: 1.63,
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
        // DUYỆT button (navy gradient)
        GestureDetector(
          key: const Key('approve_button'),
          onTap: busy
              ? null
              : () async {
                  final ok = await notifier.decide(
                    leaveId: leave.id!,
                    decision: 'Approved',
                  );
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.errorMessage ?? 'Đã xảy ra lỗi.',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.20, -0.99),
                end: Alignment(0.80, 1.99),
                colors: [Color(0xFF0F3c8f), Color(0xFF003178)],
              ),
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
            child: Center(
              child: isApproving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Duyệt đơn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // TỪ CHỐI button (outlined red)
        GestureDetector(
          key: const Key('reject_button'),
          onTap: busy
              ? null
              : () async {
                  // Hiển thị confirm dialog trước khi từ chối
                  final confirmed = await _showRejectConfirm(context);
                  if (!confirmed) return;
                  await notifier.decide(
                    leaveId: leave.id!,
                    decision: 'Rejected',
                  );
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: ShapeDecoration(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: busy
                      ? const Color(0xFFEF4444).withOpacity(0.4)
                      : const Color(0xFFEF4444),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Center(
              child: isRejecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFFEF4444),
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: busy
                              ? const Color(0xFFEF4444).withOpacity(0.4)
                              : const Color(0xFFEF4444),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Từ chối',
                          style: TextStyle(
                            color: busy
                                ? const Color(0xFFEF4444).withOpacity(0.4)
                                : const Color(0xFFEF4444),
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Confirm dialog trước khi từ chối.
  Future<bool> _showRejectConfirm(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Xác nhận từ chối',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F3c8f),
              ),
            ),
            content: const Text(
              'Bạn có chắc muốn từ chối đơn nghỉ này không?',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Color(0xFF434651),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Huỷ',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF434651),
                  ),
                ),
              ),
              TextButton(
                key: const Key('confirm_reject_button'),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Từ chối',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
