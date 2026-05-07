# architecture.md — Cấu trúc thư mục Leave_Module

## Cây thư mục đầy đủ

```
leave_module_training/              ← Thư mục context cho AI (feed vào khi vibe code)
│
├── instructions.md                 ← Luật code, convention, thư viện ưu tiên
├── context.md                      ← Data flow, schema DB, kết nối module
├── architecture.md                 ← File này — sơ đồ thư mục
├── todo.md                         ← Danh sách task, trạng thái tiến độ
├── pubspec.md                      ← Dependencies, version thư viện, màu sắc
└── UI.dart                         ← Figma export (Flutter widget code) — nguồn UI chính xác


Leave_Module/
│
├── Leave_Module.dart               ← Entry point. Nhận input, render view, gắn output
│
└── lib/
    │
    ├── entity/
    │   ├── leave_request_entity.dart       ← Model: id, userId, startDate, endDate, reason, status, approvedBy
    │   └── leave_status.dart               ← Enum: pending, approved, rejected
    │
    ├── logic_data/
    │   ├── leave_data.dart                 ← CRUD Supabase cho bảng leave_requests
    │   └── assignment_data.dart            ← Query bảng assignments (tuyến hỗ trợ)
    │
    ├── logic_uc/
    │   ├── submit_leave_uc.dart            ← UC: Sale nộp đơn nghỉ
    │   ├── fetch_leave_list_uc.dart        ← UC: Lấy danh sách đơn (theo role)
    │   ├── approve_leave_uc.dart           ← UC: Manager duyệt / từ chối
    │   └── leave_history_uc.dart           ← UC: Thống kê lịch sử nghỉ theo năm
    │
    ├── view/
    │   ├── sale/
    │   │   ├── leave_form_view.dart        ← Form đăng ký nghỉ (Sale)
    │   │   └── my_leave_list_view.dart     ← Danh sách đơn của Sale
    │   └── manager/
    │       ├── pending_list_view.dart      ← DS đơn chờ duyệt (Manager)
    │       ├── approve_detail_view.dart    ← Chi tiết đơn + nút Duyệt/Từ chối
    │       └── leave_history_view.dart     ← Báo cáo tổng ngày nghỉ nhân viên
    │
    ├── input/
    │   └── leave_input.dart               ← Guard: kiểm tra role, truyền userId vào module
    │
    └── output/
        └── leave_output.dart              ← Định nghĩa callback/event trả về App
```

## Mô tả từng layer

### `entity/`
- Class **thuần Dart**, không import Flutter hay Supabase
- Dùng `fromJson()` / `toJson()` để serialize
- `LeaveStatus` là enum để tránh magic string

### `logic_data/`
- Mỗi hàm là `Future<T>` hoặc `Stream<T>`
- Chỉ giao tiếp với Supabase, không có rule nghiệp vụ
- Ví dụ hàm:
  ```dart
  Future<List<LeaveRequestEntity>> getLeavesByUser(String userId);
  Future<void> insertLeave(LeaveRequestEntity leave);
  Future<void> updateLeaveStatus(int id, String status, String approvedBy);
  ```

### `logic_uc/`
- Gọi `logic_data`, áp dụng rule (validate ngày, check quyền, tính số ngày)
- Trả về `Result` hoặc throw `Exception` có message
- Ví dụ rule:
  - `start_date` không được là ngày đã qua
  - `end_date >= start_date`
  - Manager chỉ approve đơn của nhân viên trong `group_id` của mình

### `view/`
- Widget **không** gọi Supabase trực tiếp
- Dùng **Riverpod** Provider/Notifier để kết nối với `logic_uc`
- Tham chiếu UI từ file `UI.txt` (Figma export)

### `input/`
- `LeaveInput` là class chứa: `userId`, `userRole`, `groupId`
- `Leave_Module.dart` nhận `LeaveInput` từ App, quyết định render view nào

### `output/`
- `LeaveOutput` là abstract class hoặc callback typedef
- Sự kiện: `onLeaveSubmitted`, `onLeaveApproved`, `onClose`
- App lắng nghe output để chuyển màn hoặc refresh dữ liệu

## Import path convention
```dart
// Từ view gọi logic_uc
import '../logic_uc/submit_leave_uc.dart';

// Từ logic_uc gọi logic_data
import '../logic_data/leave_data.dart';

// Entity dùng ở mọi nơi
import '../entity/leave_request_entity.dart';
```