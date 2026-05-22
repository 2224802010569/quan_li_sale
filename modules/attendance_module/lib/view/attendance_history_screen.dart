import 'package:flutter/material.dart';
import '../../entity/attendance.dart';
import '../../entity/user.dart';
import '../../logic_uc/attendance_uc.dart';
import 'widgets/employee_info_card.dart';
import 'widgets/history_card.dart';
import 'package:core/theme/theme.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final VoidCallback onBack;
  const AttendanceHistoryScreen({super.key, required this.onBack});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final AttendanceUseCase _useCase = AttendanceUseCase();
  User? _currentUser;
  List<User> _allUsers = [];
  List<Attendance> _history = [];
  bool _isLoading = true;
  User? _loggedInUser;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _useCase.getCurrentUser();

      List<User> users = [];
      if (user.role == 'Manager' && user.groupId != null) {
        users = await _useCase.getUsersByGroup(user.groupId!, user.id);
        final allRecord = User(
          id: 'all',
          name: 'Tất cả nhân viên',
          employeeCode: 'N/A',
          currentRoute: 'N/A',
          isEnoughWorkingDays: false,
          lastUpdated: '',
          role: 'Manager',
          groupId: user.groupId,
        );
        users.insert(0, allRecord);
      } else {
        users = [user];
      }

      final history = await _useCase.getAttendanceHistory(month: _selectedMonth);

      if (mounted) {
        setState(() {
          _loggedInUser = user;
          _allUsers = users;
          _currentUser = _allUsers.isNotEmpty ? _allUsers.first : null;
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _reloadHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final selectedUserId =
          (_currentUser == null || _currentUser!.id == 'all') ? null : _currentUser!.id;
      final history = await _useCase.getAttendanceHistory(
        userId: selectedUserId,
        month: _selectedMonth,
      );
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải lịch sử: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildMonthFilterRow() {
    final currentMonth = DateTime.now();
    final months = [
      DateTime(currentMonth.year, currentMonth.month, 1),
      DateTime(currentMonth.year, currentMonth.month - 1, 1),
      DateTime(currentMonth.year, currentMonth.month - 2, 1),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: months.map((m) {
          final isSelected = _selectedMonth.year == m.year && _selectedMonth.month == m.month;
          final title = m.year == currentMonth.year && m.month == currentMonth.month
              ? 'Tháng hiện tại'
              : 'Tháng ${m.month}/${m.year}';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedMonth = m);
                _reloadHistory();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: isSelected ? null : Border.all(color: AppColors.outlineVariant, width: 1),
                ),
                child: Text(
                  title,
                  style: AppTextStyles.labelLg.copyWith(
                    color: isSelected ? AppColors.white : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Quản lý công việc',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : RefreshIndicator(
              color: AppColors.secondary,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Filter Dropdown (Manager only) ──
                    if (_loggedInUser?.role == 'Manager') ...[
                      Text(
                        'LỌC NHÂN VIÊN',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.outlineVariant, width: 1),
                        ),
                        child: _allUsers.isEmpty
                            ? const SizedBox()
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<User>(
                                  isExpanded: true,
                                  value: _currentUser,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
                                  dropdownColor: AppColors.white,
                                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                                  items: _allUsers.map((user) {
                                    return DropdownMenuItem<User>(
                                      value: user,
                                      child: Text(user.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500)),
                                    );
                                  }).toList(),
                                  onChanged: (User? newValue) async {
                                    if (newValue != null && newValue.id != _currentUser?.id) {
                                      setState(() {
                                        _currentUser = newValue;
                                        _isLoading = true;
                                      });
                                      try {
                                        final updatedHistory = await _useCase.getAttendanceHistory(
                                          userId: newValue.id == 'all' ? null : newValue.id,
                                          month: _selectedMonth,
                                        );
                                        if (mounted) {
                                          setState(() {
                                            _history = updatedHistory;
                                            _isLoading = false;
                                          });
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          setState(() => _isLoading = false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Lỗi tải lịch sử')),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // ── Month Period Filter Chips ──
                    _buildMonthFilterRow(),
                    const SizedBox(height: AppSpacing.lg),



                    // ── History List Header ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lịch sử',
                          style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_history.length} bản ghi',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── History Items ──
                    if (_history.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              const Icon(Icons.history_rounded, size: 48, color: AppColors.outlineVariant),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có dữ liệu chấm công',
                                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return HistoryCard(attendance: _history[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
