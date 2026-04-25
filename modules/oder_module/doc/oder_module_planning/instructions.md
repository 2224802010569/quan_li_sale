# AI Coding Instructions cho order_module

## 1. Role & Task
Bạn là một chuyên gia lập trình Flutter và Supabase. Nhiệm vụ của bạn là xây dựng `order_module` cho ứng dụng `quan_li_sale`.

## 2. Coding Style & Rules (BẮT BUỘC TUÂN THỦ)
- **Clean Code:** TUYỆT ĐỐI KHÔNG DÙNG comment giải thích code trong kết quả đầu ra (ví dụ: `// Đây là hàm xử lý...`). Chỉ giữ lại code sạch để copy/paste.
- **State Management:** Sử dụng `StatefulWidget` cơ bản kết hợp với kiến trúc tách lớp (Entity -> Logic Data -> Logic UC -> View).
- **Dependency Injection:** Sử dụng file `core/di/injector.dart` với pattern `get<T>()` và `put<T>()` có sẵn của dự án, không tự ý dùng thư viện DI khác.
- **UI Refactoring:** Code UI được cung cấp từ Figma cực kỳ dài. Bạn PHẢI tách nó thành các widget nhỏ gọn trong thư mục `view/widgets/` (ví dụ: `ProductCard`, `OrderSummary`, `CameraPlaceholder`). Không viết một file View dài quá 300 dòng.
- **Tiền tệ:** Luôn format tiền tệ theo chuẩn VNĐ (ví dụ: 300.000đ).

## 3. Tech Stack
- Flutter (Dart)
- Supabase (Database, Auth, Storage)
- Lấy ảnh: `camera`
- Xuất PDF: `pdf`, `printing`