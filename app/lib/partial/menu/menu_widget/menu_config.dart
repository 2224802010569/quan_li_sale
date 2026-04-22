import 'package:flutter/material.dart';

class MenuConfig {
  final String title;
  final IconData icon;
  final String module;
  final List<String> roles;

  const MenuConfig({
    required this.title,
    required this.icon,
    required this.module,
    this.roles = const [],
  });
}
