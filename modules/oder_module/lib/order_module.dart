import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';
import 'output/order_output.dart';
import 'input/order_input.dart';
import 'logic_data/order_data.dart';
import 'logic_data/product_data.dart';
import 'logic_uc/create_order_uc.dart';
import 'logic_uc/generate_pdf_uc.dart';
import 'view/screens/sale/create_order_view.dart';
import 'view/screens/shared/order_history_view.dart';

class OrderModule extends StatelessWidget {
  final OrderInput input;
  final VoidCallback onBack;
  final Function(OrderOutput)? onOutput;

  const OrderModule({
    super.key,
    required this.input,
    required this.onBack,
    this.onOutput,
  });

  @override
  Widget build(BuildContext context) {
    final supabaseConnect = get<SupabaseConnect>();
    final client = supabaseConnect.client!;
    final orderData = OrderData(client);

    if (input.action == 'CREATE' && input.role == 'Sale' && input.storeId != null) {
      final productData = ProductData(client);

      final createOrderUC = CreateOrderUC(
        productData: productData,
        orderData: orderData,
      );

      final generatePdfUC = GeneratePdfUC(orderData: orderData);

      return CreateOrderView(
        createOrderUC: createOrderUC,
        generatePdfUC: generatePdfUC,
        userId: input.userId,
        employeeName: input.employeeName ?? '',
        storeId: input.storeId!,
        storeName: input.storeName ?? '',
        onBack: onBack,
        onOutput: onOutput,
      );
    }

    return OrderHistoryView(
      orderData: orderData,
      storeId: input.storeId,
      userId: input.role == 'Manager' ? null : input.userId,
      role: input.role,
      groupId: input.groupId,
      onBack: onBack,
    );
  }
}
