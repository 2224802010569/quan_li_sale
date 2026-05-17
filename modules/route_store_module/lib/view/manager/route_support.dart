import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'package:route_store_module/logic_uc/manage_route_uc.dart';

class RouteSupportView extends ConsumerStatefulWidget {
  final RouteEntity route;
  final String absentUserName;

  const RouteSupportView({
    Key? key,
    required this.route,
    required this.absentUserName,
  }) : super(key: key);

  @override
  ConsumerState<RouteSupportView> createState() => _RouteSupportViewState();
}

class _RouteSupportViewState extends ConsumerState<RouteSupportView> {
  final Set<int> _selectedStoreIds = {};

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      realtimeRouteDetailsProvider(widget.route.id),
    );
    final storesAsync = ref.watch(realtimeStoresProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        title: const Text('Gán hỗ trợ'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D47A1),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildWarningBanner(),
          _buildSelectionHeader(detailsAsync.value?.length ?? 0),
          Expanded(
            child: detailsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (details) {
                return storesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Center(child: Text('Lỗi tải cửa hàng: $err')),
                  data: (allStores) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final detail = details[index];
                        final store = allStores.firstWhere(
                          (s) => s.id == detail.storeId,
                        );
                        final isSelected = _selectedStoreIds.contains(
                          store.id!,
                        );

                        return _SupportStoreItem(
                          storeName: store.storeName,
                          address: store.address,
                          isSelected: isSelected,
                          onToggle: () {
                            setState(() {
                              if (isSelected) {
                                _selectedStoreIds.remove(store.id!);
                              } else {
                                _selectedStoreIds.add(store.id!);
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFF93000A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nhân viên ${widget.absentUserName} vắng mặt. Vui lòng chọn cửa hàng để gán hỗ trợ.',
              style: const TextStyle(
                color: Color(0xFF93000A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chọn cửa hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('$total Cửa hàng', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F1A1B21),
            blurRadius: 32,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _selectedStoreIds.isEmpty ? null : () => _showAssignDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'TIẾP TỤC CHỌN NHÂN VIÊN',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _showAssignDialog() {
    // Navigate to a user selection screen or show dialog
    // For now, I'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang gán ${_selectedStoreIds.length} cửa hàng...'),
      ),
    );
  }
}

class _SupportStoreItem extends StatelessWidget {
  final String storeName;
  final String address;
  final bool isSelected;
  final VoidCallback onToggle;

  const _SupportStoreItem({
    required this.storeName,
    required this.address,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD9E2FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D47A1) : Colors.transparent,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? const Color(0xFF0D47A1) : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    address,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
