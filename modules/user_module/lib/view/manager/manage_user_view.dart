import 'package:flutter/material.dart';
import 'package:user_module/logic_uc/manage_user_uc.dart';
import 'package:user_module/view/common/profile/profile_view.dart';
import 'package:user_module/view/manager/widget/manager_card.dart';
import '../../input/manager_input.dart';
import '../../entity/user.dart';
import '../../input/profile_input.dart';

class ManagerView extends StatefulWidget {
  final ManagerInput input;
  final void Function(String userId)? onOpenProfile;

  const ManagerView({
    super.key,
    required this.input,
    this.onOpenProfile,
  });

  @override
  State<ManagerView> createState() => _ManagerViewState();
}

class _ManagerViewState extends State<ManagerView> {
  final _uc = ManagerUserUC();

  List<User> users = [];
  List<User> filtered = [];

  String error = "";
  bool loading = true;

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                ? Center(child: Text(error))
                : ManagerCard(
                    users: filtered,
                    onSearch: searchCtrl,
                    onTapUser: openProfile,
                    onAdd: openAddUser,
                  ),
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
  }
}
