# Update UI — Ska Milk App
> Tài liệu cập nhật giao diện dựa trên thiết kế mới. Áp dụng toàn bộ theo Design System **Marine Precision**.

---

## 1. Design System — Nền tảng chung

### 1.1 Font
```
Font chính: "Be Vietnam Pro" (Google Fonts)
Import: @import url('https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap');
font-family: 'Be Vietnam Pro', sans-serif;
```

| Token | Size | Weight | Line Height | Letter Spacing |
|---|---|---|---|---|
| `headline-lg` | 24px | 700 | 32px | -0.02em |
| `headline-md` | 20px | 600 | 28px | — |
| `headline-sm` | 18px | 600 | 24px | — |
| `body-lg` | 16px | 400 | 24px | — |
| `body-md` | 14px | 400 | 20px | — |
| `label-lg` | 14px | 600 | 20px | 0.05em |
| `label-md` | 12px | 500 | 16px | — |
| `caption` | 11px | 400 | 14px | — |

---

### 1.2 Color Tokens (CSS Variables)
```css
:root {
  /* Backgrounds */
  --surface:                 #f8f9ff;
  --surface-dim:             #cbdbf5;
  --surface-container-lowest:#ffffff;
  --surface-container-low:   #eff4ff;
  --surface-container:       #e5eeff;
  --surface-container-high:  #dce9ff;
  --surface-container-highest:#d3e4fe;
  --background:              #f8f9ff;

  /* Text */
  --on-surface:              #0b1c30;
  --on-surface-variant:      #434750;
  --inverse-on-surface:      #eaf1ff;

  /* Primary */
  --primary:                 #002556;
  --on-primary:              #ffffff;
  --primary-container:       #0d3b7a;
  --on-primary-container:    #84a7ed;
  --inverse-primary:         #acc7ff;

  /* Secondary / Action */
  --secondary:               #0051d5;
  --on-secondary:            #ffffff;
  --secondary-container:     #316bf3;
  --on-secondary-container:  #fefcff;

  /* Tertiary / Dark */
  --tertiary:                #1a2837;
  --tertiary-container:      #303e4e;
  --on-tertiary-container:   #9aa9bc;

  /* Semantic */
  --error:                   #ba1a1a;
  --on-error:                #ffffff;
  --error-container:         #ffdad6;

  /* Outline */
  --outline:                 #747781;
  --outline-variant:         #c3c6d2;
  --surface-tint:            #395d9e;
  --surface-variant:         #d3e4fe;
}
```

---

### 1.3 Spacing & Radius
```css
:root {
  --container-margin: 1rem;       /* 16px — margin hai bên màn hình */
  --stack-gap:        0.75rem;    /* 12px — khoảng cách giữa các block */
  --card-padding:     1.25rem;    /* 20px — padding bên trong card */
  --grid-gutter:      1rem;       /* 16px — gutter giữa các cột */
  --touch-target:     2.75rem;    /* 44px — chiều cao tối thiểu button/row */

  --radius-sm:        0.25rem;    /* 4px */
  --radius:           0.5rem;     /* 8px — input, tag, button nhỏ */
  --radius-md:        0.75rem;    /* 12px */
  --radius-lg:        1rem;       /* 16px — card */
  --radius-xl:        1.5rem;     /* 24px — bottom sheet, modal */
  --radius-full:      9999px;     /* pill */
}
```

---

### 1.4 Shadows (Elevation)
```css
/* Level 1 — Card */
box-shadow: 0px 4px 12px rgba(13, 59, 122, 0.06);

/* Level 2 — Button / Input active */
box-shadow: 0px 6px 16px rgba(13, 59, 122, 0.12);

/* Level 3 — Modal / Picker */
box-shadow: 0px 12px 32px rgba(13, 59, 122, 0.18);
```

---

### 1.5 Global App Shell
```
Background page:      var(--background)   → #f8f9ff
Header bar:           background #ffffff, no shadow, border-bottom: none
  - Logo text "Ska Milk": font headline-md, color var(--primary) #002556, font-weight 700
  - Hamburger icon (☰): color var(--on-surface)
  - Bell icon (🔔): color var(--on-surface)
Header height:        56px
Side padding:         16px (var(--container-margin))
```

---

## 2. Màn hình theo từng Screen

---

### Screen 1 — Trang chủ / Dashboard (Home)
**File liên quan:** `HomeScreen`, `DashboardScreen`

#### Header
```
Greeting: "Chào buổi sáng, [Tên]"  → body-md, color var(--on-surface-variant)
Title: "Lộ trình hôm nay"           → headline-md, color var(--on-surface)
Avatar: ảnh tròn 40x40px, border 2px solid #4ade80 (online indicator)
```

#### Card — Lộ trình đang diễn ra
```
Background: #ffffff
Border-radius: var(--radius-lg) → 16px
Shadow: Level 1
Padding: var(--card-padding) → 20px

  Chip "ĐANG DIỄN RA":
    background: var(--surface-container) #e5eeff
    color: var(--secondary) #0051d5
    font: label-md, font-weight 500
    border-radius: var(--radius-full)
    padding: 4px 10px

  Title tuyến: headline-sm, color var(--on-surface)
  Sub-text "[0/4] Cửa hàng đã hoàn thành": body-md, color var(--on-surface-variant)

  Play button (▶):
    width: 48px, height: 48px
    background: var(--secondary) #0051d5
    border-radius: var(--radius-full)
    icon màu #ffffff

  Progress bar:
    Label "Tiến độ" + "0%": label-md, color var(--on-surface-variant)
    Track: height 6px, background var(--surface-container-high) #dce9ff, radius 3px
    Fill: background var(--secondary) #0051d5
```

#### Stats Row (2 cột)
```
Card trái — Khách hàng mới:
  Icon: 🏪 màu var(--secondary)
  Số: headline-md 700, color var(--on-surface)
  Label: caption, color var(--on-surface-variant)

Card phải — Doanh số:
  Icon: 📋 màu #16a34a (green)
  Số: headline-md 700, color var(--on-surface)
  Label: caption, color var(--on-surface-variant)

Layout: 2 cột equal, gap var(--grid-gutter), border-radius var(--radius-lg), shadow Level 1
```

#### Bản đồ lộ trình
```
Section header:
  "Bản đồ lộ trình": headline-sm, color var(--on-surface)
  "Chi tiết" link: label-lg, color var(--secondary)

Map container:
  border-radius: var(--radius-lg)
  overflow: hidden
  height: ~180px
  Route line: stroke var(--primary) #002556, stroke-width 3
  Waypoint dots: fill var(--secondary) #0051d5
```

#### Hoạt động gần đây
```
Section header: headline-sm
Mỗi row:
  Icon container: 40x40px, background var(--surface-container-low), border-radius var(--radius-md)
  Title: body-md 600, color var(--on-surface)
  Sub-text: caption, color var(--on-surface-variant)
  Timestamp: caption, color var(--on-surface-variant), align right
  Separator: 1px solid var(--outline-variant) #c3c6d2
```

---

### Screen 2 — Cửa hàng chi tiết (Store Detail / Check-in screen)
**File liên quan:** `StoreDetailScreen`

#### Header Card — Tên shop + địa chỉ
```
Layout: full-width card
  Badge "ACTIVE": 
    background #dcfce7 (green-100)
    color #16a34a (green-600)
    border-radius: var(--radius-full)
    font: label-md

  Tên shop: headline-md, color var(--on-surface)
  Địa chỉ: body-md, color var(--on-surface-variant), icon 📍 var(--secondary)
```

#### Doanh số Banner
```
Background: var(--primary-container) #0d3b7a  (dark navy)
Border-radius: var(--radius-lg)
Padding: 20px

  Label "DOANH SỐ TẠI ĐIỂM HÔM NAY": label-lg, color rgba(255,255,255,0.7), text-transform uppercase
  Số tiền: 28px, font-weight 700, color #ffffff
  Trend chip "+12%...":
    background rgba(255,255,255,0.15)
    color #ffffff
    icon 📈
    border-radius var(--radius-full)
    font: label-md
```

#### CTA — Lên đơn hàng
```
Button:
  background: var(--secondary) #0051d5
  color: #ffffff
  height: 52px
  border-radius: var(--radius-lg)
  font: label-lg, text-transform uppercase
  icon: 🛒 trắng
  width: 100%
  shadow: Level 2
```

#### Quick Actions (2 nút)
```
2 nút ngang nhau:

  "Kiểm tồn kho" (trái):
    background: var(--surface-container-low) #eff4ff
    color: var(--on-surface)
    border: none
    icon: 📋

  "Checkout - END VISIT" (phải):
    background: #fff0f0 (đỏ nhạt)
    color: var(--error) #ba1a1a
    border: none
    icon: 🚪

Cả hai: height 64px, border-radius var(--radius-lg), font label-md
```

#### Đơn hàng gần đây
```
Section header: "ĐƠN HÀNG GẦN ĐÂY" → label-lg uppercase + "Xem tất cả" link secondary

Mỗi row:
  Icon: 📄 trong box 36x36px, background var(--surface-container), radius var(--radius-sm)
  Mã đơn: body-md 600
  Thời gian + số SP: caption, color var(--on-surface-variant)
  Số tiền: body-md 600, color var(--on-surface), align right
  Status badge:
    - "ĐÃ XÁC NHẬN": green background/text
    - "ĐANG XỬ LÝ": orange background/text (#f97316)
    - "ĐÃ HOÀN TẤT": blue background/text
    border-radius: var(--radius-full), padding 3px 8px, font label-md
```

#### Toast notification
```
"Check-in thành công!" toast:
  background: var(--tertiary) #1a2837  (dark)
  color: #ffffff
  icon: ✅ xanh lá (#4ade80)
  border-radius: var(--radius-full)
  padding: 12px 20px
  position: fixed bottom 24px, centered
  shadow: Level 2
```

---

### Screen 3 — Lộ trình / Route Detail
**File liên quan:** `RouteDetailScreen`

#### Header
```
Title: "Tuyến [Tên]" — headline-lg, icon 🗺️ var(--secondary)
Sub: "Hành trình bán hàng hằng ngày" — body-md, color var(--on-surface-variant)
```

#### Agent Info Card
```
Background: #ffffff, shadow Level 1, radius var(--radius-lg)
  Avatar: 48x48px tròn + dot xanh lá (online)
  "Nhân viên phụ trách": caption, color var(--on-surface-variant)
  Tên: body-lg 600, color var(--on-surface)
  
  Badge "Chính thức":
    background: var(--surface-container) #e5eeff
    color: var(--secondary) #0051d5
    radius: var(--radius-full)
    font: label-md

  "ID: SKM-992": label-md, color var(--on-surface-variant), icon 💳

  Phone button:
    width: 40px, height: 40px
    background: var(--surface-container-low)
    border-radius: var(--radius-full)
    icon: 📞 var(--secondary)
```

#### Timeline — Lộ trình cửa hàng
```
Section header: "Lộ trình cửa hàng" + Badge "4 Cửa hàng":
  Badge: background var(--surface-container), radius var(--radius-full), font label-md

Timeline connector:
  Line: 2px solid var(--primary) #002556
  Step circle: 32x32px, background var(--primary), color #ffffff, font label-lg bold, radius full

Mỗi store card:
  Background: #ffffff, shadow Level 1, radius var(--radius-lg)
  Padding: 16px
  
  Tên shop: body-lg 600
  Địa chỉ: body-md, color var(--on-surface-variant)
  "Cách X m": label-md, color var(--secondary), icon 📍
  
  Check-In button:
    background: var(--primary-container) #0d3b7a
    color: #ffffff
    border-radius: var(--radius-md)
    padding: 10px 16px
    font: label-lg
    icon: ✓
    min-width: 90px
```

---

### Screen 4 — Danh sách cửa hàng
**File liên quan:** `StoreListScreen`

#### Header
```
Title: "Cửa hàng" — headline-lg
Icon refresh (🔄): top-right, color var(--on-surface)
```

#### Search Bar
```
Background: #ffffff
Border: 1px solid var(--outline-variant) #c3c6d2
Border-radius: var(--radius-lg)
Height: 48px
Icon: 🔍 var(--on-surface-variant)
Placeholder: body-md, color var(--on-surface-variant)
Focus: border-color var(--secondary), box-shadow 0 0 0 2px rgba(0,81,213,0.15)
```

#### Stats Cards (2 cột)
```
Card trái — Tổng cửa hàng:
  background: var(--primary) #002556
  color: #ffffff
  Icon: 🏪 (trắng, mờ)
  Label: caption uppercase, color rgba(255,255,255,0.7)
  Số: headline-md 700

Card phải — Đã viếng thăm:
  background: var(--surface-container-low) #eff4ff
  Icon: ✅ var(--secondary)
  Label: caption, color var(--on-surface-variant)
  Số "42/128": headline-md 700, color var(--secondary)

Cả hai: border-radius var(--radius-lg), padding 16px, height ~90px
```

#### Store List Item
```
Mỗi card:
  Background: #ffffff, shadow Level 1, radius var(--radius-lg), margin-bottom 8px
  Padding: 16px

  Tên: body-lg 600, color var(--on-surface)
  Địa chỉ: body-md, color var(--on-surface-variant), icon 📍
  Tọa độ: 
    background var(--surface-container-low)
    border-radius var(--radius-full)
    font caption
    icon 📡 var(--secondary)
    display: inline-flex

  Badge trạng thái (right):
    - "Cửa hàng trọng điểm": color var(--secondary), font label-md
    - "NỢ QUÁ HẠN": background #fef2f2, color var(--error), border-radius full, font label-md uppercase
    - "KHÁCH HÀNG MỚI": background var(--surface-container), color var(--secondary), border-radius full

  Menu (⋮): icon var(--on-surface-variant), top-right
```

---

### Screen 5 — Danh sách nhân sự
**File liên quan:** `StaffListScreen`

#### Header
```
Title: "Danh sách nhân sự" — headline-lg
Sub: "Quản lý đội ngũ nhân viên của bạn" — body-md, color var(--on-surface-variant)
```

#### Search Bar — giống Screen 4

#### Filter Chips (tabs)
```
Chip active:
  background: var(--primary) #002556
  color: #ffffff
  border-radius: var(--radius-full)
  padding: 8px 16px
  font: label-lg

Chip inactive:
  background: #ffffff
  color: var(--on-surface)
  border: 1px solid var(--outline-variant)
  border-radius: var(--radius-full)

Gap giữa chips: 8px
```

#### Staff List Item
```
Background: #ffffff, shadow Level 1, radius var(--radius-lg), padding 16px

  Avatar: 48x48px tròn
    - Dot online: 10x10px, background #4ade80, border 2px white
    - Dot offline: #fbbf24 (amber)
  Tên: body-lg 600
  SĐT: body-md, icon 📞, color var(--on-surface-variant)
  
  Delete icon (🗑️): color var(--error), right side
  Chevron (›): color var(--on-surface-variant)
```

#### FAB — Thêm nhân viên
```
Position: fixed bottom, full-width floating button
Background: var(--primary) #002556
Color: #ffffff
Height: 52px
Border-radius: var(--radius-lg)
Font: label-lg
Icon: 👤+ 
Shadow: Level 3
Margin: 0 16px 24px
```

---

### Screen 6 — Profile / Hồ sơ
**File liên quan:** `ProfileScreen`

#### Header Card
```
Background: #ffffff, shadow Level 1, radius var(--radius-lg)
Text-align: center
Padding: 24px 20px

  Tên công ty: label-lg uppercase, color var(--on-surface-variant), letter-spacing 0.05em
  Slogan: caption, color var(--on-surface-variant)

  Avatar circle: 80x80px
    Nếu không có ảnh: chữ cái đầu, background var(--surface-container-high), font 32px 700
    Edit button: 28x28px, background var(--secondary), icon ✏️ #ffffff, position bottom-right của avatar

  Tên: headline-sm 600
  Badge role:
    background: var(--secondary) #0051d5
    color: #ffffff
    border-radius: var(--radius-full)
    font: label-md
    padding: 4px 12px
```

#### Info Fields
```
Mỗi field row:
  Border-bottom: 1px solid var(--outline-variant)
  Padding: 14px 0
  
  Icon: 20x20px, color var(--secondary)
  Label: body-md, color var(--on-surface-variant)
  Giá trị: body-md 500, color var(--on-surface), align right
```

#### Action Buttons
```
"Chỉnh sửa":
  background: var(--surface-container-low) #eff4ff
  color: var(--secondary) #0051d5
  border: none
  icon: ✏️
  height: 50px, radius var(--radius-lg), width 100%

"Đăng xuất":
  background: transparent
  color: var(--error) #ba1a1a
  border: 1px solid #fecaca
  icon: 🚪
  height: 50px, radius var(--radius-lg), width 100%
```

#### Stats Footer
```
2 cột:
  "150+": headline-sm, color var(--secondary)
  "Đơn hàng tháng này": caption, color var(--on-surface-variant)

  "98%": headline-sm, color var(--secondary)
  "Hiệu suất KPI": caption, color var(--on-surface-variant)
```

---

### Screen 7 — Kiểm tồn kho (Empty State)
**File liên quan:** `InventoryScreen`

#### Header
```
Back button (←): icon var(--on-surface), no background
Title: "Kiểm tồn kho" — headline-sm
Add button (+): icon var(--secondary), font-size 22px
```

#### Empty State
```
Container: centered, padding top 80px

  Illustration card:
    width: 120px, height: 120px
    background: #ffffff
    border-radius: var(--radius-xl) 24px
    shadow: Level 2
    icon kho: 64x64px, color var(--outline-variant)
    
    QR badge (overlap bottom-right):
      background: var(--secondary) #0051d5
      border-radius: var(--radius-md)
      width: 52px, height: 52px
      icon QR: #ffffff

  Text: "Chưa có sản phẩm nào" — headline-sm, color var(--on-surface)
  Sub: body-md, color var(--on-surface-variant), text-align center
```

---

### Screen 8 — Lịch sử đơn hàng
**File liên quan:** `OrderHistoryScreen`

#### Header
```
Back (←) + Title "Lịch sử đơn hàng" + Bell (🔔)
Background: #ffffff
```

#### Filter — Nhân viên
```
Label "LỌC NHÂN VIÊN": label-lg uppercase
Dropdown:
  background: #ffffff
  border: 1px solid var(--outline-variant)
  border-radius: var(--radius-lg)
  height: 48px
  font: body-md
  icon: ▼ var(--on-surface-variant)
```

#### Period Tabs
```
Giống filter chips Screen 5
Active: background var(--primary), text white
Inactive: background transparent, border var(--outline-variant)
```

#### Order Card
```
Background: #ffffff, shadow Level 1, radius var(--radius-lg)
Padding: 16px
Margin-bottom: 8px

  Header:
    Icon 📋 trong box 36x36, background var(--surface-container), radius var(--radius-sm)
    Mã đơn "#12": body-lg 600
    Tổng tiền: body-lg 600, color var(--on-surface), align right

  Detail rows (mỗi dòng):
    Icon nhỏ: caption, color var(--secondary)
    Text: body-md, color var(--on-surface-variant)
    Gap: 6px between rows
    
  Icons sử dụng: 📅 ngày giờ, 🏪 cửa hàng, 👤 nhân viên
```

---

### Screen 9 — Lên đơn hàng (Create Order)
**File liên quan:** `CreateOrderScreen`

#### Header
```
Back (←) + Title "Lên đơn hàng"
```

#### Product List Section
```
Label "DANH SÁCH SẢN PHẨM": label-lg uppercase, color var(--on-surface-variant)
"+ Thêm sản phẩm" link: label-lg, color var(--secondary)

Empty state container:
  background: var(--surface-container-low) #eff4ff
  border: 1.5px dashed var(--outline-variant) #c3c6d2
  border-radius: var(--radius-lg)
  padding: 32px
  text-align: center

  Icon kho: 48px, color var(--outline-variant)
  Text gợi ý: body-md, có **bold** inline
```

#### In hóa đơn tạm tính
```
Button:
  background: transparent
  border: 1.5px solid var(--secondary) #0051d5
  color: var(--secondary)
  height: 50px
  border-radius: var(--radius-full)
  icon: 🖨️
  font: label-lg
  width: 100%
```

#### Chụp hình đơn hàng
```
Label "CHỤP HÌNH ĐƠN HÀNG": label-lg uppercase

Status badge "Chưa chụp":
  background: #fef2f2
  color: var(--error)
  border-radius: var(--radius-full)
  font: label-md
  dot đỏ trước text

Camera container:
  background: var(--primary) #002556 (dark navy)
  border-radius: var(--radius-lg)
  padding: 40px 20px
  min-height: 200px
  text-align: center

  Camera icon circle: 64x64px, background rgba(255,255,255,0.2), icon 📷 trắng
  Text: body-md, color rgba(255,255,255,0.8)
  
  "Bắt đầu chụp" button:
    background: rgba(255,255,255,0.2)
    border: 1px solid rgba(255,255,255,0.4)
    color: #ffffff
    border-radius: var(--radius-lg)
    padding: 10px 20px
    icon: 📷
```

#### Bottom Summary Bar
```
Background: #ffffff
Border-top: 1px solid var(--outline-variant)
Padding: 12px 16px
Display: flex, space-between

"Tổng tiền dự kiến": label-md
"0 đ": body-lg 600

"Sản phẩm": label-md  
"0": body-lg 600
```

---

### Screen 10 — Quản lý tuyến (Route Management)
**File liên quan:** `RouteManagementScreen`

#### Header
```
Hamburger + Title "Quản lý tuyến" + icons (🔄 🔔)
```

#### Search Bar — giống Screen 4

#### Filter Bar
```
"Tất cả lộ trình" label + filter icon (⊟): label-lg
```

#### Route Card
```
Background: #ffffff, shadow Level 1, radius var(--radius-lg)
Padding: 16px, margin-bottom: 12px

  Header row:
    Tên tuyến: body-lg 600
    Badge "ASSIGNED":
      background var(--surface-container) #e5eeff
      color var(--secondary)
      border-radius full, font label-md
    Delete icon 🗑️: var(--error)

  Schedule: caption, icon 🕐, color var(--on-surface-variant)

  Agent row:
    Avatar circle: 32x32px, background var(--surface-container-high), chữ cái đầu, font label-lg
    Tên: body-md 600
    Role: caption, color var(--on-surface-variant)

  Progress:
    Label "Tiến độ viếng thăm" + "75%": label-md
    Track: height 6px, background var(--surface-container-high), radius 3px
    Fill: var(--secondary) #0051d5

  Action buttons (2 cột):
    "Sửa":
      background: transparent
      border: 1px solid var(--outline-variant)
      color: var(--on-surface)
      icon: ✏️
      height: 40px, radius var(--radius-md)
    
    "Phân công":
      background: var(--primary) #002556
      color: #ffffff
      icon: 👤
      height: 40px, radius var(--radius-md)

Create new placeholder:
  background: var(--surface-container-low)
  border: 1.5px dashed var(--outline-variant)
  border-radius: var(--radius-lg)
  text-align: center, padding 24px
  icon 🛣️ + text: color var(--on-surface-variant)
```

#### FAB (+)
```
Position: fixed, bottom-right 24px
Width/Height: 52px, border-radius full
Background: var(--primary) #002556
Icon: + màu trắng, font-size 24px
Shadow: Level 3
```

---

### Screen 11 — Quản lý công việc / Check-in History
**File liên quan:** `TaskManagementScreen`

#### Filter header (giống Screen 8) + Period chips

#### Info Banner
```
Background: var(--surface-container-low) #eff4ff
Border-radius: var(--radius-lg)
Padding: 14px 16px
Display: flex, align-center

Icon: 👥 var(--secondary), 40x40px
Text: body-md 600, color var(--secondary)
```

#### History Card
```
Background: #ffffff, shadow Level 1, radius var(--radius-lg)
Overflow: hidden, margin-bottom 12px

  Image strip:
    Height: ~140px
    2 ảnh: left CHECK-IN, right CHECK-OUT
    Badge overlay:
      "CHECK-IN": background rgba(0,0,0,0.6), color white, font label-md, uppercase
      "CHECK-OUT": background var(--secondary), color white, font label-md
      position: top-left/top-right, padding 4px 8px, radius 0 0 8px 0

  Content area: padding 12px 16px
    Tên cửa hàng: body-lg 600
    Timestamp: body-md, color var(--secondary), align right (bold)
    
    Tuyến: caption, icon 📍, color var(--on-surface-variant)
    
    Agent: avatar 24px tròn + tên: body-md
    
    Status badge:
      "HOÀN TẤT": background #dcfce7, color #16a34a, radius full
      "PENDING": background #fef2f2, color var(--error), radius full
      font: label-md

  Refresh button (nếu PENDING):
    FAB nhỏ: 40x40, background var(--primary), icon 🔄 trắng, shadow Level 2, bottom-right của card
```

---

### Screen 12 — Báo cáo nghỉ phép
**File liên quan:** `LeaveReportScreen`

#### Header
```
Title: "Báo cáo nghỉ phép nhân viên" — headline-lg
Sub: "Chọn nhân viên và năm để xem thống kê" — body-md, color var(--on-surface-variant)
```

#### Dropdown — Nhân viên
```
Label "NHÂN VIÊN": label-lg uppercase, color var(--on-surface-variant)
Select:
  background: #ffffff
  border: 1px solid var(--outline-variant)
  border-radius: var(--radius-lg)
  height: 52px
  padding: 0 16px
  font: body-lg
  icon ▼: var(--on-surface-variant)
  
Focus: border var(--secondary), box-shadow 0 0 0 2px rgba(0,81,213,0.15)
```

#### Year Selector
```
Label "NĂM": label-lg uppercase

3 pill buttons ngang:
  Active:
    background: var(--primary) #002556
    color: #ffffff
    border-radius: var(--radius-full)
    padding: 10px 28px
    font: label-lg

  Inactive:
    background: #ffffff
    border: 1px solid var(--outline-variant)
    color: var(--on-surface)
    border-radius: var(--radius-full)
```

#### Stats Row (3 cột)
```
Mỗi stat card:
  Background: #ffffff, shadow Level 1, radius var(--radius-lg)
  Padding: 12px
  Text-align: center

  Label: caption uppercase, color var(--on-surface-variant)
  Số:
    - Ngày đã nghỉ: headline-sm 700, color var(--on-surface)
    - Đang chờ: headline-sm 700, color var(--secondary) #0051d5
    - Từ chối: headline-sm 700, color var(--error) #ba1a1a
  Unit: caption "ngày"/"đơn"
```

#### Tổng ngày nghỉ Card
```
Background: #ffffff, shadow Level 1, radius var(--radius-lg)
Padding: 20px
Margin-top: 12px

  Label "TỔNG NGÀY NGHỈ ĐƯỢC DUYỆT": label-lg uppercase, text-align center, color var(--on-surface-variant)

  Content row:
    Circle chart: 64x64px
      Stroke track: var(--surface-container-high), stroke-width 6
      Stroke fill: var(--secondary), stroke-width 6
      Text bên trong: headline-sm 700

    Bên phải:
      "Ngày": headline-md 700
      "Năm X • Y đơn đã duyệt": body-md, color var(--on-surface-variant)

  CTA button "+ Tạo đơn nghỉ phép mới":
    background: var(--primary) #002556
    color: #ffffff
    height: 52px, border-radius var(--radius-xl), width 100%
    font: label-lg
    icon: +
    shadow: Level 2
    margin-top: 16px
```

### Screen 13 — Đăng ký nghỉ phép (Leave Form)
**File liên quan:** `LeaveFormView`

#### Header
```
Greeting / Back button: Back icon (←) var(--on-surface)
Title: "Đăng ký nghỉ phép" — headline-lg, color var(--primary)
Status badge "Đang chờ":
  background: var(--surface-container-low)
  color: var(--on-surface-variant)
  dot màu cam (#F59E0B) ở trước text
  border-radius: var(--radius-full), font label-md
```

#### Form Card
```
Background: #ffffff, shadow Level 1, radius var(--radius-lg) (16px)
Padding: 24px (hoặc var(--card-padding))

  Nhãn phần (LÝ DO NGHỈ, NGÀY BẮT ĐẦU, NGÀY KẾT THÚC):
    label-lg, uppercase, color var(--on-surface-variant)

  Trường nhập lý do (Lý do nghỉ):
    background: var(--surface-container-low) #eff4ff
    border: 1px solid var(--outline-variant)
    radius: var(--radius) 8px
    style chữ: body-lg, color var(--on-surface)
    hint: "Nhập lý do chi tiết..." — color var(--on-surface-variant)

  Trường chọn ngày (Bắt đầu / Kết thúc):
    background: var(--surface-container-low) #eff4ff
    border: 1px solid var(--outline-variant)
    radius: var(--radius) 8px
    style chữ: body-lg, color var(--on-surface)
    icon lịch: 📅 var(--secondary) ở bên phải

  Nút "Gửi đơn":
    background: var(--primary) #002556 (hoặc gradient var(--primary) -> var(--primary-container))
    color: #ffffff
    height: 52px, radius var(--radius-lg)
    font: label-lg, font-weight 700
    shadow: Level 2
```

#### Bottom Row — Thông tin chính sách & Số ngày nghỉ còn lại
```
Bố cục: 2 cột (hoặc hàng ngang linh hoạt)

  Card trái — Quy định nghỉ phép:
    background: var(--primary-container) #0d3b7a
    radius: var(--radius-xl) 24px
    padding: var(--card-padding) 20px
    
    Tiêu đề "Quy định nghỉ phép": headline-sm, color #ffffff
    Nội dung chính sách: body-md, color var(--inverse-primary) #acc7ff
    Link "Chi tiết chính sách": label-md, color #ffffff, icon 🔗

  Card phải — Ngày phép còn lại:
    background: var(--surface-container) #e5eeff
    radius: var(--radius-lg) 16px
    padding: 20px
    text-align: center
    
    Số ngày "12": 36px, font-weight 900, color var(--secondary) #0051d5
    Nhãn "NGÀY PHÉP CÒN LẠI": label-md uppercase, color var(--on-surface-variant)
```

---

### Screen 14 — Thiết lập chỉ tiêu KPI (KPI Setup)
**File liên quan:** `kpi_module` — màn hình Manager thiết lập KPI cho nhân viên

#### Header
```
Back button: icon ← var(--on-surface)
Title: "Thiết lập chỉ tiêu" — headline-lg, color var(--primary) #002556
Sub: "Phân bổ mục tiêu kinh doanh cho đội ngũ nhân sự. Dữ liệu sẽ được đồng bộ hóa với hệ thống báo cáo hiệu suất thời gian thực."
  → body-md, color var(--on-surface-variant), max 2-3 dòng
```

#### Form Card — Thông tin nhân viên & Thời gian
```
Background: #ffffff
Border-radius: var(--radius-lg) 16px
Shadow: Level 1
Padding: var(--card-padding) 20px
Margin: 16px

  Section header:
    Left border accent: 3px solid var(--secondary) #0051d5
    Text "Thông tin nhân viên & Thời gian": headline-sm, color var(--on-surface)

  --- Field: NHÂN VIÊN ---
  Label "NHÂN VIÊN": label-lg uppercase, color var(--on-surface-variant)
  Dropdown:
    background: var(--surface-container-low) #eff4ff
    border: 1px solid var(--outline-variant)
    border-radius: var(--radius-lg)
    height: 52px
    padding: 0 16px
    font: body-lg, color var(--on-surface)
    icon ▼: var(--on-surface-variant), align right
    Focus: border var(--secondary), box-shadow 0 0 0 2px rgba(0,81,213,0.15)

  --- Field: THÁNG/NĂM ---
  Label "THÁNG/NĂM": label-lg uppercase, color var(--on-surface-variant)
  2 cột ngang (gap 12px):
    Dropdown Tháng (trái, flex 1):
      Hiển thị "Tháng X" (X = tháng hiện tại)
      Cùng style dropdown trên
    Dropdown Năm (phải, flex 1):
      Hiển thị "Năm XXXX"
      Cùng style dropdown trên

  --- Field: DOANH SỐ MỤC TIÊU ---
  Label "DOANH SỐ MỤC TIÊU": label-lg uppercase, color var(--on-surface-variant)
  Input row:
    background: var(--surface-container-low) #eff4ff
    border: 1px solid var(--outline-variant)
    border-radius: var(--radius-lg)
    height: 52px
    Input số: body-lg, color var(--on-surface), flex 1
    Suffix "VND": label-lg, color var(--on-surface-variant), padding-right 16px
    keyboardType: numeric
    hint "0": color var(--on-surface-variant)
```

#### Button — Lưu chỉ tiêu
```
Text: "Lưu chỉ tiêu"
Background: var(--primary) #002556
Color: #ffffff
Height: 52px
Border-radius: var(--radius-xl) 24px (pill shape)
Width: 100%
Font: label-lg, font-weight 700
Shadow: Level 2
Margin-top: 24px
Press state: scale(0.98), opacity 0.92, transition 80ms
```

---

### Screen 15 — Dashboard Báo cáo KPI (KPI Dashboard)
**File liên quan:** `kpi_module` — màn hình Manager xem tổng quan KPI team

#### App Bar
```
Hamburger icon ☰: var(--on-surface), align left
Title "Ska Milk": headline-md, color var(--primary) #002556, center
(không có icon phải)
```

#### Section Header
```
Title "Báo cáo KPI": headline-md, color var(--on-surface), align left
Filter icon ▽:
  Icon: Icons.filter_alt_outlined hoặc tương đương
  Color: var(--secondary) #0051d5
  Align: right
  Touch target: 44x44px
```

#### Card — KPI TEAM (primary metric)
```
Background: #ffffff
Border: 2px solid var(--primary) #002556
Border-radius: var(--radius-lg) 16px
Padding: 20px
Shadow: Level 1

  Label "KPI TEAM": label-lg uppercase, color var(--on-surface-variant)
  Số tiền: headline-lg 700 (24px+), color var(--on-surface)
    Format: NumberFormat '#,###' → "1.500.000.000 VND"
    ⚠️ Không xuống dòng giữa số và "VND" — dùng FittedBox hoặc auto-resize font
    Recommended: font-size 22px, đảm bảo fit 1 dòng
```

#### Card — TIẾN ĐỘ THỰC HIỆN TEAM (progress metric)
```
Background: #ffffff
Border: 2px solid var(--tertiary-accent) — dùng màu cam/orange: #C2410C hoặc token mới --accent-warm: #C2410C
Border-radius: var(--radius-lg) 16px
Padding: 20px
Shadow: Level 1
Margin-top: 12px

  Label "TIẾN ĐỘ THỰC HIỆN TEAM": label-lg uppercase, color var(--on-surface-variant)
  Số tiền: headline-lg 700, color #C2410C (orange-700)
    Format: "40.201.700 VND"
    ⚠️ Không xuống dòng — áp dụng FittedBox hoặc maxLines: 1 + auto-size

Gợi ý thêm (optional):
  Progress bar dưới số:
    Track: var(--surface-container-high), height 6px, radius 3px
    Fill: #C2410C, width = (tiến độ / KPI) * 100%
```

#### Section Divider — Executive Overview
```
Label "EXECUTIVE OVERVIEW": label-md uppercase, color var(--on-surface-variant)
Title "Dashboard": headline-lg 700, color var(--on-surface)
Margin: 20px 0 12px
```

#### Button — Chỉ tiêu nhân viên
```
Layout: full-width hoặc wrap content + center
Background: var(--primary) #002556
Color: #ffffff
Height: 48px
Border-radius: var(--radius-full) — pill
Padding: 0 24px
Font: label-lg
Icon: + (Icons.add) trắng, ở trước text
Text: "Chỉ tiêu nhân viên"
Shadow: Level 1
OnTap: navigate → Screen 14 (KPI Setup)
```

#### Section — Top 3 Doanh thu
```
Row header:
  Icon: 📊 (bar chart) var(--secondary)
  Text "Top 3 Doanh thu": headline-sm, color var(--on-surface)

Mỗi item (ranked list):
  Rank badge: 
    #1 → background var(--primary) #002556, color #ffffff
    #2 → background var(--surface-container-high), color var(--on-surface)
    #3 → background var(--surface-container), color var(--on-surface)
    Size: 28x28px, border-radius full, font label-lg center
  
  Tên nhân viên: body-md 600, color var(--on-surface)
  Doanh số: body-md, color var(--on-surface-variant), align right
  
  Separator: 1px solid var(--outline-variant) giữa các item
```

---

## 3. Interaction States

```
Button:
  Default → Hover: opacity 0.92
  Active/Press: scale(0.98), transition 80ms ease
  Disabled: opacity 0.4, pointer-events none

Input Focus:
  border-color: var(--secondary)
  box-shadow: 0 0 0 2px rgba(0, 81, 213, 0.15)
  transition: 150ms ease

Card Hover (trên desktop):
  box-shadow: Level 2
  transform: translateY(-1px)
  transition: 200ms ease
```

---

## 4. Status Badge System

| Trạng thái | Background | Color | Uppercase |
|---|---|---|---|
| ACTIVE / HOÀN TẤT | #dcfce7 | #16a34a | ✓ |
| ĐANG XỬ LÝ / PENDING | #fff7ed | #f97316 | ✓ |
| ĐÃ XÁC NHẬN / ASSIGNED | #eff4ff | #0051d5 | ✓ |
| TỪ CHỐI / NỢ QUÁ HẠN | #fef2f2 | #ba1a1a | ✓ |
| KHÁCH HÀNG MỚI | #e5eeff | #0051d5 | ✓ |

Tất cả badges: `border-radius: var(--radius-full)`, `padding: 3px 10px`, `font: label-md (12px 500)`

---

## 5. Navigation / Bottom Tab Bar

```
Background: #ffffff
Border-top: 1px solid var(--outline-variant) #c3c6d2
Height: 60px + safe area inset bottom
Padding-bottom: env(safe-area-inset-bottom)

Tab active:
  Icon + Label: color var(--primary) #002556
  Label: caption, font-weight 600

Tab inactive:
  Icon + Label: color var(--on-surface-variant) #434750
  Label: caption, font-weight 400
```

---

## 6. Checklist triển khai

- [ ] Thêm Google Font "Be Vietnam Pro" vào `index.html` hoặc CSS global
- [ ] Khai báo toàn bộ CSS variables vào `:root` trong file global styles
- [ ] Thay thế tất cả hardcoded colors bằng CSS variables
- [ ] Cập nhật border-radius theo token (không dùng giá trị px tùy tiện)
- [ ] Kiểm tra contrast ratio tất cả text/background (WCAG AA)
- [ ] Test trên thiết bị thật: touch target tối thiểu 44px (var(--touch-target))
- [ ] Kiểm tra safe area trên iPhone (notch / Dynamic Island)
- [ ] Validate font rendering tiếng Việt (Be Vietnam Pro có đầy đủ diacritics)
