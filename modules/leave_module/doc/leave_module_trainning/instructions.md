# instructions.md — Luật code cho Leave_Module

## Ngôn ngữ & Framework
- **Flutter** (Dart), tuân theo **Clean Architecture**
- Không dùng `setState` trực tiếp ở View — mọi state đi qua logic layer
- Widget phải là `StatelessWidget` trừ khi bắt buộc cần `StatefulWidget`

## Quy tắc đặt tên
| Loại | Convention | Ví dụ |
|---|---|---|
| File | snake_case | `leave_request_entity.dart` |
| Class | PascalCase | `LeaveRequestEntity` |
| Biến / hàm | camelCase | `fetchLeaveList()` |
| Hằng số | SCREAMING_SNAKE | `MAX_LEAVE_DAYS` |
| Thư mục | snake_case | `logic_data/` |

## Cấu trúc bắt buộc của mỗi module
```
Leave_Module/
  lib/
    entity/          ← class dữ liệu thuần (không có logic)
    logic_data/      ← CRUD với Supabase (async, trả Future)
    logic_uc/        ← use-case: gọi logic_data, xử lý rule nghiệp vụ
    view/            ← Widget Flutter, gọi logic_uc
    input/           ← điều kiện/guard để vào module
    output/          ← định nghĩa event trả về app
  Leave_Module.dart  ← entry point, kết nối view + input/output
```

## Thư viện ưu tiên
- **Supabase Flutter** — database & auth
- **flutter_riverpod** — state management (provider, notifier)
- **go_router** — điều hướng
- **intl** — format ngày tháng (`DateFormat`)
- **uuid** — tạo ID phía client nếu cần

## Quy tắc async / error handling
- Mọi hàm gọi Supabase phải `try/catch` và ném `Exception` có message rõ ràng
- Không để `print()` trong production — dùng `debugPrint()` hoặc logger
- Hàm trong `logic_data` chỉ trả raw data; hàm trong `logic_uc` mới xử lý rule

## Style UI
- File UI tham khảo: `leave_module_training/UI.dart` — Figma export chứa toàn bộ widget code chính xác. Khi build view, **đọc file này trước** để lấy đúng layout, màu, spacing.
- Font: **Manrope** (đã dùng trong Figma)
- Màu chính: `#001D4E` (navy), `#003178`, `#E8E8E8`, `#F59E0B` (pending badge)
- Border radius pill: `BorderRadius.circular(9999)`
- Spacing chuẩn: `32px` giữa các section, `24px` padding ngang
- Background scaffold: `Color.fromARGB(255, 18, 32, 47)` (dark mode)

## Quy tắc commit (nếu dùng git)
```
feat(leave): thêm màn hình danh sách đơn nghỉ
fix(leave): sửa lỗi filter ngày bị lệch múi giờ
refactor(leave): tách logic approve ra logic_uc
```