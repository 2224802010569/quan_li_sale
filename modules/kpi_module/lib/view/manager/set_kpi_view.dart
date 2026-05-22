import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kpi_module/logic_uc/manage_kpi_uc.dart';
import 'package:kpi_module/logic_data/kpi_data.dart';
import 'package:intl/intl.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';

class SetKpiView extends ConsumerStatefulWidget {
  const SetKpiView({Key? key}) : super(key: key);

  @override
  ConsumerState<SetKpiView> createState() => _SetKpiViewState();
}

class _SetKpiViewState extends ConsumerState<SetKpiView> {
  final _targetRevenueController = TextEditingController();
  String? _selectedUserId;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> _salesUsers = [];
  bool _isLoading = true; // Khởi tạo bằng true để an toàn trong initState

  @override
  void initState() {
    super.initState();
    print('DEBUG: SetKpiView initState called');
    _loadUsers();
  }

  @override
  void dispose() {
    _targetRevenueController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    print('DEBUG: _loadUsers started');
    try {
      final userStorage = get<AppStorage>().get<Map<String, dynamic>>('user');
      final managerId = userStorage?['id']?.toString() ?? '';
      print('DEBUG: managerId = $managerId');
      
      final users = await ref.read(kpiDataProvider).getSaleUsersByManager(managerId);
      print('DEBUG: fetched users count = ${users.length}');
      
      if (!mounted) return;
      setState(() {
        // Lọc các user có ID hợp lệ và loại bỏ trùng lặp để tránh crash DropdownButton
        final uniqueUsers = <String, Map<String, dynamic>>{};
        for (var u in users) {
          final id = u['id']?.toString();
          if (id != null && id.isNotEmpty) {
            uniqueUsers[id] = u;
          }
        }
        _salesUsers = uniqueUsers.values.toList();
        print('DEBUG: unique sales users = ${_salesUsers.length}');
        
        if (_salesUsers.isNotEmpty) {
          _selectedUserId = _salesUsers.first['id'].toString();
        } else {
          _selectedUserId = null;
        }
      });
    } catch (e, stacktrace) {
      print('DEBUG: ERROR in _loadUsers: $e\n$stacktrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách: $e')));
      }
    } finally {
      print('DEBUG: _loadUsers finally block');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitKpi() async {
    if (_selectedUserId == null || _targetRevenueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin')));
      return;
    }

    final targetStr = _targetRevenueController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final target = double.tryParse(targetStr);
    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doanh số mục tiêu không hợp lệ')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(manageKpiUcProvider).assignKpi(_selectedUserId!, _selectedMonth, _selectedYear, target);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thiết lập KPI thành công')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi thiết lập: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: SetKpiView build called. isLoading: $_isLoading, salesUsers.length: ${_salesUsers.length}');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF001D4E)),
      ),
      body: _isLoading && _salesUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildTrendAnalysis(),
                    const SizedBox(height: 24),
                    _buildManagerNote(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thiết lập chỉ tiêu',
          style: TextStyle(
            color: Color(0xFF001D4E),
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.20,
            letterSpacing: -0.75,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Phân bổ mục tiêu kinh doanh cho đội ngũ nhân sự. Dữ liệu sẽ được đồng bộ hóa với hệ thống báo cáo hiệu suất thời gian thực.',
          style: TextStyle(
            color: Color(0xFF434651),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.63,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140D47A1),
            blurRadius: 24,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF001D4E),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Thông tin nhân viên & Thời gian',
                style: TextStyle(
                  color: Color(0xFF001D4E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildLabel('NHÂN VIÊN'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(16), // Rounded slightly for better look
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedUserId,
                hint: const Text('Chọn nhân viên', style: TextStyle(color: Color(0xFF94A3B8))),
                items: _salesUsers.map((user) {
                  return DropdownMenuItem<String>(
                    value: user['id'].toString(),
                    child: Text(user['full_name']?.toString() ?? 'Chưa cập nhật tên'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedUserId = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel('THÁNG/NĂM'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedMonth,
                      items: List.generate(12, (index) => index + 1).map((m) {
                        return DropdownMenuItem<int>(
                          value: m,
                          child: Text('Tháng $m'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedMonth = val!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedYear,
                      items: [DateTime.now().year, DateTime.now().year + 1].map((y) {
                        return DropdownMenuItem<int>(
                          value: y,
                          child: Text('Năm $y'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedYear = val!),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('DOANH SỐ MỤC TIÊU'),
          const SizedBox(height: 8),
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetRevenueController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onChanged: (val) {
                      // Formatting raw input with commas
                      final rawNum = val.replaceAll(RegExp(r'[^0-9]'), '');
                      if (rawNum.isNotEmpty) {
                        final formatted = NumberFormat.decimalPattern('vi_VN').format(int.parse(rawNum));
                        _targetRevenueController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'VND',
                  style: TextStyle(
                    color: Color(0xFF434651),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          InkWell(
            onTap: _isLoading ? null : _submitKpi,
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF001D4E), Color(0xFF003178)],
                ),
                borderRadius: BorderRadius.circular(9999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Lưu chỉ tiêu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF434651),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.20,
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PHÂN TÍCH XU HƯỚNG',
            style: TextStyle(
              color: Color(0xFF001D4E),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.40,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 174,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.60,
                    child: Container(
                      color: const Color(0xFF001D4E), // Thay Image.network bằng màu trơn để chống treo
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xCCF3F3F3), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 32,
                  child: const Text(
                    'Hiệu suất trung bình tháng trước',
                    style: TextStyle(
                      color: Color(0xFF001D4E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 0,
                  child: const Text(
                    '+12.5%',
                    style: TextStyle(
                      color: Color(0xFF001D4E),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatBox('Tỷ lệ hoàn thành trung bình', '94%'),
          const SizedBox(height: 16),
          _buildStatBox('Nhân sự tích cực', '24/28'),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Color(0xFF1A1C1C), size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1C1C),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF001D4E),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF001D4E),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 25,
            offset: Offset(0, 20),
          )
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -32,
            top: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lưu ý Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chỉ tiêu cần được thảo luận và thống nhất trước khi chính thức phê duyệt trên hệ thống. Nhân viên sẽ nhận được thông báo qua ứng dụng ngay sau khi "Lưu chỉ tiêu".',
                style: TextStyle(
                  color: const Color(0xFF7C9CE9),
                  fontSize: 14,
                  height: 1.63,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
