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
import 'package:core/theme/theme.dart';

final routeSearchQueryProvider = StateProvider<String>((ref) => '');

class RouteListView extends ConsumerWidget {
  final VoidCallback? onAdd;
  final Function(RouteEntity)? onEdit;
  final Function(RouteEntity)? onView;
  final VoidCallback? onBack;

  const RouteListView({super.key, this.onAdd, this.onEdit, this.onView, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = get<AppStorage>();
    final currentUser = storage.get<Map<String, dynamic>>('user');
    final currentUserId = currentUser?['id']?.toString() ?? '';

    final routeInfoAsync = ref.watch(routeListWithInfoProvider);
    final searchQuery = ref.watch(routeSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: Text(
          'Quản lý tuyến',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () async {
          ref.invalidate(realtimeRoutesProvider);
          ref.invalidate(realtimeSaleUsersProvider);
          ref.invalidate(routeListWithInfoProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerMargin,
            AppSpacing.lg,
            AppSpacing.containerMargin,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(ref),
              const SizedBox(height: AppSpacing.lg),

              // Filter row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tất cả lộ trình',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list_rounded,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              routeInfoAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(color: AppColors.secondary),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Lỗi: $err',
                    style: AppTextStyles.bodyLg.copyWith(color: AppColors.error),
                  ),
                ),
                data: (items) {
                  var myRoutes = items.where((item) => item.route.createdBy == currentUserId).toList();

                  if (searchQuery.trim().isNotEmpty) {
                    final query = searchQuery.trim().toLowerCase();
                    myRoutes = myRoutes.where((item) => item.route.routeName.toLowerCase().contains(query)).toList();
                  }

                  if (myRoutes.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    children: [
                      ...myRoutes.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RouteCard(
                            info: entry.value,
                            onView: onView,
                            onEdit: onEdit,
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 52,
        height: 52,
        margin: const EdgeInsets.only(bottom: 16, right: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: AppShadows.level3,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            onTap: onAdd,
            child: const Icon(Icons.add_rounded, color: AppColors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: TextField(
        onChanged: (value) => ref.read(routeSearchQueryProvider.notifier).state = value,
        style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tuyến đường...',
          hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alt_route_rounded, size: 40, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'Chưa có lộ trình nào',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Nhấn nút + bên dưới để tạo lộ trình mới',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends ConsumerWidget {
  final RouteWithInfo info;
  final Function(RouteEntity)? onView;
  final Function(RouteEntity)? onEdit;

  const _RouteCard({required this.info, this.onView, this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = info.route;
    final assignment = info.assignment;
    final saleUser = info.saleUser;
    final isAssigned = assignment != null;

    return GestureDetector(
      onTap: () {
        if (onView != null) {
          onView!(route);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RouteDetailView(route: route)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: Route name + Badge + Delete ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    route.routeName,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isAssigned ? AppColors.surfaceContainer : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    isAssigned ? 'ASSIGNED' : 'OPEN',
                    style: AppTextStyles.labelMd.copyWith(
                      color: isAssigned ? AppColors.secondary : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
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

            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.outlineVariant, height: 1),
            const SizedBox(height: AppSpacing.md),

            // ── Agent row ──
            if (saleUser != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Text(
                      (saleUser['full_name'] ?? 'S')[0].toUpperCase(),
                      style: AppTextStyles.labelLg.copyWith(color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        saleUser['full_name'] ?? 'Unknown',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Nhân viên kinh doanh',
                        style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Chưa phân công',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // ── Progress bar ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiến độ viếng thăm',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                Text(
                  '${(info.progress * 100).toInt()}%',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: info.progress,
                backgroundColor: AppColors.surfaceContainerHigh,
                color: AppColors.secondary,
                minHeight: 6,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Action buttons ──
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: onEdit != null ? () => onEdit!(route) : null,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: Text('Sửa', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        side: const BorderSide(color: AppColors.outlineVariant, width: 1),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAssignmentBottomSheet(context, ref, info),
                      icon: const Icon(Icons.person_add_outlined, size: 14),
                      label: Text('Phân công', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
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

  void _showAssignmentBottomSheet(BuildContext context, WidgetRef ref, RouteWithInfo info) {
    ref.invalidate(realtimeSaleUsersProvider);

    final storage = get<AppStorage>();
    final currentUser = storage.get<Map<String, dynamic>>('user');
    final managerGroupId =
        currentUser?['group_id'] ?? currentUser?['groupId'] ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      backgroundColor: AppColors.white,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phân công Nhân viên',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tuyến: ${info.route.routeName}',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.lg),
                Flexible(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final usersAsync = ref.watch(realtimeSaleUsersProvider);
                      return usersAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(color: AppColors.secondary),
                          ),
                        ),
                        error: (err, _) => Center(
                          child: Text('Lỗi: $err', style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
                        ),
                        data: (users) {
                          final filteredUsers = users.where((u) {
                            final userGroupId =
                                (u['group_id'] ?? u['groupId'] ?? '')
                                    .toString();
                            final mGroupId = managerGroupId.toString();
                            return userGroupId == mGroupId;
                          }).toList();

                          if (filteredUsers.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'Không tìm thấy nhân viên Sale nào thuộc nhóm của bạn',
                                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                                  textAlign: TextAlign.center,
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
                              final fullName = user['full_name']?.toString() ?? 'Nhân viên';
                              final employeeCode = user['employee_code']?.toString() ?? '';
                              final isCurrent = info.assignment?.userId == userId;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isCurrent ? AppColors.surfaceContainerLow : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                  border: Border.all(
                                    color: isCurrent ? AppColors.secondary : AppColors.outlineVariant,
                                    width: isCurrent ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isCurrent ? AppColors.secondary : AppColors.surfaceContainerHigh,
                                    child: Text(
                                      fullName[0].toUpperCase(),
                                      style: AppTextStyles.labelLg.copyWith(
                                        color: isCurrent ? AppColors.white : AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    fullName,
                                    style: AppTextStyles.bodyLg.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isCurrent ? AppColors.secondary : AppColors.onSurface,
                                    ),
                                  ),
                                  subtitle: employeeCode.isNotEmpty
                                      ? Text(
                                          'Mã NV: $employeeCode',
                                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                                        )
                                      : null,
                                  trailing: isCurrent
                                      ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary)
                                      : const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                                  onTap: () async {
                                    final assignmentData = ref.read(assignmentDataProvider);

                                    final newAssignment = AssignmentEntity(
                                      assignmentId:
                                          info.assignment?.assignmentId ?? 0,
                                      userId: userId,
                                      routeId: info.route.id,
                                      isSupport: 1,
                                      assignedDate: DateTime.now(),
                                    );

                                    try {
                                      await assignmentData.upsertAssignment(newAssignment);

                                      ref.invalidate(realtimeAllAssignmentsProvider);
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
