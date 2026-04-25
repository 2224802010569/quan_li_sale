# Danh sách Nhiệm vụ (Todo List)

## ✅ Đã hoàn thành (Done)
- [x] Thiết kế Database Schema PostgreSQL cho các bảng liên quan.
- [x] Export UI cơ bản từ Figma sang Flutter Code (màn hình danh sách, màn quét mã, màn chụp ảnh).
- [x] Định nghĩa kiến trúc luồng chạy (Input -> Module -> View -> Output).

## 🔲 Cần thực hiện (To-Do)
- [ ] **Bước 1: Khởi tạo Entities.** Tạo các class trong `entity/` dựa trên schema: `ProductEntity`, `InventoryCheckEntity`, `InventoryDetailEntity`, `DisplayEntity` có kèm phương thức `fromJson` / `toJson`.
- [ ] **Bước 2: Xây dựng Logic Data.** Viết các hàm trong `logic_data/` dùng Supabase SDK: `fetchProductsByStore()`, `submitInventoryData()`, `uploadDisplayImage()`.
- [ ] **Bước 3: Xây dựng Logic Use Case.** Viết hàm xử lý trong `logic_uc/`: Tính toán độ chênh lệch tồn hệ thống và tồn thực tế, logic nhận diện mã vạch.
- [ ] **Bước 4: Cấu trúc lại View.** Refactor lại các đoạn code tĩnh trong `UI.txt` thành các màn hình động trong `view/`: 
  - `inventory_audit_view.dart` (Danh sách sản phẩm).
  - `barcode_scanner_view.dart` (Quét mã).
  - `proof_capture_view.dart` (Chụp ảnh minh chứng).
- [ ] **Bước 5: Kết nối Entry Point.** Setup file `inventory_module.dart` kết nối với `input/` và `output/`. Định nghĩa trigger điều hướng (ví dụ ấn "Lưu" -> Bắn event qua Output).