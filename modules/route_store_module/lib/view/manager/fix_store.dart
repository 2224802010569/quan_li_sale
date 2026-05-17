
import "dart:io";

void main() async {
  final file = File("create_store_view.dart");
  final lines = await file.readAsLines();
  List<String> newLines = [];
  
  for (int i = 0; i < lines.length; i++) {
    if (i == 1355 && lines[i].startsWith("import")) {
      break;
    }
    newLines.add(lines[i]);
  }
  
  await file.writeAsString(newLines.join("\n"));
  print("Fixed");
}

