import 'package:app/root/app_output.dart';
import 'package:app/partial/menu/menu.dart';
import 'package:app/root/inventory_root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/di/injector.dart';
import 'package:core/error/global_error_reporter.dart';
import 'package:core/storage/app_storage.dart';
import 'package:inventory_module/inventory_module_export.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'root/user_root.dart';
import 'root/attendance_root.dart';
// import 'root/inventory_root.dart';
import 'root/order_root.dart';
import 'root/route_store_root.dart';
import 'root/leave_root.dart';
import 'root/kpi_root.dart';
import 'core/theme/app_theme.dart';

class AppState {
  final String module;
  AppState(this.module);
}

final appKey = GlobalKey<MyAppState>();

void recoverFromGlobalError(GlobalErrorInfo info) {
  appKey.currentState?.recoverFromGlobalError(info);
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  final storage = get<AppStorage>();
  final List<AppState> moduleStack = [];
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _globalErrorFocusNode = FocusNode(debugLabel: 'global_error_dismiss');
  DateTime? _lastGlobalErrorAt;

  @override
  void initState() {
    super.initState();
    moduleStack.add(AppState(getInitialModule()));
  }

  @override
  void dispose() {
    _globalErrorFocusNode.dispose();
    super.dispose();
  }

  // =========================
  // MODULE
  // =========================
  // String getInitialModule() {
  //   final user = storage.get<Map<String, dynamic>>('user');
  //   return user == null ? 'USER' : 'USER_PROFILE';
  // }

  String getInitialModule() {
    final user = storage.get<Map<String, dynamic>>('user');
    if (user == null) return 'USER';
    
    // Đọc chính xác trường 'role' từ dữ liệu user đã lưu trong Storage
    final role = user['role']?.toString().toLowerCase() ?? '';
    if (role == 'manager') {
      return 'ROUTE_STORE_MANAGER';
    }
    return 'ROUTE_STORE';
}

  Widget getScreen(String module) {
    switch (module) {
      case 'USER':
        return UserRoot().build(handleOutput);

      case 'USER_PROFILE':
        return UserRoot().buildProfile(handleOutput);

      case 'USER_MANAGER_VIEW':
        return UserRoot().buildManager(handleOutput, handleBack);

      case 'ATTENDANCE':
        return AttendanceRoot().build(handleOutput);

      case 'INVENTORY':
        return InventoryRoot().build(handleOutput);

      case 'INVENTORY_SUMMARY':
        final actual = storage.get<Map<String, dynamic>>('inventory_actual');
        final previous = storage.get<Map<String, dynamic>>('inventory_previous');
        final products = storage.get<List<dynamic>>('inventory_products') ?? [];
        final actualStocks = (actual ?? {}).map((k, v) => MapEntry(k, (v as num).toInt()));
        final previousStocks = (previous ?? {}).map((k, v) => MapEntry(k, (v as num).toInt()));
        return InventorySummaryScreen(
          actualStocks: actualStocks,
          previousStocks: previousStocks,
          products: products,
          onDone: () => handleOutput(AppOutput(toModule: 'STORE_HOME')),
          onCreateOrder: () => handleOutput(AppOutput(toModule: 'CREATE_ORDER')),
        );

      case 'ORDER':
        return OrderRoot().build(handleOutput);

      case 'CREATE_ORDER':
        return OrderRoot().buildCreate(handleOutput);
      case 'ROUTE_STORE_MANAGER':
        return RouteStoreRoot().buildRouteManager(handleOutput, handleBack);

      case 'CREATE_ROUTE':
        return RouteStoreRoot().buildCreateRoute(handleOutput, handleBack);

      case 'EDIT_ROUTE':
        return RouteStoreRoot().buildEditRoute(handleOutput, handleBack);


      case 'STORE_MANAGER':
        return RouteStoreRoot().buildStoreManager(handleOutput, handleBack);

      case 'CREATE_STORE':
        return RouteStoreRoot().buildCreateStore(handleOutput, handleBack);

      case 'EDIT_STORE':
        return RouteStoreRoot().buildEditStore(handleOutput, handleBack);

      case 'STORE_HOME':
        return RouteStoreRoot().buildStoreHome(handleOutput);

      case 'CHECKOUT':
        return AttendanceRoot().buildCheckout(handleOutput);

      case 'ROUTE_STORE':
        {
          // Nếu đang check-in vào cửa hàng (chưa checkout) → vào thẳng STORE_HOME
          final activeStoreId = storage.get<int>('current_store_id');
          if (activeStoreId != null && activeStoreId > 0) {
            return RouteStoreRoot().buildStoreHome(handleOutput);
          }
          return RouteStoreRoot().build(handleOutput);
        }

      case 'LEAVE':
        return LeaveRoot().build(handleOutput, onBack: handleBack);

      case 'LEAVE_FORM':
        return LeaveRoot().buildForm(handleOutput, onBack: handleBack);

      case 'LEAVE_MANAGER_PENDING':
        return LeaveRoot().buildManagerPending(handleOutput, onBack: handleBack);

      case 'LEAVE_MANAGER_HISTORY':
        return LeaveRoot().buildManagerHistory(handleOutput, onBack: handleBack);

      case 'KPI_MANAGER':
        return KpiRoot().buildManagerDashboard(handleOutput);

      default:
        return const Scaffold(
          body: Center(child: Text('Module không tồn tại')),
        );
    }
  }

  // =========================
  // HANDLE OUTPUT
  // =========================
  void handleOutput(AppOutput output) {
    saveData(output.data);
    handleProfileLogic(output);

    final current = moduleStack.last.module;
    if (current == output.toModule) return;
    
    setState(() {
      if (output.toModule == 'USER' || 
          output.toModule == 'ROUTE_STORE' || 
          output.toModule == 'ROUTE_STORE_MANAGER') {
        moduleStack
          ..clear()
          ..add(AppState(output.toModule));
        return;
      }
      // Invalidate assignments khi quay về ROUTE_STORE để force re-fetch
      if (output.toModule == 'ROUTE_STORE') {
        final user = storage.get<Map<String, dynamic>>('user');
        final userId = user?['id']?.toString() ?? '';
        if (userId.isNotEmpty) {
          ref.invalidate(realtimeUserAssignmentsProvider(userId));
        }
      }
      // Nếu module đích đã tồn tại trong stack → pop về đó, không push mới
      final existingIndex = moduleStack.indexWhere((s) => s.module == output.toModule);
      if (existingIndex != -1) {
        moduleStack.removeRange(existingIndex + 1, moduleStack.length);
        return;
      }
      moduleStack.add(AppState(output.toModule));
    });
  }

  void saveData(Map<String, dynamic>? data) {
    if (data == null) return;

    data.forEach((k, v) => storage.set(k, v));

    if (data.containsKey('id') && data.containsKey('role')) {
      storage.set('user', data);
    }
  }

  void handleProfileLogic(AppOutput output) {
    final data = output.data;

    if (output.toModule == 'USER_PROFILE') {
      if (data == null || !data.containsKey('profile_user_id')) {
        storage.remove('profile_user_id');
      }
    } else {
      storage.remove('profile_user_id');
    }
  }

  // =========================
  // BACK
  // =========================
  void handleBack() {
    if (moduleStack.length > 1) {
      setState(() {
        moduleStack.removeLast();
      });
    }
  }

  void recoverFromGlobalError(GlobalErrorInfo info) {
    final now = DateTime.now();
    final lastGlobalErrorAt = _lastGlobalErrorAt;
    if (lastGlobalErrorAt != null &&
        now.difference(lastGlobalErrorAt) < const Duration(seconds: 2)) {
      return;
    }

    _lastGlobalErrorAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      var movedBack = false;
      final navigator = _navigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
        movedBack = true;
      } else if (moduleStack.length > 1) {
        setState(() {
          moduleStack.removeLast();
        });
        movedBack = true;
      }

      _showGlobalErrorMessage(info, movedBack: movedBack);
    });
  }

  void _showGlobalErrorMessage(
    GlobalErrorInfo info, {
    required bool movedBack,
  }) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_friendlyErrorMessage(info, movedBack: movedBack)),
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Đóng',
            onPressed: messenger.hideCurrentSnackBar,
          ),
        ),
      );

    _globalErrorFocusNode.requestFocus();
  }

  void _hideGlobalErrorMessageOnKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

  String _friendlyErrorMessage(
    GlobalErrorInfo info, {
    required bool movedBack,
  }) {
    final raw = info.error.toString().toLowerCase();
    final prefix = movedBack ? 'Đã quay về màn hình trước. ' : '';

    if (raw.contains('socketexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('network') ||
        raw.contains('connection') ||
        raw.contains('timeout') ||
        raw.contains('xmlhttprequest')) {
      return '${prefix}Có thể wifi hoặc mạng đang yếu, vui lòng thử lại.';
    }

    if (raw.contains('supabase') ||
        raw.contains('postgrest') ||
        raw.contains('database') ||
        raw.contains('storage')) {
      return '${prefix}Dữ liệu đang được cập nhật, vui lòng thử lại sau.';
    }

    return '${prefix}Một phần tính năng đang cập nhật, vui lòng thử lại sau.';
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final current = moduleStack.last.module;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      home: KeyboardListener(
        focusNode: _globalErrorFocusNode,
        onKeyEvent: _hideGlobalErrorMessageOnKey,
        child: Scaffold(
          drawer: Drawer(
            child: Menu(onOutput: handleOutput, currentModule: current),
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF0B1C30)),
            centerTitle: true,
            title: const Text(
              'Ska Milk',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF002556), // AppColors.primary
                fontFamily: 'BeVietnamPro',
              ),
            ),
          ),
          body: getScreen(current),
        ),
      ),
    );
  }
}
