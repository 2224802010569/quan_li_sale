import 'package:flutter/material.dart';
import 'package:user_module/entity/user.dart';
import 'package:user_module/input/profile_input.dart';
import 'package:user_module/logic_data/session_manager.dart';
import 'package:user_module/logic_uc/change_role_uc.dart';
import 'package:user_module/logic_uc/profile_uc.dart';
import 'package:user_module/view/common/profile/widget/profile_card.dart';


class ProfileView extends StatefulWidget {
  final ProfileInput input;

  const ProfileView({super.key, required this.input});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _uc = ProfileUC();
  final _changeRoleUC = ChangeRoleUC();
  final _session = SessionManager();

  User? user;
  String error = "";
  bool loading = true;
  bool changingRole = false;

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

  bool get canChangeRole {
    final current = _session.getUser();
    final viewedUser = user;

    if (current == null || viewedUser == null) {
      return false;
    }

    return current['role'] == 'Manager' && current['id'] != viewedUser.id;
  }

  Future<void> handleChangeRole() async {
    final viewedUser = user;
    if (viewedUser == null) {
      return;
    }

    final selectedRole = await showDialog<String>(
      context: context,
      builder: (context) {
        String role = viewedUser.role == 'Manager' ? 'Sale' : 'Manager';

        return AlertDialog(
          title: const Text("Đổi vai trò"),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(
                  labelText: "Vai trò mới",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Sale', child: Text('Sale')),
                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() => role = value);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, role),
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );

    if (selectedRole == null) {
      return;
    }

    setState(() => changingRole = true);

    try {
      final updatedUser = await _changeRoleUC.execute(
        targetUserId: viewedUser.id,
        newRole: selectedRole,
      );

      if (!mounted) return;

      setState(() => user = updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Đã đổi vai trò sang ${updatedUser.role} và group ${updatedUser.groupId}",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => changingRole = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                ? Text(error)
                : ProfileCard(
                    user: user!,
                    onChangeRole: canChangeRole ? handleChangeRole : null,
                    changingRole: changingRole,
                  ),
          ),
        ),
      ),
    );
  }
}
