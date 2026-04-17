-- =========================================================================
-- DEV MODE MOCK DATA SCRIPT
-- Run this in your Supabase SQL Editor to populate the DB with test constraints.
-- =========================================================================

-- 1. Khởi tạo User (1 Manager và 1 Sale trùng khớp với ID trong auth_wrapper.dart)
-- Lưu ý: id bắt buộc phải khớp với mockUserId khai báo bên file Flutter.
-- CHÚ Ý: Bổ sung group_id để test tính năng lọc theo khu vực cho Quản lý.
INSERT INTO public.users (id, full_name, employee_code, role, phone, password, group_id, last_updated)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Lê Văn Sale (DEV)', 'NV9999', 'Sale', '0999999001', 'password123', 'TEAM_HCM_01', NOW()),
  ('22222222-2222-2222-2222-222222222222', 'Trần Thị Manager (DEV)', 'QL9999', 'Manager', '0988888002', 'password123', 'TEAM_HCM_01', NOW()),
  ('33333333-3333-3333-3333-333333333333', 'Nguyễn Văn Nhờ (SALE KHÁC NHÓM)', 'NV8888', 'Sale', '0977777003', 'password123', 'TEAM_HN_02', NOW())
ON CONFLICT (id) DO UPDATE SET 
  role = EXCLUDED.role, 
  phone = EXCLUDED.phone,
  password = EXCLUDED.password,
  group_id = EXCLUDED.group_id,
  full_name = EXCLUDED.full_name;

-- 2. Tạo một Tuyến (Route)
INSERT INTO public.routes (id, route_name)
VALUES (999, 'Tuyến Mẫu - Cụm Q1')
ON CONFLICT (id) DO NOTHING;

-- 3. Đưa 3 cửa hàng mẫu vào Route đó
INSERT INTO public.stores (id, store_name, address, latitude, longitude)
VALUES
  (9901, 'Cửa hàng Tiện Lợi Alpha', '123 Lê Lợi', 10.7769, 106.7009),
  (9902, 'Siêu thị Mini Beta', '456 Nguyễn Huệ', 10.7745, 106.7025),
  (9903, 'Đại lý Sữa Gamma', '789 Đồng Khởi', 10.7780, 106.7011)
ON CONFLICT (id) DO NOTHING;

-- Liên kết tuyến với 3 cửa hàng bên trên
INSERT INTO public.route_details (route_id, store_id)
VALUES 
  (999, 9901),
  (999, 9902),
  (999, 9903)
ON CONFLICT DO NOTHING;

-- 4. Phân công tuyến 999 cho Sale chạy ngay trong NGÀY HÔM NAY 
INSERT INTO public.assignments (user_id, route_id, assigned_date)
VALUES ('11111111-1111-1111-1111-111111111111', 999, CURRENT_DATE)
ON CONFLICT DO NOTHING;

-- 5. Bơm thẳng 5 bản ghi Check-in mẫu NGÀY HÔM NAY để bypass test 'ĐỦ CÔNG' (>= 5 Checkins)
INSERT INTO public.attendance (user_id, store_id, route_id, status, created_at, checkin_time, checkout_time)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 9901, 999, 'Completed', NOW() - INTERVAL '5 hours', NOW() - INTERVAL '5 hours', NOW() - INTERVAL '4 hours 30 mins'),
  ('11111111-1111-1111-1111-111111111111', 9902, 999, 'Completed', NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours', NOW() - INTERVAL '3 hours 30 mins'),
  ('11111111-1111-1111-1111-111111111111', 9903, 999, 'Completed', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '2 hours 30 mins'),
  ('11111111-1111-1111-1111-111111111111', 9901, 999, 'Completed', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hours 30 mins'),
  ('11111111-1111-1111-1111-111111111111', 9902, 999, 'Completed', NOW() - INTERVAL '1 hours', NOW() - INTERVAL '1 hours', NOW() - INTERVAL '30 minutes')
ON CONFLICT DO NOTHING;

-- Done!