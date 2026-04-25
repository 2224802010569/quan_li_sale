import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';

import 'logic_data/order_data.dart';
import 'logic_data/product_data.dart';
import 'logic_uc/create_order_uc.dart';
import 'logic_uc/generate_pdf_uc.dart';
import 'view/screens/sale/create_order_view.dart';
import 'view/screens/mock_setup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. KHỞI TẠO SUPABASE
  await Supabase.initialize(
    url: 'https://nxlvrhpjvbhpdphbgklq.supabase.co',
    anonKey: 'sb_publishable_RYXxtTiEqLXz0Xa_bnIN6g_3Y8rMkAJ',
  );

  // 2. GÁN CLIENT VÀ TIÊM DEPENDENCY
  final supabaseConnect = SupabaseConnect();
  supabaseConnect.client = Supabase.instance.client;
  put<SupabaseConnect>(supabaseConnect);

  // 3. KHỞI TẠO DATA & USECASE
  final client = Supabase.instance.client;
  final productData = ProductData(client);
  final orderData = OrderData(client);

  final createOrderUC = CreateOrderUC(
    productData: productData,
    orderData: orderData,
  );
  final generatePdfUC = GeneratePdfUC(orderData: orderData);

  // 4. CHẠY APP
  runApp(TestOrderModuleApp());
}

class TestOrderModuleApp extends StatelessWidget {
  // Vì chúng ta dùng MockSetupView để gọi OrderModule (nơi tự khởi tạo lại Usecase),
  // bạn không cần truyền cứng createOrderUC vào đây nữa.
  const TestOrderModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order Module Test',
      theme: ThemeData(fontFamily: 'Manrope'),
      // Gắn màn hình Mock làm màn hình chính
      home: const MockSetupView(),
    );
  }
}
