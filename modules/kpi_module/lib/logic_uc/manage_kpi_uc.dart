import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kpi_module/entity/kpi_report_entity.dart';
import 'package:kpi_module/entity/kpi_setting_entity.dart';
import 'package:kpi_module/logic_data/kpi_data.dart';
import 'package:core/di/injector.dart';
import 'package:core/storage/app_storage.dart';

final manageKpiUcProvider = Provider<ManageKpiUc>((ref) {
  return ManageKpiUc(ref.read(kpiDataProvider));
});

class ManageKpiUc {
  final KpiData _data;

  ManageKpiUc(this._data);

  // Giao KPI cho 1 nhân viên
  Future<void> assignKpi(String userId, int month, int year, double targetRevenue) async {
    final setting = KpiSettingEntity(
      userId: userId,
      month: month,
      year: year,
      targetRevenue: targetRevenue,
    );
    await _data.upsertKpiSetting(setting);
  }

  // Lấy chi tiết báo cáo KPI của 1 nhân viên
  Future<KpiReportEntity> fetchKpiReport(String userId, String userName, int month, int year) async {
    // 1. Lấy chỉ tiêu
    final setting = await _data.getKpiSetting(userId, month, year);
    final targetRevenue = setting?.targetRevenue ?? 0.0;

    // 2. Lấy đơn hàng thực tế
    final orders = await _data.getCompletedOrders(userId, month, year);
    
    // Tính tổng doanh số
    double actualRevenue = 0.0;
    List<String> proofImageUrls = [];

    for (var order in orders) {
      actualRevenue += (order['total_amount'] ?? 0).toDouble();
      
      // Lấy ảnh đơn hàng
      final orderImg = order['order_image'] as String?;
      if (orderImg != null && orderImg.isNotEmpty) {
        // orderImg có thể đã là URL đầy đủ hoặc chỉ là path. Giả sử là URL hoặc path
        if (orderImg.startsWith('http')) {
          proofImageUrls.add(orderImg);
        } else {
          // Thường Supabase trả về url nếu dùng .getPublicUrl()
          proofImageUrls.add(orderImg);
        }
      }
    }

    // 3. Lấy ảnh check-in
    final checkinPhotos = await _data.getAttendancePhotoUrls(userId, month, year);
    proofImageUrls.addAll(checkinPhotos);

    return KpiReportEntity(
      userId: userId,
      userName: userName,
      month: month,
      year: year,
      targetRevenue: targetRevenue,
      actualRevenue: actualRevenue,
      orders: orders,
      proofImageUrls: proofImageUrls,
    );
  }

  // Lấy Dashboard cho tất cả nhân viên (dành cho Manager)
  Future<List<KpiReportEntity>> fetchDashboardKpis(int month, int year) async {
    final userStorage = get<AppStorage>().get<Map<String, dynamic>>('user');
    final managerId = userStorage?['id']?.toString() ?? '';

    if (managerId.isEmpty) {
      return [];
    }

    final users = await _data.getSaleUsersByManager(managerId);
    final settings = await _data.getAllKpiSettings(month, year);
    
    List<KpiReportEntity> dashboard = [];

    for (var user in users) {
      final userId = user['id'] as String;
      final userName = user['full_name'] as String? ?? 'Chưa cập nhật tên';

      // Tìm setting của user này
      final setting = settings.where((s) => s.userId == userId).firstOrNull;
      final targetRevenue = setting?.targetRevenue ?? 0.0;

      // Lấy orders
      final orders = await _data.getCompletedOrders(userId, month, year);
      double actualRevenue = 0.0;
      for (var order in orders) {
        actualRevenue += (order['total_amount'] ?? 0).toDouble();
      }

      // Lấy avatar
      final avatarPath = user['avatar_path'] as String? ?? user['avatarPath'] as String? ?? '';
      final avatarUrl = _data.getUserAvatarUrl(avatarPath);

      dashboard.add(KpiReportEntity(
        userId: userId,
        userName: userName,
        month: month,
        year: year,
        targetRevenue: targetRevenue,
        actualRevenue: actualRevenue,
        orders: orders, // Truyền danh sách orders vào để lấy ảnh
        proofImageUrls: [], // Có thể bỏ trống vì lấy từ orders
        avatarUrl: avatarUrl,
      ));
    }

    return dashboard;
  }
}
