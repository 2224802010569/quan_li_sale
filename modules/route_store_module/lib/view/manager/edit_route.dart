import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/route_detail_entity.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'package:route_store_module/logic_uc/manage_route_uc.dart';

class EditRouteView extends ConsumerStatefulWidget {
  final RouteEntity route;
  final VoidCallback? onBack;

  const EditRouteView({Key? key, required this.route, this.onBack}) : super(key: key);

  @override
  ConsumerState<EditRouteView> createState() => _EditRouteViewState();
}

class _EditRouteViewState extends ConsumerState<EditRouteView> {
  final _routeNameController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _routeNameController.text = widget.route.routeName;
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final uc = ref.read(manageRouteUcProvider);
      await uc.updateRouteName(widget.route.id, _routeNameController.text);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật lộ trình')));
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      realtimeRouteDetailsProvider(widget.route.id),
    );
    final allStoresAsync = ref.watch(realtimeStoresProvider);
    final allRouteDetailsAsync = ref.watch(realtimeAllRouteDetailsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Chỉnh sửa Lộ trình'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'LƯU',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameInput(),
            const SizedBox(height: 32),
            const Text(
              'Danh sách cửa hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1B21),
              ),
            ),
            const SizedBox(height: 16),
            detailsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (details) {
                return allStoresAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Center(child: Text('Lỗi tải cửa hàng: $err')),
                  data: (stores) {
                    return Column(
                      children: [
                        ...details.map((d) {
                          final store = stores.firstWhere(
                            (s) => s.id == d.storeId,
                            orElse: () => StoreEntity(
                              id: d.storeId,
                              storeName: 'Cửa hàng #${d.storeId}',
                              address: 'Đã bị xóa hoặc không tìm thấy',
                              latitude: 0.0,
                              longitude: 0.0,
                              managerId: '',
                            ),
                          );
                          return _EditableStoreItem(
                            detail: d,
                            store: store,
                            onRemove: () async {
                              await ref
                                  .read(manageRouteUcProvider)
                                  .removeStoreFromRoute(
                                    widget.route.id,
                                    d.storeId,
                                  );
                              ref.invalidate(realtimeRouteDetailsProvider(widget.route.id));
                              ref.invalidate(realtimeAllRouteDetailsProvider);
                            },
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        _buildAddButton(stores, details, allRouteDetailsAsync.value ?? []),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tên lộ trình',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          TextField(
            controller: _routeNameController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Nhập tên lộ trình',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    List<StoreEntity> allStores,
    List<RouteDetailEntity> currentDetails,
    List<RouteDetailEntity> allDetails,
  ) {
    return InkWell(
      onTap: () {
        _showAddStoreDialog(allStores, currentDetails, allDetails);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFC3C6D4), width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFF434652)),
            SizedBox(width: 8),
            Text(
              'Thêm điểm dừng mới',
              style: TextStyle(
                color: Color(0xFF434652),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStoreDialog(
    List<StoreEntity> allStores,
    List<RouteDetailEntity> currentDetails,
    List<RouteDetailEntity> allDetails,
  ) {
    // Filter out stores already in ANY route
    final availableStores = allStores
        .where((s) => !allDetails.any((d) => d.storeId == s.id))
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn cửa hàng để thêm',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableStores.length,
                  itemBuilder: (context, index) {
                    final store = availableStores[index];
                    return ListTile(
                      title: Text(store.storeName),
                      subtitle: Text(store.address),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF0D47A1),
                      ),
                      onTap: () async {
                        final uc = ref.read(manageRouteUcProvider);
                        await uc.addStoreToRoute(
                          widget.route.id,
                          store.id!,
                          currentDetails.length + 1,
                        );
                        ref.invalidate(realtimeRouteDetailsProvider(widget.route.id));
                        ref.invalidate(realtimeAllRouteDetailsProvider);
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditableStoreItem extends StatelessWidget {
  final RouteDetailEntity detail;
  final StoreEntity store;
  final VoidCallback onRemove;

  const _EditableStoreItem({
    required this.detail,
    required this.store,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F3FB),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${detail.sequence}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  store.address,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
