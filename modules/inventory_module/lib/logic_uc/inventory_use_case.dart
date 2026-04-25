class InventoryUseCase {
  /// Tính toán chênh lệch tồn kho
  /// Trả về số lượng chênh lệch (Thực tế - Hệ thống)
  int calculateStockDifference({required int systemStock, required int actualStock}) {
    return actualStock - systemStock;
  }

  /// Xác định trạng thái kiểm tồn dựa trên độ chênh lệch
  /// Để lưu vào cột 'status' của bảng inventory_details
  String determineStockStatus({int? previousQty, required int actualQty}) {
    if (previousQty == null) return 'NEW';
    final diff = actualQty - previousQty;
    if (diff == 0) return 'MATCHED';   // Khớp
    if (diff > 0) return 'SURPLUS';    // Dư thừa
    return 'SHORTAGE';                 // Thiếu hụt
  }

  /// Kiểm tra điều kiện hợp lệ để submit báo cáo kiểm tồn
  /// - Phải kiểm tra ít nhất 1 mặt hàng
  /// - Nếu yêu cầu kiểm kê đủ danh sách, số lượng đã kiểm phải >= số lượng yêu cầu
  /// - Bắt buộc phải có ảnh minh chứng kệ hàng
  void validateSubmission({
    required int totalCheckedItems,
    required int requiredItemsCount,
    required bool hasProofImage,
  }) {
    if (totalCheckedItems == 0) {
      throw Exception('Bạn chưa kiểm kê bất kỳ mặt hàng nào.');
    }
    
    // Tùy vào yêu cầu nghiệp vụ: có bắt buộc kiểm hết danh sách hay không
    if (totalCheckedItems < requiredItemsCount) {
      throw Exception('Bạn chưa kiểm kê đầy đủ các mặt hàng được yêu cầu ($totalCheckedItems/$requiredItemsCount).');
    }

    if (!hasProofImage) {
      throw Exception('Bắt buộc phải có ảnh chụp minh chứng kệ hàng hoặc trưng bày.');
    }
  }

  /// Xử lý logic nhận diện mã vạch
  /// Trả về true nếu mã vạch nằm trong danh sách cần kiểm kê
  bool isValidBarcode(String scannedBarcode, List<String> validBarcodes) {
    if (scannedBarcode.isEmpty) return false;
    return validBarcodes.contains(scannedBarcode);
  }
}
