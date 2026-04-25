# Cấu trúc Thư mục (Architecture)

Thư mục dành riêng cho module kiểm tồn kho sẽ được đặt tại `lib/Inventory_Module/`. 
AI cần import đúng các đường dẫn này khi sinh code:

```text
Inventory_Module/
├── lib/
│   ├── entity/               # Định nghĩa các model class maps với Database (InventoryCheck, InventoryDetail, Product, Display)
│   ├── logic_data/           # Các hàm gọi API Supabase CRUD (insert kiểm tồn, upload ảnh, fetch sản phẩm)
│   ├── logic_uc/             # Xử lý Use Case (so sánh tồn kho, validate dữ liệu, xử lý quét mã vạch)
│   ├── view/                 # Các màn hình UI (List sản phẩm, Quét Barcode, Camera Chụp ảnh)
│   ├── input/                # Class định nghĩa điều kiện đầu vào để khởi chạy View (chứa store_id, sale_id...)
│   ├── output/               # Class định nghĩa các event callback trả về cho App (chuyển qua module khác)
│   └── inventory_module.dart # File entry point kết nối Input -> View -> Output