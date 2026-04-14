import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../entity/store.dart';
import '../../logic_uc/attendance_uc.dart';
import 'widgets/camera_view_finder.dart';
import 'widgets/store_info_bottom_sheet.dart';

class CameraActionScreen extends StatefulWidget {
  final bool isCheckIn;

  const CameraActionScreen({Key? key, required this.isCheckIn})
    : super(key: key);

  @override
  State<CameraActionScreen> createState() => _CameraActionScreenState();
}

class _CameraActionScreenState extends State<CameraActionScreen> {
  final AttendanceUseCase _useCase = AttendanceUseCase();
  Store? _currentStore;
  bool _isLoading = true;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _cameraError;

  // Mock store location (replace with actual logic later)
  final double destLat = 10.979938;
  final double destLng = 106.674564;

  double? _currentDistance;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    await _loadStoreInfo();
    await _initCamera();
    _startLocationStream();
  }

  Future<void> _loadStoreInfo() async {
    final store = await _useCase.getCurrentStoreInfo();
    setState(() {
      _currentStore = store;
    });
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

  void _startLocationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;

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
    if (_currentStore == null ||
        _cameraController == null ||
        !_isCameraInitialized)
      return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final imagePath = await _useCase.checkLocationAndCapture(
        cameraController: _cameraController!,
        destLat: destLat,
        destLng: destLng,
      );

      bool success;
      if (widget.isCheckIn) {
        success = await _useCase.submitCheckIn(_currentStore!.id, imagePath);
      } else {
        success = await _useCase.submitCheckOut(_currentStore!.id, imagePath);
      }

      Navigator.pop(context); // Close loading

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.isCheckIn ? "Check-in" : "Check-out"} thành công! Ảnh lưu tại: $imagePath',
            ),
          ),
        );
        Navigator.pop(context);
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
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isCheckIn ? 'Check-in' : 'Check-out',
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
                else if (_currentStore != null)
                  StoreInfoBottomSheet(
                    store: _currentStore!,
                    isCheckIn: widget.isCheckIn,
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
