import 'package:app/partial/menu/menu_widget/menu_config.dart';
import 'package:app/partial/menu/menu_widget/menu_item.dart';
import 'package:app/root/app_output.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final Function(AppOutput) onOutput;
  final String currentModule;

  const Menu({super.key, required this.onOutput, required this.currentModule});

  void _navigate(BuildContext context, String module) {
    Navigator.pop(context);
    onOutput(AppOutput(toModule: module));
  }

  List<MenuConfig> get menus => const [
    MenuConfig(title: 'User', icon: Icons.person, module: 'USER'),
    MenuConfig(title: 'Test', icon: Icons.bug_report, module: 'TEST'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF5F6FA),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Menu",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),
            ...menus.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MenuItem(
                  title: item.title,
                  icon: item.icon,
                  isActive: currentModule == item.module,
                  onTap: () => _navigate(context, item.module),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
