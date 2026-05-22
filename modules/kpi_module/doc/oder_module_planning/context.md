# Project Context: Order Module

## 1. Tổng quan
`order_module` quản lý quy trình lên đơn hàng của Sale tại cửa hàng và cho phép Manager xem lại lịch sử đơn hàng.

## 2. Phân quyền (Roles)
- **Sale:**
  - Được quyền vào màn hình `CreateOrderView`.
  - Chọn sản phẩm, nhập số lượng, chụp ảnh minh chứng tại `store_id`.
  - Lưu đơn hàng và xuất/in file PDF.
  - Chỉ xem được lịch sử đơn hàng do chính mình tạo ra.
- **Manager:**
  - KHÔNG có tính năng tạo đơn.
  - Xem danh sách toàn bộ đơn hàng trong `OrderHistoryView`. Có thể lọc theo `store_id` hoặc `user_id`.

## 3. Database Schema (Supabase)
Module này tương tác chính với 3 bảng:

**Table: products**
- `id` (bigint, PK)
- `product_name` (varchar)
- `price` (numeric)

**Table: orders**
- `id` (bigint, PK, auto_gen)
- `user_id` (uuid, FK users)
- `store_id` (bigint, FK stores)
- `total_amount` (numeric)
- `order_image` (text - URL từ Supabase Storage)
- `pdf_link` (text - URL từ Supabase Storage)
- `created_at` (timestamp)

**Table: order_items**
- `id` (bigint, PK, auto_gen)
- `order_id` (bigint, FK orders)
- `product_id` (bigint, FK products)
- `quantity` (integer)
- `unit_price` (numeric)

## 4. Data Flow (Luồng tạo đơn)
1. App truyền `OrderInput(role: 'Sale', storeId: 1)` vào module.
2. View gọi UC lấy list `products`.
3. User tương tác UI: tăng/giảm số lượng -> tính `total_amount`.
4. User chụp ảnh -> UC gọi Supabase Storage lấy url ảnh.
5. UC lưu `orders` (trả về order_id) -> UC lưu list `order_items`.
6. UC gen PDF -> Lưu PDF lên Storage -> Update `pdf_link` vào `orders`.