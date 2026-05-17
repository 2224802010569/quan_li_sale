import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_store_module/entity/route_entity.dart';
import 'package:route_store_module/entity/assignment_entity.dart';
import 'package:route_store_module/logic_uc/manage_route_uc.dart';
import 'package:route_store_module/logic_uc/manage_assignment_uc.dart';

// Provider lấy danh sách sale users
final _saleUsersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('users')
      .select('id, full_name, employee_code, phone')
      .eq('role', 'sale')
      .order('full_name', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

class AssignRouteView extends ConsumerStatefulWidget {
  const AssignRouteView({Key? key}) : super(key: key);

  @override
  ConsumerState<AssignRouteView> createState() => _AssignRouteViewState();
}

class _AssignRouteViewState extends ConsumerState<AssignRouteView> {
  RouteEntity? _selectedRoute;
  Map<String, dynamic>? _selectedSale;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Colors theo design system của app
  static const _bgColor = Color.fromARGB(255, 18, 32, 47);
  static const _appBarColor = Color(0xFF001D4E);
  static const _primaryColor = Color(0xFF0D47A1);
  static const _cardColor = Color(0xFF0A1929);
  static const _successColor = Color(0xFF22C55E);
  static const _errorColor = Color(0xFFEF4444);
  static const _warningColor = Color(0xFFF59E0B);

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _primaryColor,
              surface: _cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  Future<void> _assignRoute() async {
    if (_selectedRoute == null || _selectedSale == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn tuyến và nhân viên sale';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final uc = ref.read(manageAssignmentUcProvider);
      final userId = _selectedSale!['id'].toString();

      await uc.assignRouteToSale(userId, _selectedRoute!.id, _selectedDate);

      setState(() {
        _successMessage =
            'Đã phân công tuyến "${_selectedRoute!.routeName}" cho ${_selectedSale!['full_name']}';
        _selectedRoute = null;
        _selectedSale = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routeListProvider);
    final salesAsync = ref.watch(_saleUsersProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Phân tuyến nhân viên',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: _appBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================== HEADER ====================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF003178), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.assignment_ind,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Phân công tuyến',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chọn tuyến, nhân viên và ngày để phân công',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================== CHỌN TUYẾN ====================
            _buildSectionLabel('1. Chọn tuyến đường', Icons.route),
            const SizedBox(height: 8),
            routesAsync.when(
              loading: () => _buildLoadingCard(),
              error: (err, _) =>
                  _buildErrorCard('Không thể tải danh sách tuyến'),
              data: (routes) {
                if (routes.isEmpty) {
                  return _buildEmptyCard('Chưa có tuyến đường nào');
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedRoute != null
                          ? _primaryColor.withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RouteEntity>(
                      isExpanded: true,
                      value: _selectedRoute,
                      hint: const Text(
                        'Chọn tuyến...',
                        style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Inter',
                        ),
                      ),
                      dropdownColor: _cardColor,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white54,
                      ),
                      items: routes.map((route) {
                        return DropdownMenuItem<RouteEntity>(
                          value: route,
                          child: Text(
                            route.routeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 15,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoute = value;
                          _errorMessage = null;
                          _successMessage = null;
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ==================== CHỌN SALE ====================
            _buildSectionLabel('2. Chọn nhân viên Sale', Icons.person),
            const SizedBox(height: 8),
            salesAsync.when(
              loading: () => _buildLoadingCard(),
              error: (err, _) =>
                  _buildErrorCard('Không thể tải danh sách nhân viên'),
              data: (sales) {
                if (sales.isEmpty) {
                  return _buildEmptyCard('Chưa có nhân viên sale nào');
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedSale != null
                          ? _primaryColor.withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      isExpanded: true,
                      value: _selectedSale,
                      hint: const Text(
                        'Chọn nhân viên...',
                        style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Inter',
                        ),
                      ),
                      dropdownColor: _cardColor,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white54,
                      ),
                      items: sales.map((sale) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: sale,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: _primaryColor,
                                child: Text(
                                  (sale['full_name'] ?? 'S')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    sale['full_name'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    sale['employee_code'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSale = value;
                          _errorMessage = null;
                          _successMessage = null;
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ==================== CHỌN NGÀY ====================
            _buildSectionLabel('3. Chọn ngày phân công', Icons.calendar_today),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: _primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.edit_calendar,
                      color: Colors.white.withOpacity(0.5),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================== PREVIEW ====================
            if (_selectedRoute != null || _selectedSale != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xác nhận phân công',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPreviewRow(
                      'Tuyến:',
                      _selectedRoute?.routeName ?? 'Chưa chọn',
                    ),
                    _buildPreviewRow(
                      'Sale:',
                      _selectedSale?['full_name'] ?? 'Chưa chọn',
                    ),
                    _buildPreviewRow(
                      'Ngày:',
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    ),
                    _buildPreviewRow('Loại:', 'Tuyến chính (is_support = 1)'),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ==================== MESSAGES ====================
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _errorColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _errorColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: _errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: _errorColor,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _successColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: _successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(
                          color: _successColor,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ==================== BUTTON ====================
            ElevatedButton(
              onPressed: _isLoading ? null : _assignRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                disabledBackgroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'PHÂN CÔNG TUYẾN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Manrope',
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: _errorColor),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: _errorColor, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox, color: Colors.white.withOpacity(0.3), size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
