import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/theme/theme.dart';

import '../../logic_uc/submit_leave_uc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// State của form đăng ký nghỉ phép.
class LeaveFormState {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;
  final String? errorMessage;

  const LeaveFormState({
    this.startDate,
    this.endDate,
    this.isLoading = false,
    this.errorMessage,
  });

  LeaveFormState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LeaveFormState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier quản lý state của LeaveFormView.
class LeaveFormNotifier extends StateNotifier<LeaveFormState> {
  final SubmitLeaveUc _submitLeaveUc;
  final String userId;

  LeaveFormNotifier({
    required SubmitLeaveUc submitLeaveUc,
    required this.userId,
  })  : _submitLeaveUc = submitLeaveUc,
        super(const LeaveFormState());

  void setStartDate(DateTime date) =>
      state = state.copyWith(startDate: date, clearError: true);

  void setEndDate(DateTime date) =>
      state = state.copyWith(endDate: date, clearError: true);

  /// Gọi use-case submit, trả về `true` nếu thành công.
  Future<bool> submit(String reason) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _submitLeaveUc(
        userId: userId,
        startDate: state.startDate!,
        endDate: state.endDate!,
        reason: reason,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Cần truyền userId + SupabaseClient từ ngoài vào trước khi dùng.
/// Trong Leave_Module.dart sẽ override provider này với đúng instance.
final leaveFormNotifierProvider =
    StateNotifierProvider.autoDispose<LeaveFormNotifier, LeaveFormState>(
  (ref) => throw UnimplementedError(
    'leaveFormNotifierProvider phải được override trong Leave_Module.',
  ),
);

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

/// Màn hình đăng ký nghỉ phép dành cho Sale.
/// Layout 1-1 theo Figma (UI.txt): header + white form card + info card.
class LeaveFormView extends ConsumerStatefulWidget {
  final VoidCallback? onSubmitSuccess;
  final VoidCallback? onBack;

  const LeaveFormView({
    super.key,
    this.onSubmitSuccess,
    this.onBack,
  });

  @override
  ConsumerState<LeaveFormView> createState() => _LeaveFormViewState();
}

class _LeaveFormViewState extends ConsumerState<LeaveFormView> {
  final _reasonController = TextEditingController();
  final _reasonFocusNode = FocusNode();

  @override
  void dispose() {
    _reasonController.dispose();
    _reasonFocusNode.dispose();
    super.dispose();
  }

  // ---- helpers ---------------------------------------------------------------

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'mm/dd/yyyy';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  Future<void> _pickDateRange() async {
    final formState = ref.read(leaveFormNotifierProvider);
    final now = DateTime.now();
    final initial = DateTimeRange(
      start: formState.startDate ?? now,
      end: formState.endDate ?? now.add(const Duration(days: 1)),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange: initial,
      locale: const Locale('vi', 'VN'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.onSurface,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      ref.read(leaveFormNotifierProvider.notifier).setStartDate(picked.start);
      ref.read(leaveFormNotifierProvider.notifier).setEndDate(picked.end);
    }
  }

  Future<void> _handleSubmit() async {
    _reasonFocusNode.unfocus();

    final reason = _reasonController.text;
    final formState = ref.read(leaveFormNotifierProvider);

    // Basic UI-level guard trước khi gọi UC
    if (formState.startDate == null || formState.endDate == null) {
      _showSnackbar('Vui lòng chọn ngày bắt đầu và kết thúc.', isError: true);
      return;
    }

    final success =
        await ref.read(leaveFormNotifierProvider.notifier).submit(reason);

    if (!mounted) return;

    if (success) {
      _reasonController.clear();
      _showSnackbar('Đơn nghỉ phép đã được gửi thành công! 🎉');
      widget.onSubmitSuccess?.call();
    } else {
      final msg = ref.read(leaveFormNotifierProvider).errorMessage ??
          'Đã xảy ra lỗi. Vui lòng thử lại.';
      _showSnackbar(msg, isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? AppColors.error : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radius)),
        margin: const EdgeInsets.all(AppSpacing.containerMargin),
      ),
    );
  }

  // ---- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(leaveFormNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          'Đăng ký nghỉ phép',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
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
                      'Đang chờ',
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerMargin,
            AppSpacing.lg,
            AppSpacing.containerMargin,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Form Card ─────────────────────────────────────────────
              _buildFormCard(formState),
              const SizedBox(height: AppSpacing.xxl),

              // ── Info + Days Remaining row ─────────────────────────────
              _buildBottomRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Form Card ────────────────────────────────────────────────────────────────


  Widget _buildFormCard(LeaveFormState state) {
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
          // LÝ DO NGHỈ
          _buildSectionLabel('LÝ DO NGHỈ'),
          const SizedBox(height: 8),
          _buildReasonField(),
          const SizedBox(height: 24),

          // NGÀY BẮT ĐẦU
          _buildSectionLabel('NGÀY BẮT ĐẦU'),
          const SizedBox(height: 8),
          _buildDateField(
            id: 'start_date_field',
            value: _formatDate(state.startDate),
            onTap: _pickDateRange,
          ),
          const SizedBox(height: 16),

          // NGÀY KẾT THÚC
          _buildSectionLabel('NGÀY KẾT THÚC'),
          const SizedBox(height: 8),
          _buildDateField(
            id: 'end_date_field',
            value: _formatDate(state.endDate),
            onTap: _pickDateRange,
          ),
          const SizedBox(height: 32),

          // Submit button
          _buildSubmitButton(state),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLg.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.20,
      ),
    );
  }

  Widget _buildReasonField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: TextField(
        key: const Key('reason_text_field'),
        controller: _reasonController,
        focusNode: _reasonFocusNode,
        maxLines: 4,
        style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Nhập lý do chi tiết...',
          hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String id,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key(id),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(LeaveFormState state) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: state.isLoading ? null : _handleSubmit,
          child: Center(
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Gửi đơn',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Row (info card + days remaining) ──────────────────────────────────

  Widget _buildBottomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info card
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quy định nghỉ phép',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bộ phận Kinh doanh (Sale) cần đăng ký trước ít nhất 48h để sắp xếp bàn giao khách hàng.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.inversePrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.open_in_new_rounded, color: AppColors.white, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chi tiết chính sách nhân sự 2024',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Days remaining card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '12',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'NGÀY PHÉP\nCÒN LẠI',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
