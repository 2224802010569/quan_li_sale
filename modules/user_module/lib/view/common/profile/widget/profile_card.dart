import 'package:flutter/material.dart';
import 'package:user_module/entity/user.dart';
import 'package:core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback? onChangeRole;
  final VoidCallback? onEdit;
  final VoidCallback? onLogout;
  final bool changingRole;
  final bool editingProfile;

  const ProfileCard({
    super.key,
    required this.user,
    this.onChangeRole,
    this.onEdit,
    this.onLogout,
    this.changingRole = false,
    this.editingProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarPath.isNotEmpty 
        ? Supabase.instance.client.storage.from('user_avatars').getPublicUrl(user.avatarPath)
        : user.avatarUrl.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==================== CARD 1: HEADER CARD ====================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.level1,
          ),
          child: Column(
            children: [
              Text(
                "Cá nhân",
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
        
              const SizedBox(height: AppSpacing.xxl),

              // Avatar with Edit Button Overlay
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                            style: AppTextStyles.headlineLg.copyWith(
                              color: AppColors.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  if (onEdit != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: editingProfile ? null : onEdit,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: editingProfile
                              ? const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Full Name
              Text(
                user.fullName,
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ==================== CARD 2: DETAILS CARD ====================
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.level1,
          ),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: "Số điện thoại",
                value: user.phone.isNotEmpty ? user.phone : "Chưa cập nhật",
              ),
              const Divider(color: AppColors.outlineVariant, height: 24, thickness: 1),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: "Email",
                value: user.email.isNotEmpty ? user.email : "Chưa cập nhật",
              ),
              const Divider(color: AppColors.outlineVariant, height: 24, thickness: 1),
              _buildInfoRow(
                icon: Icons.badge_outlined,
                label: "Vai trò",
                value: user.role.toUpperCase(),
              ),
              const Divider(color: AppColors.outlineVariant, height: 24, thickness: 1),
              _buildInfoRow(
                icon: Icons.groups_outlined,
                label: "Nhóm / Group ID",
                value: user.groupId.isNotEmpty ? user.groupId : "Chưa phân nhóm",
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // ==================== LOGOUT BUTTON ====================
        if (onLogout != null)
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0), // Đỏ nhạt
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                onTap: onLogout,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "ĐĂNG XUẤT",
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.secondary, size: 20),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
