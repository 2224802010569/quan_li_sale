
import "dart:io";

void main() async {
  final directories = ["../../lib/view/manager", "../../lib/view/sale"];
  for (var dir in directories) {
    final dirInfo = Directory(dir);
    if (!dirInfo.existsSync()) continue;
    
    for (var entity in dirInfo.listSync()) {
      if (entity is File && entity.path.endsWith(".dart")) {
        var content = await entity.readAsString();
        content = content.replaceAll(")BoxShadow(", "), BoxShadow(");
        await entity.writeAsString(content);
      }
    }
  }
}

