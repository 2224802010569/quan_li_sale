import 'package:flutter/material.dart';
import '../../components/route_list.dart';

class RouteHomeSaleView extends StatelessWidget {
  final VoidCallback onBack;

  const RouteHomeSaleView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final routes = ['Tuyến Quận 1', 'Tuyến Quận 7'];

    return WillPopScope(
      onWillPop: () async {
        onBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tuyến làm việc'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
        ),
        body: RouteList(routes: routes),
      ),
    );
  }
}
