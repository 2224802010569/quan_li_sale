import 'package:kpi_module/entity/kpi_setting_entity.dart';

class KpiReportEntity {
  final String userId;
  final String userName;
  final int month;
  final int year;
  final double targetRevenue;
  final double actualRevenue;
  final List<Map<String, dynamic>> orders;
  final List<String> proofImageUrls;
  final String avatarUrl;

  KpiReportEntity({
    required this.userId,
    required this.userName,
    required this.month,
    required this.year,
    required this.targetRevenue,
    required this.actualRevenue,
    required this.orders,
    required this.proofImageUrls,
    this.avatarUrl = '',
  });

  double get percentCompleted {
    if (targetRevenue <= 0) return 0.0;
    return (actualRevenue / targetRevenue) * 100;
  }
}
