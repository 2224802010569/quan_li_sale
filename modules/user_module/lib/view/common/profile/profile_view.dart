import 'package:flutter/material.dart';
import 'package:user_module/entity/user.dart';
import 'package:user_module/input/profile_input.dart';
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

  User? user;
  String error = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
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
                : ProfileCard(user: user!),
          ),
        ),
      ),
    );
  }
}
