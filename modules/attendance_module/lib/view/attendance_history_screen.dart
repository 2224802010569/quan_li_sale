import 'package:flutter/material.dart';
import '../../entity/attendance.dart';
import '../../entity/user.dart';
import '../../logic_uc/attendance_uc.dart';
import 'widgets/employee_info_card.dart';
import 'widgets/history_card.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

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
        // Add a dummy 'All' user at the beginning
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

      final history = await _useCase.getAttendanceHistory();

      if (mounted) {
        setState(() {
          _loggedInUser = user;
          _allUsers = users;
          
          if (_allUsers.isNotEmpty) {
            _currentUser = _allUsers.first;
          } else {
            _currentUser = null;
          }
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // Light greyish blue
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý công việc',
          style: TextStyle(
            color: Color(0xFF0F3c8f), // Navy
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter dropdown (Only hidden if explicitly NOT manager, though allUsers will be empty/single if Sale)
                    if (_loggedInUser?.role == 'Manager')
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LỌC NHÂN VIÊN',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F6FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _allUsers.isEmpty 
                                ? const SizedBox()
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<User>(
                                      isExpanded: true,
                                      value: _currentUser,
                                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                      items: _allUsers.map((user) {
                                        return DropdownMenuItem<User>(
                                          value: user,
                                          child: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        );
                                      }).toList(),
                                      onChanged: (User? newValue) async {
                                        if (newValue != null && newValue.id != _currentUser?.id) {
                                          setState(() {
                                            _currentUser = newValue;
                                            _isLoading = true;
                                          });
                                          
                                          // Reload history based on selected user
                                          try {
                                            final updatedHistory = await _useCase.getAttendanceHistory(
                                              userId: newValue.id == 'all' ? null : newValue.id
                                            );
                                            if (mounted) {
                                              setState(() {
                                                _history = updatedHistory;
                                                _isLoading = false;
                                              });
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() { _isLoading = false; });
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải lịch sử')));
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    if (_loggedInUser?.role == 'Manager')
                      const SizedBox(height: 16),
                    
                    // Employee Info (only show for a specific employee, not 'All')
                    if (_currentUser != null && _currentUser!.id != 'all') 
                      EmployeeInfoCard(user: _currentUser!)
                    else if (_currentUser != null && _currentUser!.id == 'all')
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.group, color: Color(0xFF0F3c8f), size: 40),
                            const SizedBox(width: 16),
                            const Text('Đang xem lịch sử toàn đội', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F3c8f))),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // History List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lịch sử',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F3c8f), // Navy
                          ),
                        ),
                        Text(
                          '${_history.length} bản ghi được tìm thấy',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // History Items
                    if (_history.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Text(
                            'Chưa có dữ liệu chấm công hôm nay',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
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
