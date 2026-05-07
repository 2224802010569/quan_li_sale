# context.md — Bản đồ dự án & Leave_Module

## Vị trí trong hệ thống
Leave_Module là module số **6** trong 7 module của app quản lý Sales.

```
App (go_router)
 ├── User_Module         (đăng nhập → lưu session user)
 ├── Attendance_Module
 ├── Order_Module
 ├── Inventory_Module
 ├── Route_Store_Module
 ├── Leave_Module        ← ĐANG XÂY DỰNG
 └── KPI_Report_Module
```

## Luồng dữ liệu (Data Flow)

```
[Sale/Manager mở Leave_Module]
        │
        ▼
  input/ kiểm tra role
        │
   ┌────┴────────────┐
   │ Sale            │ Manager
   ▼                 ▼
view/sale_form    view/manager_list
(đăng ký nghỉ)   (duyệt đơn)
        │                 │
        ▼                 ▼
  logic_uc/         logic_uc/
  submit_leave      approve_leave
        │                 │
        ▼                 ▼
  logic_data/       logic_data/
  insert_leave      update_leave_status
        │                 │
        ▼                 ▼
   Supabase DB      Supabase DB
 (leave_requests) (leave_requests)
        │
        ▼
  output/ → event → App (thông báo / chuyển màn)
```

## Bảng Database liên quan

### `leave_requests` (bảng chính)
| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | bigint | PK, auto |
| user_id | uuid | FK → users |
| start_date | date | Ngày bắt đầu nghỉ |
| end_date | date | Ngày kết thúc nghỉ |
| reason | text | Lý do nghỉ |
| status | varchar | `Pending` / `Approved` / `Rejected` |
| approved_by | uuid | FK → users (Manager) |
| created_at | timestamp | Auto |
| data | jsonb | Metadata mở rộng |

### `assignments` (kiểm tra tuyến hỗ trợ)
| Cột | Kiểu | Ghi chú |
|---|---|---|
| user_id | uuid | Nhân viên được gán |
| route_id | bigint | Tuyến làm việc |
| is_support | int | 1=Chính, 2=Hỗ trợ, 3=Dự phòng |
| assigned_date | date | Ngày gán |

### `users` (thông tin nhân viên)
| Cột | Kiểu | Ghi chú |
|---|---|---|
| id | uuid | PK |
| full_name | varchar | Tên đầy đủ |
| role | varchar | `Manager` hoặc `Sale` |
| group_id | varchar | Nhóm (để Manager lọc cấp dưới) |

## Kết nối module khác
- **User_Module** → cung cấp `currentUser` (id, role, group_id) để Leave_Module dùng
- **Route_Store_Module** → Leave_Module đọc `assignments` để hiển thị tuyến bị ảnh hưởng khi nghỉ
- **KPI_Report_Module** → có thể đọc `leave_requests` để trừ ngày công

## Supabase config
- Project URL và anon key lưu trong `.env` (không commit)
- Dùng `supabase.from('leave_requests')` cho mọi CRUD
- Row Level Security (RLS): Sale chỉ thấy đơn của mình; Manager thấy đơn của cả group
