import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic_data/leave_data.dart';
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
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0F3c8f),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1A1C1C),
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
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ---- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(leaveFormNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                _buildHeader(formState),
                const SizedBox(height: 32),

                // ── Form Card ─────────────────────────────────────────────
                _buildFormCard(formState),
                const SizedBox(height: 32),

                // ── Info + Days Remaining row ─────────────────────────────
                _buildBottomRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(LeaveFormState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title block
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const SizedBox(height: 4),
            const Text(
              'Đăng ký\nnghỉ phép',
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
        ),

        // Status badge (pending)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: const Color(0xFFE8E8E8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Đang\nchờ',
                style: TextStyle(
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
    );
  }

  // ── Form Card ────────────────────────────────────────────────────────────────

  Widget _buildFormCard(LeaveFormState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, left: 32, right: 32, bottom: 48),
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
          // LÝ DO NGHỈ
          _buildSectionLabel('LÝ DO NGHỈ'),
          const SizedBox(height: 8),
          _buildReasonField(),
          const SizedBox(height: 32),

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
      style: const TextStyle(
        color: Color(0xFF434651),
        fontSize: 12,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        letterSpacing: 1.20,
        height: 1.33,
      ),
    );
  }

  Widget _buildReasonField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFE8E8E8),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: TextField(
        key: const Key('reason_text_field'),
        controller: _reasonController,
        focusNode: _reasonFocusNode,
        maxLines: 4,
        style: const TextStyle(
          color: Color(0xFF1A1C1C),
          fontSize: 16,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
        decoration: const InputDecoration(
          hintText: 'Nhập lý do chi tiết...',
          hintStyle: TextStyle(
            color: Color(0x7F747782),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
          ),
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
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFE8E8E8),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1C1C),
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF434651),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(LeaveFormState state) {
    return GestureDetector(
      onTap: state.isLoading ? null : _handleSubmit,
      child: Container(
        key: const Key('submit_leave_button'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
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
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Gửi đơn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
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
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: const Color(0xFF003178),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quy định nghỉ phép',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.56,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Bộ phận Kinh doanh (Sale) cần đăng ký trước ít nhất 48h để sắp xếp bàn giao khách hàng.',
                  style: TextStyle(
                    color: Color(0xFF7C9CE9),
                    fontSize: 14,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    height: 1.63,
                  ),
                ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: 0.80,
                  child: Row(
                    children: const [
                      Icon(Icons.open_in_new, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chi tiết chính sách nhân sự 2024',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            height: 1.33,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Days remaining card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: const Color(0xFFF3F3F3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                '12',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F3c8f),
                  fontSize: 36,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w900,
                  height: 1.11,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'NGÀY PHÉP\nCÒN LẠI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF434651),
                  fontSize: 10,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
