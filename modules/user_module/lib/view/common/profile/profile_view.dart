import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_module/entity/user.dart';
import 'package:user_module/input/profile_input.dart';
import 'package:user_module/logic_data/session_manager.dart';
import 'package:user_module/logic_uc/logout_uc.dart';
import 'package:user_module/logic_uc/profile_uc.dart';
import 'package:user_module/view/common/profile/widget/profile_card.dart';
import 'package:core/theme/theme.dart';

class ProfileView extends StatefulWidget {
  final ProfileInput input;
  final VoidCallback? onLogout;

  const ProfileView({super.key, required this.input, this.onLogout});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _uc = ProfileUC();
  final _session = SessionManager();
  final _logoutUC = LogoutUC();

  User? user;
  String error = "";
  bool loading = true;
  bool savingProfile = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = "";
    });

    if (!widget.input.canOpen()) {
      setState(() {
        error = "Không có quyền truy cập";
        loading = false;
      });
      return;
    }

    try {
      final result = await _uc.execute(userId: widget.input.userId);

      if (!mounted) return;

      setState(() {
        user = result;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  bool get isOwnProfile {
    final current = _session.getUser();
    final viewedUser = user;

    if (current == null || viewedUser == null) {
      return false;
    }

    return current['id'] == viewedUser.id;
  }

  Future<void> handleEditProfile() async {
    final viewedUser = user;
    if (viewedUser == null || !isOwnProfile) {
      return;
    }

    final fullNameCtrl = TextEditingController(text: viewedUser.fullName);
    final emailCtrl = TextEditingController(text: viewedUser.email);
    final phoneCtrl = TextEditingController(text: viewedUser.phone);
    Uint8List? selectedAvatarBytes;
    String? selectedAvatarName;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickAvatar() async {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (picked == null) return;

              final bytes = await picked.readAsBytes();
              setModalState(() {
                selectedAvatarBytes = bytes;
                selectedAvatarName = picked.name;
              });
            }

            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              title: Text(
                "Chỉnh sửa thông tin",
                style: AppTextStyles.headlineSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.surfaceContainerLow,
                          backgroundImage: selectedAvatarBytes != null
                              ? MemoryImage(selectedAvatarBytes!)
                              : viewedUser.avatarUrl.isNotEmpty
                              ? NetworkImage(viewedUser.avatarUrl)
                              : null,
                          child: selectedAvatarBytes == null &&
                                  viewedUser.avatarUrl.isEmpty
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 36,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: pickAvatar,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_camera_rounded,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    TextField(
                      controller: fullNameCtrl,
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: "Họ tên",
                        labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: "Số điện thoại",
                        labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "Hủy",
                    style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                  ),
                  child: Text(
                    "Lưu",
                    style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true) {
      fullNameCtrl.dispose();
      emailCtrl.dispose();
      phoneCtrl.dispose();
      return;
    }

    setState(() => savingProfile = true);

    try {
      final updatedUser = await _uc.updateCurrentUser(
        fullName: fullNameCtrl.text,
        email: emailCtrl.text,
        phone: phoneCtrl.text,
        avatarBytes: selectedAvatarBytes,
        avatarFileName: selectedAvatarName,
      );

      if (!mounted) return;

      setState(() => user = updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã cập nhật thông tin cá nhân")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      fullNameCtrl.dispose();
      emailCtrl.dispose();
      phoneCtrl.dispose();

      if (mounted) {
        setState(() => savingProfile = false);
      }
    }
  }

  void handleLogout() {
    _logoutUC.execute();

    if (widget.onLogout != null) {
      widget.onLogout!();
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 520 ? 16.0 : 24.0;
            final maxWidth = constraints.maxWidth >= 900
                ? 640.0
                : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.xxl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (canPop) ...[
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.onSurface,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              isOwnProfile ? "Hồ sơ cá nhân" : "Chi tiết nhân sự",
                              style: AppTextStyles.headlineMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                      loading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 80),
                                child: CircularProgressIndicator(color: AppColors.secondary),
                              ),
                            )
                          : error.isNotEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 80),
                                    child: Text(
                                      error,
                                      style: AppTextStyles.bodyLg.copyWith(color: AppColors.error),
                                    ),
                                  ),
                                )
                              : ProfileCard(
                                  user: user!,
                                  onChangeRole: null,
                                  onEdit: isOwnProfile ? handleEditProfile : null,
                                  editingProfile: savingProfile,
                                  onLogout: isOwnProfile ? handleLogout : null,
                                ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
