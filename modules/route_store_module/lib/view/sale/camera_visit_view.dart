import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/assignment_entity.dart';
import 'package:route_store_module/logic_uc/upload_visit_photo_uc.dart';

class CameraVisitView extends ConsumerStatefulWidget {
  final AssignmentEntity assignment;

  const CameraVisitView({Key? key, required this.assignment}) : super(key: key);

  @override
  ConsumerState<CameraVisitView> createState() => _CameraVisitViewState();
}

class _CameraVisitViewState extends ConsumerState<CameraVisitView> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isReady = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.high);
      await _controller?.initialize();
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isUploading) return;

    try {
      final image = await _controller!.takePicture();
      setState(() {
        _isUploading = true;
      });

      final uc = ref.read(uploadVisitPhotoUcProvider);
      // Giả sử userId lấy từ assignment (để upload ảnh vào đúng folder)
      final url = await uc.execute(widget.assignment.userId, File(image.path));
      
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        // Ở đây có thể show Dialog thành công và quay về
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload thành công!')));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}