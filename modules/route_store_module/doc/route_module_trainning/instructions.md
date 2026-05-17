# DEVELOPMENT INSTRUCTIONS

---

# 1. Architecture Rules

Bắt buộc:

* Clean Architecture
* Feature First
* SOLID

Không được:

* viết business logic trong UI

---

# 2. State Management

Use:

* Riverpod

Không dùng:

* GetX
* setState cho business state

---

# 3. Naming Convention

## File

snake_case.dart

## Class

PascalCase

## Variable

camelCase

---

# 6. Supabase Rules

Tất cả table:

* enable RLS

---

# 7. Realtime Rules

Realtime cho:

* routes
* assignments

---

# 8. CRUD Rules

Không hard delete:

* stores
* routes

Use:
is_hidden = true

---

# 9. Assignment Rules

Không cho:

* trùng lịch assignment

Support assignment:
is_support = 2

---

# 10. Sorting Rules

Store order:

* dùng sort_order
* drag and drop

---

# 11. Map Rules

Map phải hỗ trợ:

* marker
* polyline
* route preview

---

# 12. Search Rules

Search:

* store name
* store code

---

# 13. UI Rules

Design:

* hiện đại
* tối giản
* responsive

---

# 14. Error Handling

Always:

* loading state
* empty state
* error state

---

# 15. Logging

Use:
logger package

---

# 16. Performance

Use:

* pagination
* indexed query
* debounce search

---

# 17. Security

Never expose:

* service_role key

Flutter chỉ dùng:

* anon key

---

# 18. Testing

Required:

* repository tests
* assignment tests
* sorting tests

---

# 19. Recommended Packages

* flutter_riverpod
* go_router
* freezed
* json_serializable
* flutter_map
* latlong2
* geolocator
* logger
* intl
