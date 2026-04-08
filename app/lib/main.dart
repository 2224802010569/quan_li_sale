import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'app.dart';

void main() {
  put(AppStorage()); // dùng core
  runApp(const MyApp());
}
