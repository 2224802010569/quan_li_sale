# Dependencies Configuration

Khi viết code, hãy giả định rằng file `pubspec.yaml` của `order_module` đã cài đặt sẵn các thư viện sau ở phiên bản mới nhất tương thích với Flutter 3.x:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0      # Thao tác DB và Storage
  camera: ^0.10.5               # Chụp ảnh hóa đơn/đơn hàng
  path_provider: ^2.1.2         # Lưu file tạm trước khi up Storage
  intl: ^0.19.0                 # BẮT BUỘC dùng để format tiền tệ VNĐ (NumberFormat)
  pdf: ^3.10.8                  # Khung vẽ PDF
  printing: ^5.11.1             # Chức năng in/preview PDF