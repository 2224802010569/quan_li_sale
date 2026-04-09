import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'app.dart';

void main() {
  final storage = AppStorage();
  put<AppStorage>(storage);
  runApp(const MyApp());
}
