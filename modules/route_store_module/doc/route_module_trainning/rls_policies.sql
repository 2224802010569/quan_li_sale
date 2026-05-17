-- ============================================================
-- RLS (Row Level Security) cho Route Store Module
-- Chạy trên Supabase SQL Editor
-- ============================================================

-- 1. Enable RLS trên tất cả bảng
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Routes" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Route_Details" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Assignments" ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. STORES - Manager chỉ thấy stores của mình
-- ============================================================

-- Manager: CRUD stores thuộc manager_id = auth.uid()
CREATE POLICY "manager_stores_select" ON stores
  FOR SELECT USING (manager_id = auth.uid()::int);

CREATE POLICY "manager_stores_insert" ON stores
  FOR INSERT WITH CHECK (manager_id = auth.uid()::int);

CREATE POLICY "manager_stores_update" ON stores
  FOR UPDATE USING (manager_id = auth.uid()::int);

-- Sale: Xem stores được gán qua assignments
CREATE POLICY "sale_stores_select" ON stores
  FOR SELECT USING (
    id IN (
      SELECT rd.store_id FROM "Route_Details" rd
      JOIN "Assignments" a ON a.route_id = rd.route_id
      WHERE a.user_id = auth.uid()::text
    )
  );

-- ============================================================
-- 3. ROUTES - Manager chỉ thấy routes do mình tạo
-- ============================================================

CREATE POLICY "manager_routes_select" ON "Routes"
  FOR SELECT USING (created_by = auth.uid()::int);

CREATE POLICY "manager_routes_insert" ON "Routes"
  FOR INSERT WITH CHECK (created_by = auth.uid()::int);

CREATE POLICY "manager_routes_update" ON "Routes"
  FOR UPDATE USING (created_by = auth.uid()::int);

-- Sale: Xem routes được gán
CREATE POLICY "sale_routes_select" ON "Routes"
  FOR SELECT USING (
    route_id IN (
      SELECT route_id FROM "Assignments"
      WHERE user_id = auth.uid()::text
    )
  );

-- ============================================================
-- 4. ROUTE_DETAILS - Theo route access
-- ============================================================

CREATE POLICY "route_details_select" ON "Route_Details"
  FOR SELECT USING (
    route_id IN (
      SELECT route_id FROM "Routes"
      WHERE created_by = auth.uid()::int
    )
    OR
    route_id IN (
      SELECT route_id FROM "Assignments"
      WHERE user_id = auth.uid()::text
    )
  );

CREATE POLICY "route_details_modify" ON "Route_Details"
  FOR ALL USING (
    route_id IN (
      SELECT route_id FROM "Routes"
      WHERE created_by = auth.uid()::int
    )
  );

-- ============================================================
-- 5. ASSIGNMENTS - Manager tạo, Sale xem của mình
-- ============================================================

CREATE POLICY "manager_assignments_all" ON "Assignments"
  FOR ALL USING (
    route_id IN (
      SELECT route_id FROM "Routes"
      WHERE created_by = auth.uid()::int
    )
  );

CREATE POLICY "sale_assignments_select" ON "Assignments"
  FOR SELECT USING (user_id = auth.uid()::text);

-- ============================================================
-- LƯU Ý:
-- - auth.uid() trả về UUID của user đang login
-- - Cần cast sang đúng type (int hoặc text) tùy schema
-- - Nếu manager_id là UUID, bỏ ::int dùng ::uuid
-- - Test kỹ trên Supabase Dashboard trước khi deploy
-- ============================================================
