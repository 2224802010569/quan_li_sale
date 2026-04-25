# Todo List: order_module

Tiến hành code theo thứ tự sau. Sau khi hoàn thành một task, hãy kiểm tra lại syntax trước khi sang task mới.

- [x] **Phase 1: Entities & Input/Output**
  - [x] Tạo `product.dart`, `order.dart`, `order_item.dart` có hàm `fromMap` và `toMap`.
  - [x] Tạo `order_input.dart` (chứa role, storeId, userId).
  - [x] Tạo `order_output.dart` (chứa tín hiệu back hoặc success).

- [x] **Phase 2: Database Data Access (logic_data)**
  - [x] Viết hàm `getProducts` trong `product_data.dart`.
  - [x] Viết hàm `insertOrderAndItems` trong `order_data.dart` (lưu ý dùng RPC hoặc rpc batch nếu cần, hoặc insert order lấy ID rồi mới insert items).
  - [x] Viết hàm `uploadFile` (cho ảnh và pdf).

- [x] **Phase 3: Logic Use Cases (logic_uc)**
  - [x] Hoàn thiện `create_order_uc.dart`: quản lý danh sách giỏ hàng tạm, tính `totalAmount` (tính cả VAT 10% theo UI).
  - [x] Viết khung cơ bản cho `generate_pdf_uc.dart`.

- [x] **Phase 4: UI Refactoring (Khó nhất)**
  - [x] Đọc file UI Figma được cung cấp.
  - [x] Tách UI Figma thành các Widget: `ProductItemCard` (có nút tăng giảm số lượng), `OrderSummaryPanel` (chứa VAT và tổng cộng).
  - [x] Dựng `create_order_view.dart` ghép các widget lại. Tích hợp nút mở Camera.

- [x] **Phase 5: Lịch sử & Phân quyền**
  - [x] Dựng `order_history_view.dart` (hiển thị danh sách đơn hàng cơ bản).
  - [x] Code file `order_module.dart` để đọc `OrderInput`: Nếu là Sale -> Mở `CreateOrderView` (có tab Lịch sử). Nếu là Manager -> Mở thẳng màn hình Lịch sử.