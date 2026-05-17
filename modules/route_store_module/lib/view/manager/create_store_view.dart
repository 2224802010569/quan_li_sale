import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:route_store_module/logic_uc/manage_store_uc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';

class CreateStoreView extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final StoreEntity? store;
  const CreateStoreView({Key? key, this.onBack, this.store}) : super(key: key);

  @override
  ConsumerState<CreateStoreView> createState() => _CreateStoreViewState();
}

class _CreateStoreViewState extends ConsumerState<CreateStoreView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store?.storeName ?? '');
    _addressController = TextEditingController(text: widget.store?.address ?? '');
    _latController = TextEditingController(text: widget.store?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: widget.store?.longitude.toString() ?? '');
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final storage = get<AppStorage>();
      final user = storage.get<Map<String, dynamic>>('user');
      final managerId = user?['id']?.toString() ?? '';
      
      final store = StoreEntity(
        id: widget.store?.id,
        storeName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        latitude: double.tryParse(_latController.text) ?? 0.0,
        longitude: double.tryParse(_lngController.text) ?? 0.0,
        managerId: managerId,
      );

      final uc = ref.read(manageStoreUcProvider);
      if (widget.store != null) {
        await uc.updateStore(widget.store!.id!, store);
      } else {
        await uc.addStore(store);
      }

      if (mounted) {
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.store != null ? 'Đã cập nhật cửa hàng thành công' : 'Đã tạo cửa hàng mới thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        title: Text(widget.store != null ? 'Chỉnh sửa cửa hàng' : 'Thêm cửa hàng mới'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1B21),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Tên cửa hàng'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Ví dụ: Tạp hóa Lan Anh',
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên cửa hàng' : null,
              ),
              const SizedBox(height: 20),
              
              _buildLabel('Địa chỉ'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _addressController,
                hint: 'Số nhà, tên đường, quận/huyện...',
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Vĩ độ (Lat)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _latController,
                          hint: '10.7626',
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Lỗi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kinh độ (Long)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _lngController,
                          hint: '106.6602',
                          keyboardType: TextInputType.number,
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Lỗi' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF0D47A1).withValues(alpha: 0.4),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'LƯU CỬA HÀNG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF434652),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}