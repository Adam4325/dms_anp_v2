import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> openQrScanner(BuildContext context) async {
  final controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  String? result;
  await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (ctx) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            controller.dispose();
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text('Scan QR Code / Barcode', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black87,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String code = barcodes.first.rawValue ?? '';
                      if (code.isNotEmpty) {
                        result = code;
                        controller.stop();
                        Navigator.pop(ctx, code);
                      }
                    }
                  },
                ),
                scannerOverlay(),
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Posisikan kode di dalam kotak untuk memindai',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  return result;
}

Widget scannerOverlay() {
  return CustomPaint(
    painter: _ScannerOverlayPainter(),
    child: Container(),
  );
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2 - 50;
    final scanArea = Rect.fromLTWH(
      scanAreaLeft,
      scanAreaTop,
      scanAreaSize,
      scanAreaSize,
    );

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanArea)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, overlayPaint);

    final cornerLength = 30.0;
    final cornerWidth = 4.0;

    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      borderPaint..strokeWidth = cornerWidth,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      borderPaint..strokeWidth = cornerWidth,
    );

    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop),
      borderPaint..strokeWidth = cornerWidth,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      borderPaint..strokeWidth = cornerWidth,
    );

    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      borderPaint..strokeWidth = cornerWidth,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength),
      borderPaint..strokeWidth = cornerWidth,
    );

    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop + scanAreaSize),
      borderPaint..strokeWidth = cornerWidth,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize - cornerLength),
      borderPaint..strokeWidth = cornerWidth,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
