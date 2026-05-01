import 'package:flutter/material.dart';
import 'package:user_module/logic_uc/manage_user_uc.dart';
import 'package:user_module/view/common/profile/profile_view.dart';
import 'package:user_module/view/manager/add_user_view.dart';
import 'package:user_module/view/manager/widget/manager_card.dart';
import '../../input/manager_input.dart';
import '../../entity/user.dart';
import '../../input/profile_input.dart';

class ManagerView extends StatefulWidget {
  final ManagerInput input;
  final void Function(String userId)? onOpenProfile;

  const ManagerView({super.key, required this.input, this.onOpenProfile});

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

  @override
  void initState() {
    super.initState();
    load();
    searchCtrl.addListener(onSearch);
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

  void onSearch() {
    final q = searchCtrl.text.toLowerCase();

    setState(() {
      filtered = users
          .where((u) => u.fullName.toLowerCase().contains(q))
          .toList();
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: const Text("Team")),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 520 ? 16.0 : 24.0;
            final maxWidth = constraints.maxWidth >= 900
                ? 760.0
                : constraints.maxWidth;
            final listHeight = (constraints.maxHeight - 260).clamp(
              220.0,
              520.0,
            );

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : error.isNotEmpty
                      ? Center(child: Text(error))
                      : ManagerCard(
                          users: filtered,
                          onSearch: searchCtrl,
                          onTapUser: openProfile,
                          onDeleteUser: confirmDeleteUser,
                          deletingUserId: deletingUserId,
                          onAdd: openAddUser,
                          listHeight: listHeight,
                        ),
                ),
              ),
            );
          },
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
          title: const Text("Xóa nhân viên"),
          content: Text("Bạn có chắc muốn xóa ${user.fullName} khỏi Supabase?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Xóa"),
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
        SnackBar(content: Text("Đã xóa ${user.fullName} trên Supabase")),
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
