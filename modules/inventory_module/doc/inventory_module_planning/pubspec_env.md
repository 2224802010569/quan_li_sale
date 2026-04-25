# Cấu hình Chuẩn & Môi trường

Để module hoạt động đúng, AI cần lưu ý sử dụng các package chuẩn sau trong file `pubspec.yaml`. Chỉ sử dụng các thư viện này để tránh xung đột phiên bản hoặc lỗi hàm deprecated.

## 1. Thư viện yêu cầu (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  # Supabase SDK để xử lý Database và Storage
  supabase_flutter: ^2.4.0 
  
  # Quét mã vạch (Barcode Scanner)
  mobile_scanner: ^3.5.6 
  
  # Sử dụng Camera để chụp ảnh trưng bày kệ hàng
  camera: ^0.10.5
  
  # Quản lý hiển thị hình ảnh từ network (nếu cần show ảnh sản phẩm)
  cached_network_image: ^3.3.1
  
  # State Management (AI chọn 1 tùy thuộc base code hiện tại của project, ví dụ Provider)
  provider: ^6.1.1