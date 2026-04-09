import 'package:flutter/material.dart';
import 'package:user_module/output/login_output.dart';
import 'package:user_module/user_module.dart';

class UserRoot {
  static Widget openLogin(Function(LoginOutput) onOutput) {
    return UserScreen(onOutput: onOutput, view: '');
  }
}
