import 'dart:io';

void main() async {
  const name = "app";
  const version = "1.2.0";
  final libDir = Directory(Platform.script.resolve('../lib').toFilePath());

  if (!await libDir.exists()) {
    print("❌ Không tìm thấy lib");
    return;
  }

  final fileName = "${name}_v$version.txt";

  final output = File(Platform.script.resolve(fileName).toFilePath());

  final buffer = StringBuffer();

  await for (var entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      buffer.writeln("\nFILE: ${entity.path}");

      final content = await entity.readAsString();
      buffer.writeln(content);
    }
  }

  await output.writeAsString(buffer.toString());

  print("✅ Export xong: $fileName");
}
