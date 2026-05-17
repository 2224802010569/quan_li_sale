import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/logic_uc/manage_route_uc.dart';

class DeleteConfirmationDialog extends ConsumerWidget {
  final int routeId;
  final String routeName;

  const DeleteConfirmationDialog({
    Key? key,
    required this.routeId,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x261A1B21),
              blurRadius: 32,
              offset: Offset(0, 12),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFDAD6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A), size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Xóa tuyến đường?',
              style: TextStyle(
                color: Color(0xFF1A1B21),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Tất cả dữ liệu lịch trình và phân công của tuyến '),
                  TextSpan(
                    text: routeName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1B21)),
                  ),
                  const TextSpan(text: ' sẽ bị ẩn. Bạn có chắc chắn?'),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF434652), fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await ref.read(manageRouteUcProvider).hideRoute(routeId);
                if (context.mounted) Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA1A1A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('XÓA TUYẾN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('HỦY', style: TextStyle(color: Color(0xFF434652), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}