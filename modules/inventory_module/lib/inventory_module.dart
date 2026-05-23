import 'dart:io';
import 'package:flutter/material.dart';
import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';

import 'input/inventory_input.dart';
import 'output/inventory_output.dart';
import 'view/inventory_audit_view.dart';
import 'view/inventory_confirm_view.dart';
import 'logic_data/inventory_data_service.dart';
import 'logic_uc/inventory_use_case.dart';
import 'entity/product_entity.dart';
import 'entity/inventory_check_entity.dart';
import 'entity/inventory_detail_entity.dart';
import 'entity/display_entity.dart';

class InventoryModule extends StatefulWidget {
  final InventoryInput input;
  final Function(InventoryOutput) onOutput;
  final VoidCallback onBack;

  const InventoryModule({
    super.key,
    required this.input,
    required this.onOutput,
    required this.onBack,
  });

  @override
  State<InventoryModule> createState() => _InventoryModuleState();
}

class _InventoryModuleState extends State<InventoryModule> {
  late final InventoryDataService _dataService;
  final _useCase = InventoryUseCase();

  List<ProductEntity> _products = [];
  Map<String, int> _previousQuantities = {};
  
  bool _isLoading = true;
  String? _error;

  // State for submitting overlay
  Map<String, int> _actualStocks = {};

  @override
  void initState() {
    super.initState();
    final client = get<SupabaseConnect>().client!;
    _dataService = InventoryDataService(client);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!widget.input.canOpen()) {
      setState(() {
        _error = "Dữ liệu đầu vào không hợp lệ (Thiếu storeId hoặc userId)";
        _isLoading = false;
      });
      return;
    }

    try {
      final productsFuture = _dataService.fetchAllProducts();
      final previousQuantitiesFuture = _dataService.fetchLastCheckQuantities(widget.input.storeId);

      final results = await Future.wait([productsFuture, previousQuantitiesFuture]);
      
      setState(() {
        _products = results[0] as List<ProductEntity>;
        _previousQuantities = results[1] as Map<String, int>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showConfirmSheet(Map<String, int> actualStocks) {
    setState(() {
      _actualStocks = actualStocks;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return InventoryConfirmView(
          actualStocks: actualStocks,
          previousStocks: _previousQuantities,
          allProducts: _products,
          onBack: () => Navigator.pop(context),
          onSubmit: (File proofImage) {
            Navigator.pop(context);
            _handleSubmit(proofImage);
          },
          isLoading: false,
        );
      },
    );
  }

  Future<void> _handleSubmit(File proofImage) async {
    try {
      setState(() => _isLoading = true);

      // 1. Validate UseCase
      int checkedItems = _actualStocks.values.where((qty) => qty > 0).length;
      
      _useCase.validateSubmission(
        totalCheckedItems: checkedItems,
        requiredItemsCount: 1, 
        hasProofImage: true,
      );

      // 2. Chuẩn bị Entity Phiếu kiểm tồn
      final checkEntity = InventoryCheckEntity(
        id: '', // Sẽ bị drop trước khi insert vào DB để tự sinh ID
        userId: widget.input.userId,
        storeId: widget.input.storeId,
        createdAt: DateTime.now(),
      );

      // 3. Chuẩn bị danh sách Chi tiết kiểm tồn
      List<InventoryDetailEntity> details = [];
      _actualStocks.forEach((productId, actualQty) {
        final previousQty = _previousQuantities[productId];
        
        final status = _useCase.determineStockStatus(
          previousQty: previousQty, 
          actualQty: actualQty,
        );

        details.add(InventoryDetailEntity(
          id: '', // DB tự sinh
          checkId: 0, // Sẽ được cập nhật tự động trong Data Service
          productId: productId,
          quantity: actualQty,
          status: status,
          createdAt: DateTime.now(),
        ));
      });

      // 4. Lưu toàn bộ dữ liệu kiểm tồn vào Database
      await _dataService.submitInventoryData(checkEntity, details);

      // 5. Upload ảnh minh chứng
      final displayEntity = DisplayEntity(
        id: '', // DB tự sinh
        userId: widget.input.userId,
        storeId: widget.input.storeId,
        imageUrl: '', // Sẽ được gán Public URL sau khi upload
        createdAt: DateTime.now(),
      );
      await _dataService.uploadDisplayImage(displayEntity, proofImage);

      setState(() => _isLoading = false);

      // 6. Hoàn tất & Gửi sự kiện Output ra ngoài App
      widget.onOutput(InventoryOutput.success(
        actualStocks: _actualStocks,
        previousStocks: _previousQuantities,
        products: _products,
      ));

    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _products.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi tải dữ liệu')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        InventoryAuditView(
          allProducts: _products,
          onBack: widget.onBack,
          onConfirm: _showConfirmSheet,
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
