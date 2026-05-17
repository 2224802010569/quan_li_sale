
import "dart:io";

void main() async {
  final file = File("UI.txt");
  // Try to read with default encoding, but we will ignore character issues.
  // Actually, readAsBytes and convert to string using latin1 or just check substring
  final bytes = await file.readAsBytes();
  final content = String.fromCharCodes(bytes);
  final lines = content.split("\n");
  
  String currentFile = "";
  List<String> currentContent = [];
  
  for (var line in lines) {
    if (line.startsWith("- UI c")) {
      if (currentFile.isNotEmpty) {
        await File("../../lib/view/tmp_ui/$currentFile").writeAsString(currentContent.join("\n"));
      }
      // Extract the filename ending with .dart
      final match = RegExp(r"([a-zA-Z0-9_]+\.dart)").firstMatch(line);
      if (match != null) {
        currentFile = match.group(1)!;
      }
      currentContent = [];
    } else {
      currentContent.add(line);
    }
  }
  
  if (currentFile.isNotEmpty) {
    await File("../../lib/view/tmp_ui/$currentFile").writeAsString(currentContent.join("\n"));
  }
  print("Split complete.");
}

