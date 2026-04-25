import 'dart:io';
import 'package:flutter/material.dart';

class CameraCaptureBox extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onCapture;
  final VoidCallback? onRemove;

  const CameraCaptureBox({
    super.key,
    this.imagePath,
    required this.onCapture,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath!),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 24),
                onPressed: onRemove,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onCapture,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.blue, size: 40),
            SizedBox(height: 8),
            Text(
              'Chụp ảnh kệ hàng (Bắt buộc)',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
