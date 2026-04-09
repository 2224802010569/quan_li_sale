import 'package:flutter/material.dart';

class RouteList extends StatelessWidget {
  final List<String> routes;
  final Function(String)? onTap;

  const RouteList({super.key, required this.routes, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return const Center(child: Text('Chưa có tuyến'));
    }

    return ListView.builder(
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return ListTile(
          leading: const Icon(Icons.route),
          title: Text(route),
          onTap: () => onTap?.call(route),
        );
      },
    );
  }
}
