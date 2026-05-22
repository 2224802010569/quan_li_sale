import 'package:app/root/app_output.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';
import 'package:kpi_module/kpi_module.dart';
import 'package:flutter/material.dart';

class KpiRoot {
  Widget buildManagerDashboard(Function(AppOutput) onNavigate) {
    return const KpiDashboardView();
  }
}
