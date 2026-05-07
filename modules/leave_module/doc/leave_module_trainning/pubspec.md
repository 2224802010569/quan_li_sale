# pubspec.md — Dependencies & Cấu hình dự án

> File này là **tài liệu tham khảo** để AI hiểu môi trường dự án.  
> File thực tế: `pubspec.yaml` ở root project.

---

## pubspec.yaml (phần dependencies)

```yaml
name: qls_app
description: Quản lý Sales App

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter

  # Backend
  supabase_flutter: ^2.x.x       # Supabase client cho Flutter

  # State management
  flutter_riverpod: ^2.x.x       # Riverpod (provider, notifier, asyncNotifier)
  riverpod_annotation: ^2.x.x    # Code gen annotation

  # Navigation
  go_router: ^13.x.x             # Routing khai báo

  # UI / UX
  intl: ^0.19.x                  # Format ngày: DateFormat('dd/MM/yyyy')
  flutter_datetime_picker_plus: ^2.x.x  # Date range picker
  cached_network_image: ^3.x.x   # Ảnh từ network (avatar, checkin image)

  # Utilities
  uuid: ^4.x.x                   # Tạo UUID phía client
  equatable: ^2.x.x              # So sánh entity dễ hơn
  json_annotation: ^4.x.x        # fromJson/toJson code gen

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.x.x
  json_serializable: ^6.x.x
  riverpod_generator: ^2.x.x
  flutter_lints: ^3.x.x
```

---

## Cấu hình Supabase

Khai báo trong `lib/main.dart` (không đặt key thật ở đây):

```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

Truyền khi build:
```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJxxx
```

---

## Font Manrope (theo Figma)

Thêm vào `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: Manrope
      fonts:
        - asset: assets/fonts/Manrope-Regular.ttf
          weight: 400
        - asset: assets/fonts/Manrope-Bold.ttf
          weight: 700
        - asset: assets/fonts/Manrope-ExtraBold.ttf
          weight: 800
```

---

## Màu sắc chuẩn (theo UI.txt / Figma)

```dart
// lib/core/app_colors.dart
class AppColors {
  static const navy       = Color(0xFF001D4E);
  static const navyDark   = Color(0xFF003178);
  static const scaffold   = Color.fromARGB(255, 18, 32, 47);
  static const surface    = Color(0xFF1A2A3A);
  static const textMuted  = Color(0xFF434651);
  static const chipBg     = Color(0xFFE8E8E8);
  static const pending    = Color(0xFFF59E0B);
  static const approved   = Color(0xFF22C55E);
  static const rejected   = Color(0xFFEF4444);
}
```

---

## Lưu ý version

- Không dùng API bị **deprecated** trong Riverpod v1 (ví dụ: `ChangeNotifierProvider`)
- Dùng `AsyncNotifier` thay `StateNotifier` cho async state
- `go_router` v13+: dùng `GoRoute` + `ShellRoute`, không dùng `Navigator.push` thủ công
- `supabase_flutter` v2: `supabase.auth.currentUser` thay vì `supabase.auth.user()`
