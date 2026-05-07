# todo.md — Kế hoạch thực hiện Leave_Module

## Bảng kế hoạch tổng quan

| STT | Task | Layer | Role test | Ưu tiên | Trạng thái |
|---|---|---|---|---|---|
| 1 | Tạo `LeaveRequestEntity` + `LeaveStatus` enum | entity | — | 🔴 Cao | ✅ Hoàn thành |
| 2 | Viết `leave_data.dart` — hàm CRUD Supabase | logic_data | — | 🔴 Cao | ✅ Hoàn thành |
| 3 | Viết `assignment_data.dart` — query tuyến hỗ trợ | logic_data | — | 🟡 Trung | ✅ Hoàn thành |
| 4 | Viết `submit_leave_uc.dart` — validate + insert | logic_uc | Sale | 🔴 Cao | ✅ Hoàn thành |
| 5 | Viết `fetch_leave_list_uc.dart` — lọc theo role | logic_uc | Sale/Mgr | 🔴 Cao | ✅ Hoàn thành |
| 6 | Viết `approve_leave_uc.dart` — duyệt/từ chối | logic_uc | Manager | 🔴 Cao | ✅ Hoàn thành |
| 7 | Viết `leave_history_uc.dart` — thống kê năm | logic_uc | Manager | 🟡 Trung | ✅ Hoàn thành |
| 8 | Xây `leave_form_view.dart` (UI Figma — Sale form) | view/sale | Sale | 🔴 Cao | ✅ Hoàn thành |
| 9 | Xây `my_leave_list_view.dart` (DS đơn của Sale) | view/sale | Sale | 🔴 Cao | ✅ Hoàn thành |
| 10 | Xây `pending_list_view.dart` (Manager xem đơn) | view/manager | Manager | 🔴 Cao | ✅ Hoàn thành |
| 11 | Xây `approve_detail_view.dart` (Duyệt/Từ chối) | view/manager | Manager | 🔴 Cao | ✅ Hoàn thành |
| 12 | Xây `leave_history_view.dart` (Báo cáo năm) | view/manager | Manager | 🟡 Trung | ✅ Hoàn thành |
| 13 | Viết `leave_input.dart` + `leave_output.dart` | input/output | — | 🔴 Cao | ✅ Hoàn thành |
| 14 | Viết `Leave_Module.dart` — kết nối toàn bộ | entry | — | 🔴 Cao | ✅ Hoàn thành |
| 15 | Test end-to-end: Sale gửi → Manager duyệt | — | Cả hai | 🔴 Cao | ⬜ Chưa làm |

---

## Thứ tự thực hiện (theo dependency)

```
Bước 1 — Foundation (không phụ thuộc gì)
  └── entity/ (task 1)

Bước 2 — Data layer
  └── logic_data/ (task 2, 3)

Bước 3 — Business logic
  └── logic_uc/ (task 4, 5, 6, 7)

Bước 4 — UI
  └── view/sale/ (task 8, 9)
  └── view/manager/ (task 10, 11, 12)

Bước 5 — Wiring
  └── input/ + output/ (task 13)
  └── Leave_Module.dart (task 14)

Bước 6 — QA
  └── Test end-to-end (task 15)
```

---

## Chi tiết từng use-case

### UC-01: Sale đăng ký nghỉ phép
- **Input**: lý do, ngày bắt đầu, ngày kết thúc
- **Rule**: start ≥ hôm nay, end ≥ start
- **Output**: bản ghi mới trong `leave_requests` với status = `Pending`
- **UI ref**: màn hình "Đăng ký nghỉ phép" trong UI.txt (badge "Đang chờ" màu vàng)

### UC-02: Xem danh sách đơn
- **Sale**: chỉ thấy đơn của mình, filter theo tháng/trạng thái
- **Manager**: thấy đơn của cả `group_id`, filter tương tự
- **Output**: list card hiển thị ngày, lý do, trạng thái

### UC-03: Manager phê duyệt / từ chối
- **Input**: id đơn, quyết định, ghi chú (tuỳ chọn)
- **Rule**: Manager chỉ duyệt được đơn của nhóm mình
- **Output**: cập nhật `status` + `approved_by` trong DB; thông báo kết quả

### UC-04: Theo dõi lịch sử nghỉ phép
- **Input**: id nhân viên, năm
- **Output**: tổng ngày đã nghỉ (Approved), số đơn Pending, số đơn Rejected

---

## Ghi chú kỹ thuật
- Supabase RLS cần được cấu hình: Sale chỉ SELECT/INSERT row của mình
- Dùng `DateTimeRange` của Flutter cho date picker
- Badge trạng thái dùng màu: Pending=`#F59E0B`, Approved=`#22C55E`, Rejected=`#EF4444`
