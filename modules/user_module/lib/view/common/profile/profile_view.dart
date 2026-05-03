import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_module/entity/user.dart';
import 'package:user_module/input/profile_input.dart';
import 'package:user_module/logic_data/session_manager.dart';
import 'package:user_module/logic_uc/logout_uc.dart';
import 'package:user_module/logic_uc/profile_uc.dart';
import 'package:user_module/view/common/profile/widget/profile_card.dart';

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
              title: const Text("Chỉnh sửa thông tin"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFE8EEF8),
                      backgroundImage: selectedAvatarBytes != null
                          ? MemoryImage(selectedAvatarBytes!)
                          : viewedUser.avatarUrl.isNotEmpty
                          ? NetworkImage(viewedUser.avatarUrl)
                          : null,
                      child:
                          selectedAvatarBytes == null &&
                              viewedUser.avatarUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Color(0xFF001D4E),
                              size: 36,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: pickAvatar,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text("Chọn ảnh đại diện"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: fullNameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Họ tên",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Lưu"),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
                padding: EdgeInsets.all(horizontalPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : error.isNotEmpty
                      ? Text(error)
                      : ProfileCard(
                          user: user!,
                          onChangeRole: null,
                          onEdit: isOwnProfile ? handleEditProfile : null,
                          editingProfile: savingProfile,
                          onLogout: isOwnProfile ? handleLogout : null,
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
