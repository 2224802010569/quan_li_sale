
import "dart:io";

void main() async {
  final directories = ["../../lib/view/manager", "../../lib/view/sale"];
  for (var dir in directories) {
    final dirInfo = Directory(dir);
    if (!dirInfo.existsSync()) continue;
    
    for (var entity in dirInfo.listSync()) {
      if (entity is File && entity.path.endsWith(".dart")) {
        var content = await entity.readAsString();
        // Replace empty comma lines in lists
        content = content.replaceAll(RegExp(r"\[\s*,\s*\]"), "[]");
        // Also sometimes it is just a comma alone on a line inside children
        content = content.replaceAll(RegExp(r"^\s*,\s*$", multiLine: true), "");
        
        await entity.writeAsString(content);
        print("Fixed ${entity.path}");
      }
    }
  }
}

