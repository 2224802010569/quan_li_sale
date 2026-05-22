import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:kpi_module/entity/kpi_report_entity.dart';
import 'package:intl/intl.dart';

class GenerateKpiPdfUc {
  Future<void> generateAndPrintPdf(KpiReportEntity report) async {
    final pdf = pw.Document();

    // Thử load font hỗ trợ tiếng Việt (thường cần dùng font TTF như Roboto)
    // Nếu ứng dụng chưa có sẵn font, ta có thể dùng font mặc định nhưng sẽ bị lỗi dấu.
    // Tạm dùng font mặc định của Printing package
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Tiêu đề
            pw.Header(
              level: 0,
              child: pw.Text(
                'BÁO CÁO TIẾN ĐỘ KPI',
                style: pw.TextStyle(font: fontBold, fontSize: 24),
              ),
            ),
            pw.SizedBox(height: 16),

            // Thông tin nhân viên
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Nhân viên: ${report.userName}', style: pw.TextStyle(font: fontBold, fontSize: 14)),
                  pw.SizedBox(height: 4),
                  pw.Text('Mã NV: ${report.userId}', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 4),
                  pw.Text('Kỳ báo cáo: Tháng ${report.month} / ${report.year}', style: pw.TextStyle(font: font)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Tóm tắt số liệu
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryBox('MỤC TIÊU', currencyFormat.format(report.targetRevenue), font, fontBold),
                _buildSummaryBox('THỰC ĐẠT', currencyFormat.format(report.actualRevenue), font, fontBold),
                _buildSummaryBox('HOÀN THÀNH', '${report.percentCompleted.toStringAsFixed(1)}%', font, fontBold, isHighlight: true),
              ],
            ),
            pw.SizedBox(height: 32),

            // Bảng danh sách đơn hàng
            pw.Text('CHI TIẾT ĐƠN HÀNG TRONG THÁNG', style: pw.TextStyle(font: fontBold, fontSize: 14)),
            pw.SizedBox(height: 8),
            _buildOrderTable(report.orders, font, fontBold, currencyFormat),
          ];
        },
      ),
    );

    // Mở hộp thoại in / lưu PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'KPI_Report_${report.month}_${report.year}_${report.userName}',
    );
  }

  pw.Widget _buildSummaryBox(String title, String value, pw.Font font, pw.Font fontBold, {bool isHighlight = false}) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: isHighlight ? PdfColors.blue50 : PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: isHighlight ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildOrderTable(List<Map<String, dynamic>> orders, pw.Font font, pw.Font fontBold, NumberFormat currencyFormat) {
    if (orders.isEmpty) {
      return pw.Text('Không có đơn hàng nào trong tháng này.', style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic));
    }

    return pw.TableHelper.fromTextArray(
      headers: ['Mã ĐH', 'Cửa hàng', 'Ngày tạo', 'Thành tiền'],
      headerStyle: pw.TextStyle(font: fontBold),
      cellStyle: pw.TextStyle(font: font),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
      cellAlignment: pw.Alignment.centerLeft,
      data: orders.map((order) {
        final id = order['id']?.toString() ?? 'N/A';
        final storeId = order['store_id']?.toString() ?? 'N/A';
        final createdAt = order['created_at'] != null ? order['created_at'].toString().split('T')[0] : 'N/A';
        final total = currencyFormat.format((order['total_amount'] ?? 0).toDouble());
        return [id, 'CH #$storeId', createdAt, total];
      }).toList(),
    );
  }
}
