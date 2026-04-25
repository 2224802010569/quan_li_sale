import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraController = MobileScannerController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã vạch sản phẩm'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => _cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => _cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String code = barcodes.first.rawValue ?? '';
                if (code.isNotEmpty) {
                   _cameraController.stop();
                   Navigator.pop(context, code);
                }
              }
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: ScannerOverlayPainter(animationValue: _animationController.value),
                child: Container(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double animationValue;

  ScannerOverlayPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = 250.0;
    final double cornerLength = 40.0;
    final double strokeWidth = 4.0;
    
    // Background overlay
    final paintBg = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: scanAreaSize,
        height: scanAreaSize,
      ))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(backgroundPath, paintBg);

    final Paint paintCorner = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    // Top-Left Corner
    canvas.drawPath(Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top)
      ..lineTo(left + cornerLength, top), paintCorner);

    // Top-Right Corner
    canvas.drawPath(Path()
      ..moveTo(right - cornerLength, top)
      ..lineTo(right, top)
      ..lineTo(right, top + cornerLength), paintCorner);

    // Bottom-Left Corner
    canvas.drawPath(Path()
      ..moveTo(left, bottom - cornerLength)
      ..lineTo(left, bottom)
      ..lineTo(left + cornerLength, bottom), paintCorner);

    // Bottom-Right Corner
    canvas.drawPath(Path()
      ..moveTo(right - cornerLength, bottom)
      ..lineTo(right, bottom)
      ..lineTo(right, bottom - cornerLength), paintCorner);

    // Animating Scan Line
    final Paint paintLine = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    final double lineY = top + (scanAreaSize * animationValue);
    canvas.drawLine(Offset(left, lineY), Offset(right, lineY), paintLine);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
