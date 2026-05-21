import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/assignment_entity.dart';

class RouteListView extends ConsumerWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onAssign;
  final Function(RouteEntity)? onEdit;

  const RouteListView({Key? key, this.onAdd, this.onAssign, this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeInfoAsync = ref.watch(routeListWithInfoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: Stack(
        children: [
          // ==================== LIST CONTENT ====================
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar placeholder
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tất cả lộ trình',
                              style: TextStyle(
                                color: Color(0xFF1A1B21),
                                fontSize: 18,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_list, size: 20),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        routeInfoAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (err, _) => Center(child: Text('Lỗi: $err')),
                          data: (items) {
                            if (items.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Text('Chưa có lộ trình nào'),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 24),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    if (onEdit != null) {
                                      onEdit!(items[index].route);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(24),
                                  child: _RouteCard(info: items[index]),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================== APP BAR ====================
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xD8FAF8FF),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F1A1B21),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quản lý tuyến',
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 22,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.55,
                        ),
                      ),
                      Row(
                        children: [
                          if (onAssign != null)
                            IconButton(
                              onPressed: onAssign,
                              icon: const Icon(Icons.assignment_ind, color: Color(0xFF0D47A1)),
                              tooltip: 'Phân công tuyến',
                            ),
                          IconButton(
                            onPressed: () {
                              ref.invalidate(realtimeRoutesProvider);
                              ref.invalidate(routeListWithInfoProvider);
                            },
                            icon: const Icon(Icons.refresh, color: Color(0xFF0D47A1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==================== FAB ====================
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              onPressed: onAdd,
              backgroundColor: const Color(0xFF0D47A1),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.only(left: 48, right: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          )
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tuyến đường...',
          hintStyle: TextStyle(color: Color(0x99737783), fontSize: 16),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0x99737783)),
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteWithInfo info;

  const _RouteCard({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final route = info.route;
    final assignment = info.assignment;
    final saleUser = info.saleUser;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A1A1B21),
            blurRadius: 32,
            offset: Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.routeName,
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 18,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFF434652)),
                      const SizedBox(width: 4),
                      Text(
                        assignment != null 
                            ? '${assignment.assignedDate.day.toString().padLeft(2, '0')}/${assignment.assignedDate.month.toString().padLeft(2, '0')}/${assignment.assignedDate.year}' 
                            : 'Chưa phân công',
                        style: const TextStyle(
                          color: Color(0xFF434652),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: assignment != null ? const Color(0xFF0D47A1) : Colors.grey,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  assignment != null ? 'ASSIGNED' : 'OPEN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Assignment Info
          if (saleUser != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFD9E2FF),
                  child: Text(
                    (saleUser['full_name'] ?? 'S')[0].toUpperCase(),
                    style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  saleUser['full_name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Color(0xFF1A1B21),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            const Text(
              'Chưa phân công',
              style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          
          const SizedBox(height: 16),

          // Progress Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiến độ viếng thăm',
                    style: TextStyle(color: Color(0xFF434652), fontSize: 12),
                  ),
                  Text(
                    '${(info.progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF003178),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: info.progress,
                backgroundColor: const Color(0xFFE8E7F0),
                color: const Color(0xFF0D47A1),
                minHeight: 6,
                borderRadius: BorderRadius.circular(9999),
              ),
            ],
          ),
        ],
      ),
    );
  }
}