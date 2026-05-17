# TODO LIST

Route Store Module


# PHASE 1 - STORE FEATURE

## Manager

* [x] Create store
* [x] Edit store
* [x] Hide store (soft delete - is_hidden)
* [x] Store list
* [x] Store map

## Sale

* [x] Search store
* [x] Store detail

---

# PHASE 2 - ROUTE FEATURE

## Manager

* [x] Create route
* [x] Edit route
* [x] Hide route (soft delete - is_hidden)
* [x] Add stores to route
* [x] Remove stores from route

## Shared

* [x] Route detail
* [x] Route map
* [x] Route preview

---

# PHASE 3 - ROUTE SORTING

* [x] Drag drop sorting (UC + Data layer)
* [x] Update sort_order (sequence)
* [x] Save sorted route

---

# PHASE 4 - ASSIGNMENT

## Manager

* [x] Assign route
* [x] Reassign route
* [x] Support assignment (is_support = 2)
* [x] Assignment validation (trùng lịch)

## Sale

* [x] View assigned routes

---

# PHASE 5 - REALTIME

* [x] Realtime routes (StreamProvider)
* [x] Realtime assignments (StreamProvider)
* [x] Realtime route updates

---

# PHASE 6 - MAP

* [x] Store markers
* [x] Route polyline
* [x] GPS display

---

# PHASE 7 - SEARCH

* [x] Search by store name

---

# PHASE 8 - SECURITY

* [x] Enable RLS (SQL file created)
* [x] Manager isolation
* [x] Sale assignment access

---

# PHASE 9 - TESTING

* [ ] Sorting tests
* [ ] Assignment conflict tests

---

# PHASE 12 - OPTIMIZATION

* [ ] Pagination
* [ ] Lazy loading
