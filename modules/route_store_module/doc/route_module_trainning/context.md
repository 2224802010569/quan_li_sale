# BUSINESS CONTEXT

Module Route Store Management

---

# 1. Tổng quan nghiệp vụ

Đây là module quản lý:

* cửa hàng
* tuyến bán hàng
* phân công sale
* tuyến hỗ trợ

---

# 2. Vai trò người dùng

## Manager

Có quyền:

* CRUD cửa hàng
* CRUD tuyến
* gán sale cho tuyến đã được tạo
* điều chuyển hỗ trợ khi sale đang được phân công mà xin nghỉ phép
* sắp xếp thứ tự cửa hàng trong chi tiết tuyến 

## Sale

Có quyền:

* xem tuyến được phân công
* tìm kiếm cửa hàng
* xem chi tiết tuyến

---

# 3. Business Flow

## 3.1 Tạo cửa hàng

Manager nhập:

* tên cửa hàng
* địa chỉ
* GPS

Hệ thống:

* lưu database
* hiển thị trên map

---

# 3.2 Tạo tuyến

Manager:

* chọn nhiều cửa hàng(Có thanh tìm kiếm) 
* sắp xếp thứ tự ghé thăm 

Hệ thống:

* tạo Route
* tạo RouteDeatails

---

# 3.3 Gán tuyến

Manager:

* chọn tuyến
* chọn sale
* chọn thời gian

Hệ thống:

* tạo Assignment
* cập nhật realtime

---

# 3.4 Điều chuyển hỗ trợ

Manager:

* chọn sale hỗ trợ
* chọn tuyến cần hỗ trợ ( khi có sale xin nghỉ phép và tuyến đó bị trở thành tuyến hỗ trợ)

Hệ thống:

* tạo assignment:
  is_support = 2

---

# 3.5 Sale xem tuyến

Sale:

* xem tuyến được giao
* xem danh sách cửa hàng
* xem thứ tự di chuyển

---

# 4. Business Rules

## Store

* không xóa cứng
* chỉ hidden

---

## Route

* không xóa cứng
* chỉ hidden

---

## Assignment

* không trùng lịch
* hỗ trợ:
  is_support = 2

---

## Sorting

* tuyến có thứ tự cố định
* manager drag drop thay đổi

---

# 5. Search Rules

Sale có thể:

* tìm theo tên

---

# 6. Route Visualization

Hệ thống hiển thị:

* marker
* đường tuyến
* thứ tự ghé

---

# 7. Realtime Rules

Manager cập nhật:

* sale thấy ngay

---

# 8. Security Context

Manager:

* chỉ thấy dữ liệu thuộc mình

Sale:

* chỉ thấy tuyến được gán

---

# 9. Scalability

Thiết kế hỗ trợ:

* nhiều manager
* nhiều tuyến
* nhiều cửa hàng
* realtime đồng thời

---

# 10. Main Use Cases

* CRUD cửa hàng
* CRUD tuyến
* route sorting
* assignment
* support assignment
* route detail
* store search
