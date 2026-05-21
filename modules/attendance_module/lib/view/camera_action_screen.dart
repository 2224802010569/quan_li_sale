import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../entity/store.dart';
import '../../logic_uc/attendance_uc.dart';
import 'widgets/camera_view_finder.dart';
import 'widgets/store_info_bottom_sheet.dart';

import '../../output/attendance_output.dart';

class CameraActionScreen extends StatefulWidget {
  final Store store;
  final Function(AttendanceOutput) onOutput;
  final VoidCallback onBack;

  const CameraActionScreen({Key? key, required this.store, required this.onOutput, required this.onBack})
    : super(key: key);

  @override
  State<CameraActionScreen> createState() => _CameraActionScreenState();
}

class _CameraActionScreenState extends State<CameraActionScreen> {
  final AttendanceUseCase _useCase = AttendanceUseCase();
  late Store _currentStore;
  bool _isLoading = true;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _cameraError;

  bool _isCheckIn = true; // default before checking DB

  double? _currentDistance;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _currentStore = widget.store;
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    await _checkStatus();
    await _initCamera();
    if (_currentStore.latitude != null && _currentStore.longitude != null) {
      _startLocationStream(_currentStore.latitude!, _currentStore.longitude!);
    } else {
      if (mounted) {
        setState(() {
          _cameraError = 'Cửa hàng không có dữ liệu tọa độ (Latitude/Longitude).';
        });
      }
    }
  }

  Future<void> _checkStatus() async {
    try {
      final ongoing = await _useCase.hasOngoingCheckIn(_currentStore.id);
      if (mounted) {
        setState(() {
          _isCheckIn = !ongoing;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải trạng thái: ${e.toString().replaceAll("Exception: ", "")}')),
        );
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = 'Không tìm thấy camera trên thiết bị.');
        return;
      }
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError =
              'Tạm thời không thể truy cập camera. Vui lòng cấp quyền hoặc khởi động lại ứng dụng.';
          _isLoading = false;
        });
      }
    }
  }

  void _startLocationStream(double destLat, double destLng) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _cameraError = 'Dịch vụ định vị đang bị tắt. Vui lòng bật vị trí.';
        });
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _cameraError = 'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng cấp quyền trong Cài đặt.';
        });
      }
      return;
    }

    // Lấy vị trí lập tức để hiển thị khoảng cách ngay
    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentDistance = Geolocator.distanceBetween(
            initialPosition.latitude,
            initialPosition.longitude,
            destLat,
            destLng,
          );
        });
      }
    } catch (_) {
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null && mounted) {
          setState(() {
            _currentDistance = Geolocator.distanceBetween(
              lastPosition.latitude,
              lastPosition.longitude,
              destLat,
              destLng,
            );
          });
        }
      } catch (_) {}
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // update every 1 meter
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            if (mounted) {
              setState(() {
                _currentDistance = Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  destLat,
                  destLng,
                );
              });
            }
          },
        );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  void _handleAction() async {
    if (_cameraController == null || !_isCameraInitialized) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imagePath = await _useCase.checkLocationAndCapture(
        cameraController: _cameraController!,
        destLat: _currentStore.latitude ?? 0,
        destLng: _currentStore.longitude ?? 0,
      );

      bool success;
      if (_isCheckIn) {
        success = await _useCase.submitCheckIn(_currentStore.id, imagePath, routeId: _currentStore.routeId);
      } else {
        success = await _useCase.submitCheckOut(_currentStore.id, imagePath);
      }

      Navigator.pop(context); // Close loading

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_isCheckIn ? "Check-in" : "Check-out"} thành công!',
            ),
          ),
        );
        widget.onOutput(AttendanceOutput(
          success: true,
          storeId: _currentStore.id,
          storeName: _currentStore.name,
          routeId: _currentStore.routeId,
        ));
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(child: CameraPreview(_cameraController!))
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4a554a), Color(0xFFaebcb3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _cameraError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          _cameraError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: widget.onBack,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCheckIn ? 'Check-in' : 'Check-out',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.flash_off, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // View Finder area
                const Expanded(child: CameraViewFinderUI()),

                // Bottom Sheet area
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else
                  StoreInfoBottomSheet(
                    store: _currentStore,
                    isCheckIn: _isCheckIn,
                    onActionPressed: _handleAction,
                    currentDistance: _currentDistance,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
