import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:route_store_module/entity/assignment_entity.dart';
import 'package:route_store_module/logic_uc/check_in_gps_uc.dart';
import 'package:route_store_module/view/sale/camera_visit_view.dart';

class StoreDetailView extends ConsumerStatefulWidget {
  final StoreEntity store;
  final AssignmentEntity assignment;

  const StoreDetailView({Key? key, required this.store, required this.assignment}) : super(key: key);

  @override
  ConsumerState<StoreDetailView> createState() => _StoreDetailViewState();
}

class _StoreDetailViewState extends ConsumerState<StoreDetailView> {
  bool _isLoadingGps = false;
  bool _canCheckIn = false;
  String _gpsMessage = 'Đang kiểm tra vị trí...';

  @override
  void initState() {
    super.initState();
    _checkGps();
  }

  Future<void> _checkGps() async {
    setState(() {
      _isLoadingGps = true;
    });

    final uc = ref.read(checkInGpsUcProvider);
    final pos = await uc.getCurrentLocation();
    
    if (pos == null) {
      setState(() {
        _isLoadingGps = false;
        _canCheckIn = false;
        _gpsMessage = 'Không thể lấy được GPS';
      });
      return;
    }

    final store = widget.store;
    final isWithin = uc.isWithinRadius(pos.latitude, pos.longitude, store.latitude, store.longitude);
    setState(() {
      _isLoadingGps = false;
      _canCheckIn = isWithin;
      _gpsMessage = isWithin ? 'Đang ở trong bán kính, có thể Check-in' : 'Ngoài bán kính 200m';
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      appBar: AppBar(
        title: Text(store.storeName),
        backgroundColor: const Color(0xFF001D4E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Địa chỉ: ${store.address}',
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF0D47A1)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _gpsMessage,
                          style: TextStyle(
                            color: _canCheckIn ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_isLoadingGps)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else
              ElevatedButton(
                onPressed: _canCheckIn
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraVisitView(assignment: widget.assignment),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canCheckIn ? const Color(0xFF001D4E) : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CHỤP ẢNH CHECK-IN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}