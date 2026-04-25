import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProofCaptureView extends StatefulWidget {
  const ProofCaptureView({super.key});

  @override
  State<ProofCaptureView> createState() => _ProofCaptureViewState();
}

class _ProofCaptureViewState extends State<ProofCaptureView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  Future<void> _takePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      
      if (mounted) {
        if (photo != null) {
          Navigator.pop(context, File(photo.path));
        } else {
          Navigator.pop(context, null);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi chụp ảnh: $e');
      if (mounted) {
        Navigator.pop(context, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
