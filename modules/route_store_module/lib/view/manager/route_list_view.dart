import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'package:route_store_module/logic_data/assignment_data.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/assignment_entity.dart';
import 'package:route_store_module/view/manager/route_detail_view.dart';
import 'package:route_store_module/view/manager/delete_route_confirm.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';

final routeSearchQueryProvider = StateProvider<String>((ref) => '');

class RouteListView extends ConsumerWidget {
  final VoidCallback? onAdd;
  final Function(RouteEntity)? onEdit;
  final Function(RouteEntity)? onView;

  const RouteListView({Key? key, this.onAdd, this.onEdit, this.onView})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = get<AppStorage>();
    final currentUser = storage.get<Map<String, dynamic>>('user');
    final currentUserId = currentUser?['id']?.toString() ?? '';

    final routeInfoAsync = ref.watch(routeListWithInfoProvider);
    final searchQuery = ref.watch(routeSearchQueryProvider);

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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(realtimeRoutesProvider);
                      ref.invalidate(realtimeAllAssignmentsProvider);
                      ref.invalidate(routeListWithInfoProvider);
                      // Đợi 1 chút để UI kịp rebuild với dữ liệu mới
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar placeholder
                          _buildSearchBar(ref),
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
                              // Chỉ lọc hiển thị các tuyến do Manager hiện tại tạo
                              var myRoutes = items
                                  .where(
                                    (item) =>
                                        item.route.createdBy == currentUserId,
                                  )
                                  .toList();

                              if (searchQuery.trim().isNotEmpty) {
                                final query = searchQuery.trim().toLowerCase();
                                myRoutes = myRoutes
                                    .where(
                                      (item) => item.route.routeName
                                          .toLowerCase()
                                          .contains(query),
                                    )
                                    .toList();
                              }

                              if (myRoutes.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 40),
                                    child: Text('Chưa có lộ trình nào.'),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: myRoutes.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  return _RouteCard(
                                    info: myRoutes[index],
                                    onView: onView,
                                    onEdit: onEdit,
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
                  ),
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
                      IconButton(
                        onPressed: () {
                          ref.invalidate(realtimeRoutesProvider);
                          ref.invalidate(realtimeSaleUsersProvider);
                          ref.invalidate(routeListWithInfoProvider);
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFF0D47A1),
                        ),
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

  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.only(left: 48, right: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => ref.read(routeSearchQueryProvider.notifier).state = value,
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm tuyến đường...',
          hintStyle: TextStyle(color: Color(0x99737783), fontSize: 16),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0x99737783)),
        ),
      ),
    );
  }
}

class _RouteCard extends ConsumerWidget {
  final RouteWithInfo info;
  final Function(RouteEntity)? onView;
  final Function(RouteEntity)? onEdit;

  const _RouteCard({Key? key, required this.info, this.onView, this.onEdit})
    : super(key: key);

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Không có dữ liệu';
    final days = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật',
    ];
    final dayStr = days[dt.weekday - 1];
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final hourStr = hour12.toString().padLeft(2, '0');
    return '$dayStr, $hourStr:$minute $ampm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = info.route;
    final assignment = info.assignment;
    final saleUser = info.saleUser;

    return GestureDetector(
      onTap: () {
        if (onView != null) {
          onView!(route);
        } else {
          // Fallback: push RouteDetailView nội bộ
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RouteDetailView(route: route)),
          );
        }
      },
      child: Container(
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
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Header
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
                          color: Color(0xFF0D47A1),
                          fontSize: 18,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF434652),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(route.createdAt),
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
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: assignment != null
                            ? (assignment.isSupport == 2
                                ? const Color(0xFFBA1A1A) // Màu đỏ cho SUPPORT
                                : const Color(0xFF0D47A1))
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        assignment != null
                            ? (assignment.isSupport == 2 ? 'SUPPORT' : 'ASSIGNED')
                            : 'OPEN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFBA1A1A),
                        size: 20,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        final deleted = await showDialog<bool>(
                          context: context,
                          builder: (_) => DeleteConfirmationDialog(
                            routeId: route.id,
                            routeName: route.routeName,
                          ),
                        );
                        if (deleted == true) {
                          ref.invalidate(realtimeRoutesProvider);
                          ref.invalidate(routeListWithInfoProvider);
                        }
                      },
                    ),
                  ],
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
                      style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 12,
                      ),
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
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 16),

            // Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tiến độ hoàn thành',
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

            // ==================== ACTION BUTTONS ====================
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF0F0F8)),
            const SizedBox(height: 12),
            Row(
              children: [
                // Chỉnh sửa / gán cửa hàng
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit != null ? () => onEdit!(route) : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D47A1),
                      side: const BorderSide(color: Color(0xFF0D47A1)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 14),
                        SizedBox(width: 4),
                        Text('Sửa', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Phân công tuyến cho nhân viên trực tiếp
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _showAssignmentBottomSheet(context, ref, info),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_ind, size: 14),
                        SizedBox(width: 4),
                        Text('Phân công', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignmentBottomSheet(
    BuildContext context,
    WidgetRef ref,
    RouteWithInfo info,
  ) {
    // Invalidate để đảm bảo nhân viên mới thêm được cập nhật ngay lập tức
    ref.invalidate(realtimeSaleUsersProvider);

    final storage = get<AppStorage>();
    final currentUser = storage.get<Map<String, dynamic>>('user');
    final managerGroupId =
        currentUser?['group_id'] ?? currentUser?['groupId'] ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phân công Nhân viên',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1B21),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  'Chọn nhân viên phụ trách tuyến: ${info.route.routeName}',
                  style: const TextStyle(
                    color: Color(0xFF434652),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final usersAsync = ref.watch(realtimeSaleUsersProvider);
                      return usersAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, _) => Center(child: Text('Lỗi: $err')),
                        data: (users) {
                          // Lọc danh sách nhân viên Sale có cùng group_id với Manager
                          final filteredUsers = users.where((u) {
                            final userGroupId =
                                (u['group_id'] ?? u['groupId'] ?? '')
                                    .toString();
                            final mGroupId = managerGroupId.toString();
                            return userGroupId == mGroupId;
                          }).toList();

                          if (filteredUsers.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  'Không tìm thấy nhân viên Sale nào thuộc nhóm của bạn',
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final userId = user['id']?.toString() ?? '';
                              final fullName =
                                  user['full_name']?.toString() ?? 'Nhân viên';
                              final employeeCode =
                                  user['employee_code']?.toString() ?? '';

                              final isCurrent =
                                  info.assignment?.userId == userId;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? const Color(0xFFF0F4FF)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCurrent
                                        ? const Color(0xFF0D47A1)
                                        : const Color(0xFFE2E8F0),
                                    width: isCurrent ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isCurrent
                                        ? const Color(0xFF0D47A1)
                                        : const Color(0xFFE2E8F0),
                                    child: Text(
                                      fullName[0].toUpperCase(),
                                      style: TextStyle(
                                        color: isCurrent
                                            ? Colors.white
                                            : const Color(0xFF434652),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    fullName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent
                                          ? const Color(0xFF0D47A1)
                                          : const Color(0xFF1A1B21),
                                    ),
                                  ),
                                  subtitle: employeeCode.isNotEmpty
                                      ? Text('Mã NV: $employeeCode')
                                      : null,
                                  trailing: isCurrent
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF0D47A1),
                                        )
                                      : const Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF434652),
                                        ),
                                  onTap: () async {
                                    final assignmentData = ref.read(
                                      assignmentDataProvider,
                                    );

                                    final newAssignment = AssignmentEntity(
                                      assignmentId:
                                          info.assignment?.assignmentId ?? 0,
                                      userId: userId,
                                      routeId: info.route.id,
                                      isSupport: 1,
                                      assignedDate: DateTime.now(),
                                    );

                                    try {
                                      await assignmentData.upsertAssignment(
                                        newAssignment,
                                      );

                                      ref.invalidate(
                                        realtimeAllAssignmentsProvider,
                                      );
                                      ref.invalidate(routeListWithInfoProvider);

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đã gán tuyến cho $fullName thành công',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Lỗi: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
