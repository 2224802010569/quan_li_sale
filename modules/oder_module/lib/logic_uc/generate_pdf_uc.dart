import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../logic_data/order_data.dart';
import 'create_order_uc.dart';

class GeneratePdfUC {
  final OrderData _orderData;

  GeneratePdfUC({required OrderData orderData}) : _orderData = orderData;

  final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );



  Future<void> printDraftInvoice({
    required String storeName,
    required List<CartItem> items,
    required double subtotal,
    required double vatAmount,
    required double totalAmount,
  }) async {
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
      italic: fontItalic,
    );

    final pdf = pw.Document(theme: theme);
    pdf.addPage(_buildInvoicePage(
      storeName: storeName,
      items: items,
      subtotal: subtotal,
      vatAmount: vatAmount,
      totalAmount: totalAmount,
    ));

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'hoa_don_tam_tinh_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<String> generateAndUpload({
    required int orderId,
    required String storeName,
    required List<CartItem> items,
    required double subtotal,
    required double vatAmount,
    required double totalAmount,
  }) async {
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
      italic: fontItalic,
    );

    final pdf = pw.Document(theme: theme);
    pdf.addPage(_buildInvoicePage(
      orderLabel: '#$orderId',
      storeName: storeName,
      items: items,
      subtotal: subtotal,
      vatAmount: vatAmount,
      totalAmount: totalAmount,
    ));

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/order_${orderId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    final pdfUrl = await _orderData.uploadFile(
      filePath: filePath,
      bucket: 'order_pdfs',
      folder: 'pdfs',
    );

    await _orderData.updateOrderPdfLink(orderId: orderId, pdfLink: pdfUrl);

    await file.delete();

    return pdfUrl;
  }

  pw.Page _buildInvoicePage({
    String? orderLabel,
    required String storeName,
    required List<CartItem> items,
    required double subtotal,
    required double vatAmount,
    required double totalAmount,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'HÓA ĐƠN BÁN HÀNG',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Cửa hàng: $storeName',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ),
            if (orderLabel != null && orderLabel.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Mã đơn: $orderLabel',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            _buildItemsTable(items),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 8),
            _buildSummaryRow('Tạm tính:', _currencyFormat.format(subtotal)),
            pw.SizedBox(height: 4),
            _buildSummaryRow('VAT (10%):', _currencyFormat.format(vatAmount)),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 4),
            _buildSummaryRow(
              'TỔNG CỘNG:',
              _currencyFormat.format(totalAmount),
              isBold: true,
            ),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Text(
                'Cảm ơn quý khách!',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  pw.Widget _buildItemsTable(List<CartItem> items) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      headers: ['Sản phẩm', 'Đơn giá', 'SL', 'Thành tiền'],
      data: items.map((item) {
        return [
          item.product.productName,
          _currencyFormat.format(item.product.price),
          '${item.quantity}',
          _currencyFormat.format(item.lineTotal),
        ];
      }).toList(),
    );
  }

  pw.Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    final style = pw.TextStyle(
      fontSize: isBold ? 14 : 12,
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(value, style: style),
      ],
    );
  }
}

