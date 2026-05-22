import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kpi_module/entity/kpi_report_entity.dart';
import 'package:kpi_module/logic_uc/manage_kpi_uc.dart';
import 'package:kpi_module/view/manager/kpi_detail_view.dart';
import 'package:kpi_module/view/manager/set_kpi_view.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class KpiDashboardView extends ConsumerStatefulWidget {
  const KpiDashboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<KpiDashboardView> createState() => _KpiDashboardViewState();
}

class _KpiDashboardViewState extends ConsumerState<KpiDashboardView> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  Future<List<KpiReportEntity>> _fetchDashboard() {
    return ref.read(manageKpiUcProvider).fetchDashboardKpis(_selectedMonth, _selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Báo cáo KPI', style: TextStyle(color: Color(0xFF001D4E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF001D4E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _showFilterDialog,
          )
        ],
      ),
      body: FutureBuilder<List<KpiReportEntity>>(
        future: _fetchDashboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];
          
          double totalTarget = 0;
          double totalActual = 0;
          List<Map<String, dynamic>> allOrders = [];
          for (var r in data) {
            totalTarget += r.targetRevenue;
            totalActual += r.actualRevenue;
            if (r.orders.isNotEmpty) {
              allOrders.addAll(r.orders);
            }
          }

          // Sort for top 3
          final sortedData = List<KpiReportEntity>.from(data);
          sortedData.sort((a, b) => b.actualRevenue.compareTo(a.actualRevenue));
          final top3 = sortedData.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16, bottom: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCards(totalTarget, totalActual),
                  const SizedBox(height: 32),
                  _buildExecutiveOverview(),
                  const SizedBox(height: 32),
                  _buildTop3(top3),
                  const SizedBox(height: 32),
                  _buildOrderImages(allOrders),
                  const SizedBox(height: 32),
                  _buildExportReport(sortedData, totalTarget, totalActual),
                  const SizedBox(height: 32),
                  // List tất cả nhân viên để có thể ấn vào xem chi tiết
                  _buildAllStaffList(sortedData),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        int tempMonth = _selectedMonth;
        int tempYear = _selectedYear;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Chọn thời gian'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Tháng: '),
                      DropdownButton<int>(
                        value: tempMonth,
                        items: List.generate(12, (index) => index + 1).map((m) {
                          return DropdownMenuItem<int>(value: m, child: Text('$m'));
                        }).toList(),
                        onChanged: (val) => setStateDialog(() => tempMonth = val!),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Năm: '),
                      DropdownButton<int>(
                        value: tempYear,
                        items: [DateTime.now().year - 1, DateTime.now().year, DateTime.now().year + 1].map((y) {
                          return DropdownMenuItem<int>(value: y, child: Text('$y'));
                        }).toList(),
                        onChanged: (val) => setStateDialog(() => tempYear = val!),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = tempMonth;
                      _selectedYear = tempYear;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderCards(double target, double actual) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    
    return Column(
      children: [
        _buildStatCard(
          title: 'KPI TEAM',
          value: currencyFormat.format(target),
          borderColor: const Color(0xFF001D4E),
          titleColor: const Color(0xFF434651),
          valueColor: const Color(0xFF001D4E),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'TIẾN ĐỘ THỰC HIỆN TEAM',
          value: currencyFormat.format(actual),
          borderColor: const Color(0xFFE6845D),
          titleColor: const Color(0xFF434651),
          valueColor: const Color(0xFFE6845D),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color borderColor,
    required Color titleColor,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0D47A1),
            blurRadius: 24,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.40,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXECUTIVE OVERVIEW',
          style: TextStyle(
            color: Color(0xFF434651),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.70,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF001D4E),
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.90,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const SetKpiView()));
            setState(() {});
          },
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF001D4E), Color(0xFF003178)],
              ),
              borderRadius: BorderRadius.circular(9999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330D47A1),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Chỉ tiêu nhân viên',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTop3(List<KpiReportEntity> top3) {
    if (top3.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0x19C4C6D2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0D47A1),
            blurRadius: 24,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0x19001D4E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.leaderboard, color: Color(0xFF001D4E), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Top 3 Doanh thu',
                style: TextStyle(
                  color: Color(0xFF001D4E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(top3.length, (index) {
            return _buildTop3Item(top3[index], index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildTop3Item(KpiReportEntity report, int rank) {
    Color rankColor;
    String rankStr;
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFACC15);
        rankStr = '1ST';
        break;
      case 2:
        rankColor = const Color(0xFFCBD5E1);
        rankStr = '2ND';
        break;
      case 3:
      default:
        rankColor = const Color(0xFFD97706);
        rankStr = '3RD';
        break;
    }

    final currencyFormat = NumberFormat.compact(locale: 'vi_VN');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rank == 1 ? const Color(0x0C001D4E) : Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        border: rank == 1 ? Border.all(color: const Color(0x19001D4E)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: rank == 1 ? 28 : 24,
                      backgroundColor: const Color(0xFFE8E8E8),
                      backgroundImage: report.avatarUrl.isNotEmpty ? NetworkImage(report.avatarUrl) : null,
                      child: report.avatarUrl.isEmpty
                          ? Text(
                              report.userName.isNotEmpty ? report.userName[0].toUpperCase() : '?',
                              style: TextStyle(color: const Color(0xFF001D4E), fontWeight: FontWeight.bold, fontSize: rank == 1 ? 24 : 18),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: -4,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: rankColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            rankStr,
                            style: TextStyle(
                              color: rank == 1 ? const Color(0xFF001D4E) : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF001D4E),
                          fontSize: rank == 1 ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Sale',
                        style: TextStyle(
                          color: Color(0xFF434651),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(report.actualRevenue),
                style: TextStyle(
                  color: const Color(0xFF001D4E),
                  fontSize: rank == 1 ? 18 : 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${report.percentCompleted.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: report.percentCompleted >= 100 ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderImages(List<Map<String, dynamic>> orders) {
    // Lọc ra các order có ảnh hợp lệ
    final validOrders = orders.where((o) {
      final img = o['order_image'] as String?;
      return img != null && img.isNotEmpty;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hình ảnh đơn hàng',
              style: TextStyle(
                color: Color(0xFF001D4E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (validOrders.isNotEmpty)
              Text(
                'Xem tất cả',
                style: TextStyle(
                  color: const Color(0xFF003178),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (validOrders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Chưa có hình ảnh đơn hàng nào trong tháng.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          )
        else
          SizedBox(
            height: 163,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: validOrders.length > 10 ? 10 : validOrders.length, // Tối đa 10 ảnh
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final order = validOrders[index];
                final id = order['id']?.toString() ?? 'N/A';
                final imageUrl = order['order_image'] as String;

                return Container(
                  width: 163,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.grey.shade200,
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          width: 163,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.60), Colors.transparent],
                            ),
                          ),
                          child: Text(
                            'ORD-$id',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildExportReport(List<KpiReportEntity> data, double totalTarget, double totalActual) {
    return InkWell(
      onTap: () {
        _exportPdf(data, totalTarget, totalActual);
      },
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0x4CC4C6D2), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.file_download_outlined, color: Color(0xFF434651)),
            SizedBox(width: 8),
            Text(
              'Xuất báo cáo',
              style: TextStyle(
                color: Color(0xFF434651),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(List<KpiReportEntity> data, double totalTarget, double totalActual) async {
    // Hiển thị loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang tạo báo cáo PDF...')),
    );

    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.robotoRegular();
      final boldFont = await PdfGoogleFonts.robotoBold();
      final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Text('BÁO CÁO KPI TỔNG QUAN', style: pw.TextStyle(font: boldFont, fontSize: 24)),
              pw.SizedBox(height: 8),
              pw.Text('Tháng $_selectedMonth/$_selectedYear', style: pw.TextStyle(font: font, fontSize: 16)),
              pw.SizedBox(height: 24),
              
              pw.Text('1. TỔNG QUAN', style: pw.TextStyle(font: boldFont, fontSize: 16)),
              pw.SizedBox(height: 12),
              pw.Text('Tổng chỉ tiêu: ${currencyFormat.format(totalTarget)}', style: pw.TextStyle(font: font, fontSize: 14)),
              pw.Text('Tổng thực đạt: ${currencyFormat.format(totalActual)}', style: pw.TextStyle(font: font, fontSize: 14)),
              pw.Text('Tiến độ: ${totalTarget > 0 ? (totalActual / totalTarget * 100).toStringAsFixed(1) : 0}%', style: pw.TextStyle(font: font, fontSize: 14)),
              pw.SizedBox(height: 32),

              pw.Text('2. CHI TIẾT NHÂN VIÊN', style: pw.TextStyle(font: boldFont, fontSize: 16)),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(font: boldFont),
                cellStyle: pw.TextStyle(font: font),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headers: ['STT', 'Nhân viên', 'Chỉ tiêu', 'Thực đạt', 'Tiến độ'],
                data: List<List<String>>.generate(
                  data.length,
                  (index) {
                    final report = data[index];
                    return [
                      (index + 1).toString(),
                      report.userName,
                      currencyFormat.format(report.targetRevenue),
                      currencyFormat.format(report.actualRevenue),
                      '${report.percentCompleted.toStringAsFixed(1)}%',
                    ];
                  },
                ),
              ),
            ];
          },
        ),
      );

      await Printing.sharePdf(bytes: await pdf.save(), filename: 'bao_cao_kpi_$_selectedMonth-$_selectedYear.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xuất báo cáo: $e')),
        );
      }
    }
  }

  Widget _buildAllStaffList(List<KpiReportEntity> data) {
    if (data.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tất cả nhân viên',
          style: TextStyle(
            color: Color(0xFF001D4E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...data.map((report) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KpiDetailView(
                    userId: report.userId,
                    userName: report.userName,
                    month: report.month,
                    year: report.year,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x19C4C6D2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    report.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        '${report.percentCompleted.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: report.percentCompleted >= 100 ? Colors.green : Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
