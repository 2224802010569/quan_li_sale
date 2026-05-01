import 'package:app/root/app_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:user_module/input/manager_input.dart';
import 'package:user_module/input/profile_input.dart';
import 'package:user_module/user_module.dart';
import 'package:user_module/output/user_event.dart';
import 'package:user_module/view/common/profile/profile_view.dart';
import 'package:user_module/view/manager/manage_user_view.dart';

class UserRoot {
  Widget build(Function(AppOutput) onNavigate) {
    return UserScreen(
      onEvent: (UserEvent event) => _handleEvent(event, onNavigate),
    );
  }

  Widget buildProfile(Function(AppOutput) onNavigate) {
    final storage = get<AppStorage>();
    final selectedUserId = storage.get<String>('profile_user_id');
    return ProfileView(
      input: ProfileInput(userId: selectedUserId),
      onLogout: () {
        onNavigate(AppOutput(toModule: 'USER'));
      },
    );
  }

  Widget buildManager(Function(AppOutput) onOutput) {
    return ManagerView(
      input: ManagerInput(),
      onOpenProfile: (userId) {
        onOutput(
          AppOutput(
            toModule: 'USER_PROFILE',
            data: {'profile_user_id': userId},
          ),
        );
      },
    );
  }

  void _handleEvent(UserEvent event, Function(AppOutput) onNavigate) {
    switch (event.type) {
      case UserEventType.loginSuccess:
        _goToTestModule(event, onNavigate);
        break;
    }
  }

  /// =========================
  /// NAVIGATION FUNCTIONS
  /// =========================
  void _goToTestModule(UserEvent event, Function(AppOutput) onNavigate) {
    onNavigate(AppOutput(toModule: 'ROUTE_STORE', data: event.data));
  }
}
