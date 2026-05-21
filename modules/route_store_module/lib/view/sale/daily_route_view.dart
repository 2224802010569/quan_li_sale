import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/assignment_entity.dart';

class DailyRouteView extends ConsumerWidget {
  const DailyRouteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final assignmentsAsync = ref.watch(realtimeUserAssignmentsProvider(userId));
    final routesAsync = ref.watch(realtimeRoutesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: assignmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Lỗi: $err')),
          data: (assignments) {
            return routesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi tải tuyến: $err')),
              data: (routes) {
                // Filter routes that are assigned to the user for TODAY
                final todayStr = DateTime.now().toIso8601String().split('T')[0];
                final todayAssignments = assignments.where((a) => a.assignedDate.toIso8601String().split('T')[0] == todayStr).toList();
                
                final assignedRoutes = routes
                    .where((r) => todayAssignments.any((a) => a.routeId == r.id))
                    .toList();

                if (assignedRoutes.isEmpty) {
                  return _buildEmptyState();
                }

                // Assume the first one is the active one for simplicity in this mockup
                final activeRoute = assignedRoutes.first;
                final otherRoutes = assignedRoutes.skip(1).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildActiveRouteCard(activeRoute),
                      const SizedBox(height: 32),
                      if (otherRoutes.isNotEmpty) ...[
                        const Text(
                          'Lộ trình khác & Hỗ trợ',
                          style: TextStyle(
                            color: Color(0xFF1A1B21),
                            fontSize: 18,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...otherRoutes
                            .map((r) => _buildOtherRouteCard(r))
                            .toList(),
                      ],
                      const SizedBox(height: 32),
                      _buildPerformanceStats(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Hôm nay bạn không có lịch trình nào',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chào buổi sáng,',
              style: TextStyle(color: Color(0xFF434652), fontSize: 14),
            ),
            const Text(
              'Lộ trình hôm nay',
              style: TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const CircleAvatar(
          backgroundColor: Color(0xFFD9E2FF),
          child: Icon(Icons.person, color: Color(0xFF0D47A1)),
        ),
      ],
    );
  }

  Widget _buildActiveRouteCard(RouteEntity route) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: const [
          BoxShadow(
            color: Color(0x0F1A1B21),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.routeName,
                      style: const TextStyle(
                        color: Color(0xFF1A1B21),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      '[4/10] Cửa hàng đã hoàn thành',
                      style: TextStyle(color: Color(0xFF434652), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D47A1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const LinearProgressIndicator(
            value: 0.4,
            backgroundColor: Color(0xFFF3F3FB),
            color: Color(0xFF0D47A1),
            minHeight: 12,
            borderRadius: BorderRadius.all(Radius.circular(9999)),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Còn lại: 1h 20p',
                style: TextStyle(color: Color(0xFF434652), fontSize: 13),
              ),
              Text(
                '5.2 km',
                style: TextStyle(color: Color(0xFF434652), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherRouteCard(RouteEntity route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3FB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBCD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.support, color: Color(0xFF853100)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.routeName,
                  style: const TextStyle(
                    color: Color(0xFF1A1B21),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'SUPPORT',
                  style: TextStyle(
                    color: Color(0xFF853100),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B21),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'HIỆU SUẤT', value: '85%'),
          _StatItem(label: 'ĐƠN HÀNG', value: '12'),
          _StatItem(label: 'DOANH THU', value: '4.5M'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
