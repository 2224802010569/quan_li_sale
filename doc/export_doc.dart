import 'dart:io';

void main() async {
  const name = "quan_li_sale";
  const version = "0.1.2";
  final rootDir = Directory(Platform.script.resolve('../').toFilePath());

  if (!await rootDir.exists()) {
    print("❌ Không tìm thấy root project");
    return;
  }

  final fileName = "${name}_v$version.txt";
  final output = File(Platform.script.resolve(fileName).toFilePath());
  final buffer = StringBuffer();

  await for (var entity in rootDir.list(recursive: true)) {
    // ✅ Chỉ lấy folder tên "lib"
    if (entity is Directory &&
        entity.path.split(Platform.pathSeparator).last == 'lib') {
      print("📂 Tìm thấy lib: ${entity.path}");

      // 👉 Duyệt file trong lib đó
      await for (var file in entity.list(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          buffer.writeln("\nFILE: ${file.path}");

          final content = await file.readAsString();
          buffer.writeln(content);
        }
      }
    }
  }

  await output.writeAsString(buffer.toString());

  print("✅ Export xong: $fileName");
}
