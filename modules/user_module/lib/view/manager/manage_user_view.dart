import 'package:flutter/material.dart';
import 'package:user_module/logic_uc/manage_user_uc.dart';
import 'package:user_module/view/common/profile/profile_view.dart';
import 'package:user_module/view/manager/add_user_view.dart';
import '../../input/manager_input.dart';
import '../../entity/user.dart';
import '../../input/profile_input.dart';
import 'package:core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ManagerView extends StatefulWidget {
  final ManagerInput input;
  final void Function(String userId)? onOpenProfile;
  final VoidCallback? onBack;

  const ManagerView({super.key, required this.input, this.onOpenProfile, this.onBack});

  @override
  State<ManagerView> createState() => _ManagerViewState();
}

class _ManagerViewState extends State<ManagerView> {
  final _uc = ManagerUserUC();

  List<User> users = [];
  List<User> filtered = [];

  String error = "";
  bool loading = true;
  String? deletingUserId;

  final searchCtrl = TextEditingController();
  String selectedRoleFilter = "Tất cả"; // "Tất cả", "Sale", "Manager"

  @override
  void initState() {
    super.initState();
    load();
    searchCtrl.addListener(applyFilter);
  }

  Future<void> load() async {
    if (!widget.input.canOpen()) {
      setState(() {
        error = "Không có quyền truy cập";
        loading = false;
      });
      return;
    }

    try {
      final result = await _uc.getUsers();

      if (!mounted) return;

      setState(() {
        users = result;
        filtered = result;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void applyFilter() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filtered = users.where((u) {
        final matchesQuery = u.fullName.toLowerCase().contains(q) || u.phone.contains(q);
        final matchesRole = selectedRoleFilter == "Tất cả" || 
            u.role.trim().toLowerCase() == selectedRoleFilter.trim().toLowerCase();
        return matchesQuery && matchesRole;
      }).toList();
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: Text(
          "Danh sách nhân sự",
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : error.isNotEmpty
              ? Center(
                  child: Text(
                    error,
                    style: AppTextStyles.bodyLg.copyWith(color: AppColors.error),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: load,
                  child: Stack(
                    children: [
                      // ==================== MAIN CONTENT ====================
                      Positioned.fill(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            left: AppSpacing.containerMargin,
                            right: AppSpacing.containerMargin,
                            top: AppSpacing.lg,
                            bottom: 100,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Bar
                              _buildSearchBar(),
                              const SizedBox(height: AppSpacing.xxl),

                              // Staff List
                              if (filtered.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Text(
                                      'Không có nhân viên nào phù hợp',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppSpacing.stackGap),
                                  itemBuilder: (context, index) {
                                    final u = filtered[index];
                                    final deleting = deletingUserId == u.id;
                                    return _buildStaffCard(u, deleting);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      // ==================== FAB — ADD STAFF ====================
                      Positioned(
                        left: AppSpacing.containerMargin,
                        right: AppSpacing.containerMargin,
                        bottom: 24,
                        child: _buildAddStaffButton(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: TextField(
        controller: searchCtrl,
        style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm nhân sự...',
          hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
        ),
      ),
    );
  }



  Widget _buildStaffCard(User u, bool deleting) {
    // Determine online/offline based on ID hash for demo purposes
    final isOnline = u.id.hashCode % 3 != 0; 
    final statusColor = isOnline ? AppColors.online : const Color(0xFFFBBF24); // #4ade80 vs #fbbf24

    final avatarUrl = u.avatarPath.isNotEmpty 
        ? Supabase.instance.client.storage.from('user_avatars').getPublicUrl(u.avatarPath)
        : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        children: [
          // Avatar with Status Dot
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceContainerLow,
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : 'U',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.fullName,
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: u.role.toLowerCase() == 'manager' 
                            ? AppColors.surfaceContainerHigh 
                            : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        u.role,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      u.phone,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: "Xem hồ sơ",
                onPressed: () => openProfile(u),
                icon: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
              ),
              IconButton(
                tooltip: "Xóa nhân viên",
                onPressed: deleting ? null : () => confirmDeleteUser(u),
                color: AppColors.error,
                icon: deleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.error,
                        ),
                      )
                    : const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddStaffButton() {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level3,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: openAddUser,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add_alt_1_outlined, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                "Thêm nhân viên",
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openProfile(User user) {
    if (widget.onOpenProfile != null) {
      widget.onOpenProfile!(user.id);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileView(input: ProfileInput(userId: user.id)),
      ),
    );
  }

  void openAddUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddUserView()),
    ).then((created) {
      if (created == true) {
        load();
      }
    });
  }

  Future<void> confirmDeleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Xóa nhân viên", style: AppTextStyles.headlineSm.copyWith(color: AppColors.onSurface)),
          content: Text("Bạn có chắc muốn xóa ${user.fullName} khỏi hệ thống?", style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Hủy", style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text("Xóa", style: AppTextStyles.labelLg.copyWith(color: AppColors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() => deletingUserId = user.id);

    try {
      await _uc.deleteUser(user);
      if (!mounted) return;

      setState(() {
        users = users.where((item) => item.id != user.id).toList();
        filtered = filtered.where((item) => item.id != user.id).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xóa ${user.fullName} khỏi hệ thống")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => deletingUserId = null);
      }
    }
  }
}
