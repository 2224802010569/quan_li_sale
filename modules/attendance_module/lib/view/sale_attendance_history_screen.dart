import 'package:flutter/material.dart';
import '../../entity/attendance.dart';
import '../../entity/user.dart';
import '../../logic_uc/attendance_uc.dart';
import 'widgets/employee_info_card.dart';
import 'widgets/history_card.dart';

class SaleAttendanceHistoryScreen extends StatefulWidget {
  const SaleAttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SaleAttendanceHistoryScreen> createState() => _SaleAttendanceHistoryScreenState();
}

class _SaleAttendanceHistoryScreenState extends State<SaleAttendanceHistoryScreen> {
  final AttendanceUseCase _useCase = AttendanceUseCase();
  User? _currentUser;
  List<Attendance> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _useCase.getCurrentUser();
      // Ensure we explicitly fetch the history for the sale user
      final history = await _useCase.getAttendanceHistory(userId: user.id);

      if (mounted) {
        setState(() {
          _currentUser = user;
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
          'Lịch sử chấm công',
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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Info
                    if (_currentUser != null) EmployeeInfoCard(user: _currentUser!),
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
                          '${_history.length} bản ghi hôm nay',
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
