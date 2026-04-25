# Cẩm nang & Quy tắc Lập trình (Instructions)

## 1. Công nghệ & Framework
- **Nền tảng:** Flutter cho Mobile App.
- **Backend/Database:** Supabase.
- **Ngôn ngữ:** Dart. Đảm bảo null-safety.

## 2. Kiến trúc & Cấu trúc mã nguồn
- Tuân thủ nghiêm ngặt mô hình luồng chạy đã định nghĩa: `App -> Input -> Inventory_module.dart -> View -> Output -> App`.
- **Tách biệt Logic & View:** - Giao diện (`view/`) chỉ chịu trách nhiệm hiển thị UI (được cung cấp từ file Figma to Code). KHÔNG chứa logic gọi API hay tính toán phức tạp ở đây.
  - Xử lý dữ liệu và gọi API phải nằm ở `logic_data/` (CRUD Database) và `logic_uc/` (Use Cases).
- **Quản lý trạng thái (State Management):** Sử dụng các giải pháp như Provider, Riverpod hoặc BLoC (tùy convention hiện tại của dự án) để quản lý state giữa View và Logic.

## 3. Quy chuẩn Đặt tên (Naming Convention)
- **Tên class & widget:** `PascalCase` (ví dụ: `InventoryAuditView`, `InventoryLogicUc`).
- **Tên biến & hàm:** `camelCase` (ví dụ: `fetchProducts`, `actualStock`).
- **Tên file & thư mục:** `snake_case` (ví dụ: `inventory_module.dart`, `logic_data.dart`).

## 4. UI/UX & Style
- Bám sát cấu trúc UI đã export từ Figma (các Widget hiện có như `OverlayScrim`, `InventoryAuditScanningBarcode`, `InventoryAuditProofCapture`).
- Tách nhỏ các UI components dùng chung (ví dụ: thẻ sản phẩm, nút bấm) thay vì nhét tất cả vào một file build dài.