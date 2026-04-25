1. Không có dự án flutter lân cận (có là không debug được)
2. debug app, vì nó có main.dart
3. tôi chạy trên vscode
4. gặp vế đề debug không được, thực hiện thao tác sau:
    - terminal, cd tới app
    - flutter clean
    - flutter build

---------- Kết nối supabase ----------
1. vào pubspec.yaml, thêm vào dependencies:

  core:
    path: ../../core

2. sử dụng xem qua test_module/lib/logic_data
3. kết nối lên supabase -> edit sql -> code thêm bảng (supabasse không cho code bảng tại app)
4. debug tại thư mục có main

cd modules/test_module
flutter run -d chrome -t lib/test_module.dart