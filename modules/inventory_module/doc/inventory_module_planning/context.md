# Ngữ cảnh Dự án (Project Context)

## 1. Vị trí của Module
`Inventory_Module` là module thứ 4 trong hệ thống quản lý bán hàng (Sales App). Nó chịu trách nhiệm chính trong việc:
- Hỗ trợ nhân viên Sale kiểm kê hàng hóa tồn kho thực tế tại cửa hàng (`store_id`).
- Quét mã vạch sản phẩm.
- Chụp ảnh minh chứng kệ hàng (trưng bày).
- Gợi ý số lượng lên đơn tiếp theo dựa trên dữ liệu tồn kho.

## 2. Luồng dữ liệu (Data Flow)
- **Input:** Khởi tạo module với điều kiện bắt buộc là `store_id` (Cửa hàng hiện tại) và danh sách `product_id` (Các sản phẩm cần kiểm tra tại cửa hàng đó).
- **Quá trình thực thi:**
  1. Lấy danh sách sản phẩm và tồn kho hệ thống từ bảng `products`.
  2. Sale nhập số lượng tồn thực tế hoặc quét mã vạch để đếm.
  3. Sale chụp ảnh kệ trưng bày làm minh chứng.
- **Output:** 1. Lưu dữ liệu kiểm tồn vào bảng `inventory_checks` và `inventory_details`.
  2. Lưu ảnh minh chứng vào bảng `displays`.
  3. Bắn tín hiệu ra `Output` để điều hướng App sang các module khác (ví dụ: Order_Module để lên đơn).

## 3. Các bảng Database liên quan (Supabase PostgreSQL)
- `inventory_checks` (id, user_id, store_id, created_at)
- `inventory_details` (id, check_id, product_id, quantity, status, created_at)
- `displays` (id, user_id, store_id, image_url, note, created_at)
- `products` (id, product_name, price)