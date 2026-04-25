import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inventory_module/input/inventory_input.dart';
import 'package:inventory_module/inventory_module.dart';
class InventoryMockSetupView extends StatefulWidget {
  const InventoryMockSetupView({super.key});

  @override
  State<InventoryMockSetupView> createState() => _InventoryMockSetupViewState();
}

class _InventoryMockSetupViewState extends State<InventoryMockSetupView> {
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _stores = [];
  
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _selectedUser;
  Map<String, dynamic>? _selectedStore;

  @override
  void initState() {
    super.initState();
    _fetchMockData();
  }

  Future<void> _fetchMockData() async {
    try {
      // 1. Kéo danh sách User (Sale & Manager) [cite: 1332]
      final usersResponse = await _supabase
          .from('users')
          .select('id, full_name, role')
          .order('full_name', ascending: true);

      // 2. Kéo danh sách Cửa hàng [cite: 1330]
      final storesResponse = await _supabase
          .from('stores')
          .select('id, store_name')
          .order('id', ascending: true);


      setState(() {
        _users = List<Map<String, dynamic>>.from(usersResponse);
        _stores = List<Map<String, dynamic>>.from(storesResponse);
        
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

  void _openInventoryModule() {
    if (_selectedUser == null || _selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn User và Cửa hàng')),
      );
      return;
    }

    // Khởi tạo Input cho Inventory Module 
    final input = InventoryInput(
      userId: _selectedUser!['id'], // UUID từ bảng users [cite: 1332]
      storeId: _selectedStore!['id'].toString(), // ID từ bảng stores [cite: 1330]
      productIds: [1, 2, 3], // Dummy product IDs cho mock setup
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InventoryModule(
          input: input,
          onOutput: (output) {
            debugPrint('✅ Kết quả module: ${output.success}');
            Navigator.of(context).pop();
          },
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Inventory (Dữ liệu thực)'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1. Chọn Nhân viên', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      DropdownButton<Map<String, dynamic>>(
                        value: _selectedUser,
                        isExpanded: true,
                        items: _users.map((u) => DropdownMenuItem(
                          value: u, child: Text('${u['full_name']} (${u['role']})'))).toList(),
                        onChanged: (val) => setState(() => _selectedUser = val),
                      ),
                      
                      const SizedBox(height: 24),
                      const Text('2. Chọn Cửa hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      DropdownButton<Map<String, dynamic>>(
                        value: _selectedStore,
                        isExpanded: true,
                        items: _stores.map((s) => DropdownMenuItem(
                          value: s, child: Text(s['store_name']))).toList(),
                        onChanged: (val) => setState(() => _selectedStore = val),
                      ),

                      // Removed product selection because it is now handled inside the module                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _openInventoryModule,
                          child: const Text('BẮT ĐẦU KIỂM TỒN', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}