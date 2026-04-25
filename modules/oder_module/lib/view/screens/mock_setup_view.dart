import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../input/order_input.dart';
import '../../order_module.dart';

class MockSetupView extends StatefulWidget {
  const MockSetupView({super.key});

  @override
  State<MockSetupView> createState() => _MockSetupViewState();
}

class _MockSetupViewState extends State<MockSetupView> {
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _stores = [];
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _selectedUser;
  Map<String, dynamic>? _selectedStore;
  String _selectedAction = 'CREATE';

  @override
  void initState() {
    super.initState();
    _fetchMockData();
  }

  Future<void> _fetchMockData() async {
    try {
      // 1. Kéo danh sách User (Sale & Manager)
      final usersResponse = await _supabase
          .from('users')
          .select('id, full_name, role, group_id')
          .order('full_name', ascending: true);

      // 2. Kéo danh sách Cửa hàng
      final storesResponse = await _supabase
          .from('stores')
          .select('id, store_name')
          .order('id', ascending: true);

      setState(() {
        _users = List<Map<String, dynamic>>.from(usersResponse);
        _stores = List<Map<String, dynamic>>.from(storesResponse);
        
        // Chọn sẵn giá trị đầu tiên cho tiện test
        if (_users.isNotEmpty) _selectedUser = _users.first;
        if (_stores.isNotEmpty) _selectedStore = _stores.first;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _openOrderModule() {
    if (_selectedUser == null || (_selectedUser!['role'] == 'Sale' && _selectedStore == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đủ thông tin bắt buộc')),
      );
      return;
    }

    final input = OrderInput(
      action: _selectedAction,
      role: _selectedUser!['role'],
      userId: _selectedUser!['id'],
      employeeName: _selectedUser!['full_name'],
      storeId: _selectedStore?['id'],
      storeName: _selectedStore?['store_name'],
      groupId: _selectedUser!['group_id'],
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderModule(
          input: input,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Môi trường Test (Dữ liệu thực)'),
        backgroundColor: const Color(0xFF003178),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF003178)))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn dữ liệu từ Supabase',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // 1. Dropdown Chọn Nhân viên
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedUser,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Nhân viên (Đăng nhập)',
                          border: OutlineInputBorder(),
                        ),
                        items: _users.map((user) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: user,
                            child: Text('${user['full_name']} (${user['role']})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedUser = val);
                        },
                      ),
                      const SizedBox(height: 24),

                      // 2. Dropdown Chọn Cửa hàng
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedStore,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Cửa hàng (Đang check-in)',
                          border: OutlineInputBorder(),
                        ),
                        items: _stores.map((store) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: store,
                            child: Text('[#${store['id']}] ${store['store_name']}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedStore = val);
                        },
                      ),
                      const SizedBox(height: 24),

                      // 3. Dropdown Chọn Hành động
                      DropdownButtonFormField<String>(
                        value: _selectedAction,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Hành động muốn test',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'CREATE', child: Text('Lên đơn hàng mới')),
                          DropdownMenuItem(value: 'HISTORY', child: Text('Xem lịch sử đơn hàng')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAction = val);
                        },
                      ),
                      const SizedBox(height: 48),

                      // Nút Chạy Module
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003178),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _openOrderModule,
                          child: Text(
                            _selectedAction == 'CREATE' ? 'Bắt đầu Lên đơn' : 'Xem Lịch sử',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Text(
                        '* Mẹo: Chọn Role là Sale sẽ mở luồng tạo đơn. Chọn Role là Manager sẽ tự động mở luồng xem lịch sử.',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      )
                    ],
                  ),
                ),
    );
  }
}