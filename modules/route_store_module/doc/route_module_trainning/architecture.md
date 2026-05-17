ROUTE STORE MODULE ARCHITECTURE

Module: Route + Store Management

1. Module Scope

Module này quản lý:

CRUD cửa hàng
CRUD tuyến bán hàng
Gán tuyến cho nhân viên sale
Điều chuyển tuyến hỗ trợ khi có trường hợp nhân viên nghỉ phép hoặc nghỉ đột xuất và đang được phân công tuyến nào đó
Sắp xếp lại các cửa hàng trong tuyến
Xem danh sách tuyến
Xem chi tiết tuyến
Tìm kiếm cửa hàng
Hiển thị bản đồ tuyến
2. Tech Stack
Frontend
Flutter
Riverpod
GoRouter
Flutter Map hoặc Google Maps
Supabase Flutter SDK

Backend
Supabase PostgreSQL
Supabase Realtime
Supabase Storage
Row Level Security
3. Clean Architecture

lib/
│
├── entity/
├── input/
├── logic_data/
├── logic_uc/
├── output/
└── view/

4. Main Entities
Store

Thông tin cửa hàng.

Fields:

id
store_name
address
latitude
longitude
manager_id
created_at
data

Route

Thông tin tuyến bán hàng.

Fields:

id
route_name
create_by
is_hidden
created_at
data

Route_details

Liên kết cửa hàng với tuyến.

Fields:

id
route_id
store_id
sequence
created_at
data

Assignment

Phân công tuyến.

Fields:

id
user_id
route_id
assigned_date
is_support
created_at
data

User

Thông tin sale / manager.

Fields:

id
full_name
phone
password
role
group_id
create_at
employee_code
last_updated
username
email
avatar_path

5. Database Relationships

Manager
→ nhiều Sale

Manager
→ nhiều Store

Manager
→ nhiều Route

Sale
→ nhiều Assignment

6. Main Features
6.1 Store Management

Manager:

tạo cửa hàng
sửa cửa hàng
ẩn cửa hàng
xem danh sách cửa hàng
xem trên map

Sale:

xem cửa hàng được phân công theo tuyến từ manager
tìm kiếm cửa hàng

6.2 Route Management

Manager:

tạo tuyến
chỉnh sửa tuyến
thêm cửa hàng vào tuyến
sắp xếp vị trí cửa hàng
ẩn tuyến

Sale:

xem tuyến của mình được phân công

6.3 Route Assignment

Manager:

gán tuyến cho sale
điều chuyển hỗ trợ khi có sale xin nghỉ phép lúc đang được phân công tuyến nào đó
cập nhật realtime

Rules:

sale không được nhận 2 tuyến trùng giờ

tuyến hỗ trợ:
is_support = 2

7. Realtime Design

Realtime tables:

assignments
routes

Use cases:

manager chỉnh tuyến
sale cập nhật tức thì
điều chuyển hỗ trợ realtime

8. UI Architecture
Manager Screens
Store List
Store Form
Route List
Route Detail
Route Assignment
Route Sort Screen

Sale Screens
Assigned Routes
Route Detail
Store Search
Route Map
9. Map Design

Map features:

marker cửa hàng
polyline tuyến
route preview
GPS display
10. State Management

Riverpod:

AsyncNotifier
StreamProvider
11. Navigation

GoRouter:

auth guard
role guard
12. Security

RLS:

manager chỉ thấy dữ liệu của họ
sale chỉ thấy tuyến được gán
13. Performance
pagination
indexed query
lazy loading
selective realtime

