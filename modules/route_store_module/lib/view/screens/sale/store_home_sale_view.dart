import 'package:flutter/material.dart';
import '../../../entity/store_item.dart';
import '../../../output/route_store_output.dart';

class StoreHomeSaleView extends StatelessWidget {
  final StoreItem store;
  final Function(RouteStoreOutput) onOutput;

  const StoreHomeSaleView({
    super.key,
    required this.store,
    required this.onOutput,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          store.name,
          style: const TextStyle(
            color: Color(0xFF0F3C8F),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => onOutput(RouteStoreOutput(action: 'BACK')),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card thông tin
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.route, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              store.routeName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 14, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Đã check-in',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'CHỨC NĂNG',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Lên đơn hàng',
                    color: const Color(0xFF001D4E),
                    onTap: () => onOutput(RouteStoreOutput(
                      action: 'ORDER',
                      storeId: store.id,
                      storeName: store.name,
                    )),
                  ),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    icon: Icons.inventory_2_outlined,
                    label: 'Kiểm tồn kho',
                    color: const Color(0xFF0F3C8F),
                    onTap: () => onOutput(RouteStoreOutput(
                      action: 'INVENTORY',
                      storeId: store.id,
                      storeName: store.name,
                    )),
                  ),
                ],
              ),
            ),
          ),

          // Phần dưới cùng (Check-out)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: _buildActionButton(
              icon: Icons.logout,
              label: 'Check-out',
              color: Colors.red.shade700,
              onTap: () => onOutput(RouteStoreOutput(
                action: 'CHECKOUT',
                storeId: store.id,
                storeName: store.name,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
