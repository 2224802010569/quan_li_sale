import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/logic_uc/manage_route_uc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';

class CreateRouteView extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const CreateRouteView({Key? key, this.onBack}) : super(key: key);

  @override
  ConsumerState<CreateRouteView> createState() => _CreateRouteViewState();
}

class _CreateRouteViewState extends ConsumerState<CreateRouteView> {
  final _nameController = TextEditingController();
  bool _isSaving = false;

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final storage = get<AppStorage>();
      final user = storage.get<Map<String, dynamic>>('user');
      final userId = user?['id']?.toString() ?? '';
      
      // In this system, manager_id might be a string (UUID) or int. 
      // Let's check the schema again. 
      // rls_policies.sql says created_by = auth.uid()::int
      
      final uc = ref.read(manageRouteUcProvider);
      await uc.createRouteWithStores(
        _nameController.text.trim(),
        userId,
        [], // Start with no stores
      );

      if (mounted) {
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo tuyến mới thành công')),
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
        title: const Text('Tạo tuyến mới'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1B21),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tên tuyến đường',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF434652),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ví dụ: Tuyến Quận 1 - Sáng thứ 2',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const Spacer(),
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
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'TẠO TUYẾN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
