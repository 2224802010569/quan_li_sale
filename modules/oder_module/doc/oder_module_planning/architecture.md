# Directory Architecture: order_module

Nắm vững cấu trúc sau để import file chính xác bằng relative path (ví dụ: `import '../entity/order.dart';`).

```text
order_module/
├── lib/
│   ├── entity/
│   │   ├── product.dart
│   │   ├── order.dart
│   │   └── order_item.dart
│   ├── input/
│   │   └── order_input.dart
│   ├── output/
│   │   └── order_output.dart
│   ├── logic_data/
│   │   ├── product_data.dart     (Lấy db products)
│   │   └── order_data.dart       (CRUD orders, order_items, upload storage)
│   ├── logic_uc/
│   │   ├── create_order_uc.dart  (Logic tính tổng tiền, liên kết chụp ảnh)
│   │   ├── generate_pdf_uc.dart  (Logic vẽ PDF)
│   │   └── history_uc.dart       (Tính mốc 3 tháng, query lịch sử)
│   ├── view/
│   │   ├── screens/
│   │   │   ├── sale/
│   │   │   │   └── create_order_view.dart
│   │   │   ├── manager/
│   │   │   │   └── manager_history_view.dart
│   │   │   └── shared/
│   │   │       └── order_history_view.dart
│   │   ├── widgets/
│   │   │   ├── product_item_card.dart
│   │   │   ├── order_summary_panel.dart
│   │   │   └── camera_capture_box.dart
│   └── order_module.dart         (File root của module)
