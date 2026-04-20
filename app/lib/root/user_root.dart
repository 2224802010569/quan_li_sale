import 'package:app/root/app_output.dart';
import 'package:flutter/material.dart';
import 'package:user_module/user_module.dart';
import 'package:user_module/output/user_event.dart';

class UserRoot {
  Widget build(Function(AppOutput) onNavigate) {
    return UserScreen(
      onEvent: (UserEvent event) => _handleEvent(event, onNavigate)
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
    onNavigate(AppOutput(toModule: 'TEST', data: event.data));
  }

  // void _goToRouteStore(UserEvent event, Function(AppOutput) onNavigate) {
  //   onNavigate(AppOutput(toModule: 'ROUTE_STORE', data: event.data));
  // }
}
