import 'package:flutter/material.dart';
import '../../components/route_list.dart';
import 'route_create_view.dart';

class RouteHomeManagerView extends StatelessWidget {
  final VoidCallback onBack;

  const RouteHomeManagerView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final routes = <String>[]; // demo rỗng

    return WillPopScope(
      onWillPop: () async {
        onBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý tuyến'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RouteCreateView()),
                );
              },
              child: const Text('Tạo tuyến'),
            ),

            const SizedBox(height: 12),

            Expanded(child: RouteList(routes: routes)),
          ],
        ),
      ),
    );
  }
}
