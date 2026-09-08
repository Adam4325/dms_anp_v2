import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dms_anp/src/Helper/face_match_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

enum FaceLivenessMode { enroll, verify }

class FaceLivenessPage extends StatefulWidget {
  final FaceLivenessMode mode;
  final String enrollPhotoUrl;
  final Uint8List? enrollPhotoBytes;

  const FaceLivenessPage({
    Key? key,
    required this.mode,
    this.enrollPhotoUrl = '',
    this.enrollPhotoBytes,
  }) : super(key: key);

  @override
  State<FaceLivenessPage> createState() => _FaceLivenessPageState();
}

class _FaceLivenessPageState extends State<FaceLivenessPage> {
  static const Color _orange = Color(0xFFFF8C69);

  CameraController? _controller;
  FaceDetector? _detector;
  bool _busy = false;
  bool _capturing = false;
  String? _error;
  String _hint = 'Hadapkan wajah ke dalam oval';
  bool _faceOk = false;
  bool _blinkDone = false;
  bool _eyesWereOpen = false;
  bool _eyesWereClosed = false;
  bool _screenLight = false;
  DateTime? _faceStableSince;
  bool _showManualCapture = false;

  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    // _blinkFirst = DateTime.now().millisecond % 2 == 0;
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    final granted = await Permission.camera.request();
    if (!granted.isGranted) {
      setState(() => _error = 'Izin kamera ditolak');
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Kamera tidak ditemukan');
        return;
      }
      final front = cameras
          .where((c) => c.lensDirection == CameraLensDirection.front)
          .toList();
      final cam = front.isNotEmpty ? front.first : cameras.first;
      final controller = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
      await controller.startImageStream(_onFrame);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal buka kamera: $e');
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || _capturing || _controller == null) return;
    _busy = true;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final faces = await _detector!.processImage(input);
      if (!mounted) return;
      _evaluateFaces(faces, image.width, image.height);
    } catch (_) {
    } finally {
      _busy = false;
    }
  }

  void _evaluateFaces(List<Face> faces, int imgW, int imgH) {
    if (faces.isEmpty) {
      setState(() {
        _faceOk = false;
        _faceStableSince = null;
        _showManualCapture = false;
        _hint = 'Wajah tidak terdeteksi';
      });
      return;
    }
    faces.sort((a, b) =>
        (b.boundingBox.width * b.boundingBox.height)
            .compareTo(a.boundingBox.width * a.boundingBox.height));
    final face = faces.first;
    final box = face.boundingBox;
    final cx = box.center.dx / imgW;
    final cy = box.center.dy / imgH;
    final minSide = math.min(imgW, imgH).toDouble();
    final faceRatio = box.width / minSide;
    final centered = (cx - 0.5).abs() < 0.30 && (cy - 0.5).abs() < 0.35;
    if (!centered || faceRatio < 0.19) {
      setState(() {
        _faceOk = false;
        _faceStableSince = null;
        _showManualCapture = false;
        _hint = 'Dekatkan wajah ke oval';
      });
      return;
    }
    _faceOk = true;
    _faceStableSince ??= DateTime.now();

    // Jika wajah stabil di oval lebih dari 3.5 detik tapi kedipan belum terdeteksi (cahaya gelap/kacamata)
    if (!_blinkDone &&
        DateTime.now().difference(_faceStableSince!).inMilliseconds >= 3500) {
      if (!_showManualCapture) {
        setState(() => _showManualCapture = true);
      }
    }

    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left != null && right != null) {
      final avg = (left + right) / 2.0;
      // Lebih toleran di cahaya redup
      final eyesOpen = avg >= 0.48 || left >= 0.52 || right >= 0.52;
      final eyesClosed = avg <= 0.35 || (left <= 0.38 && right <= 0.38);
      if (!_blinkDone) {
        if (eyesOpen) _eyesWereOpen = true;
        if (_eyesWereOpen && eyesClosed) _eyesWereClosed = true;
        if (_eyesWereOpen && _eyesWereClosed && eyesOpen) {
          _blinkDone = true;
        }
      }
    }

    final nextBlink = !_blinkDone;

    if (nextBlink) {
      setState(() => _hint = _showManualCapture
          ? 'Kedipkan mata atau tap Ambil Foto'
          : 'Kedipkan mata');
    } else if (_blinkDone) {
      if (_capturing) {
        return;
      }
      _capturing = true;
      setState(() => _hint = widget.mode == FaceLivenessMode.verify
          ? 'Mencocokkan wajah...'
          : 'Mengambil foto...');
      _finishCapture();
    } else {
      setState(() => _hint = 'Tahan wajah di oval');
    }
  }

  // void _countSmile(Face face) {
  //   final smile = face.smilingProbability ?? 0;
  //   final smiling = smile > 0.50;
  //   final relaxed = smile < 0.40;
  //   if (relaxed) {
  //     _inSmile = false;
  //     _wasRelaxed = true;
  //   } else if (smiling && !_inSmile && _wasRelaxed) {
  //     _inSmile = true;
  //     _wasRelaxed = false;
  //     _smileCount++;
  //     if (_smileCount >= 1) {
  //       _smileDone = true;
  //     }
  //   }
  // }

  Future<void> _finishCapture() async {
    if (_controller == null) return;
    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted || _controller == null) return;
      final file = await _controller!.takePicture();
      if (widget.mode == FaceLivenessMode.enroll) {
        if (mounted) Navigator.of(context).pop(file.path);
        return;
      }
      setState(() => _hint = 'Mencocokkan dengan foto enroll...');
      final match = await FaceMatchHelper.compareLiveToEnroll(
        liveFile: File(file.path),
        enrollPhotoUrl: widget.enrollPhotoUrl,
        enrollPhotoBytes: widget.enrollPhotoBytes,
      );
      try {
        await File(file.path).delete();
      } catch (_) {}
      if (!mounted) return;
      if (match.matched) {
        Navigator.of(context).pop(true);
        return;
      }
      await _retryAfterReject(match.message);
    } catch (e) {
      _capturing = false;
      if (mounted) {
        setState(() => _hint = 'Gagal verifikasi: $e');
      }
      await _restartStream();
    }
  }

  Future<void> _retryAfterReject(String message) async {
    _blinkDone = false;
    _eyesWereOpen = false;
    _eyesWereClosed = false;
    _capturing = false;
    _faceStableSince = null;
    _showManualCapture = false;
    if (mounted) {
      setState(() => _hint = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    await Future.delayed(const Duration(milliseconds: 800));
    await _restartStream();
  }

  Future<void> _restartStream() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      if (!c.value.isStreamingImages) {
        await c.startImageStream(_onFrame);
      }
    } catch (_) {}
  }

  InputImage? _toInputImage(CameraImage image) {
    final cam = _controller?.description;
    if (cam == null) return null;
    final sensor = cam.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensor);
    } else {
      final orient = _controller?.value.deviceOrientation;
      var compensation = _orientations[orient] ?? 0;
      if (cam.lensDirection == CameraLensDirection.front) {
        compensation = (sensor + compensation) % 360;
      } else {
        compensation = (sensor - compensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(compensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
    if (image.planes.isEmpty) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == FaceLivenessMode.enroll
        ? 'Enrollment Wajah'
        : 'Verifikasi Wajah';
    return Scaffold(
      backgroundColor: _screenLight ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: _orange,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _screenLight = !_screenLight);
            },
            icon: Icon(
              _screenLight ? Icons.lightbulb : Icons.lightbulb_outline,
              color: _screenLight ? Colors.amberAccent : Colors.white,
              size: 20,
            ),
            label: Text(
              _screenLight ? 'Lampu ON' : 'Lampu Layar',
              style: TextStyle(
                color: _screenLight ? Colors.amberAccent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),
            )
          : _controller == null || !_controller!.value.isInitialized
              ? const Center(child: CircularProgressIndicator(color: _orange))
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),
                    CustomPaint(painter: _OvalMaskPainter(_screenLight)),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _chip('Kedip', _blinkDone),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _hint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _faceOk ? Colors.white : Colors.orangeAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_showManualCapture && !_blinkDone && _faceOk) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _capturing
                                    ? null
                                    : () {
                                        _blinkDone = true;
                                        setState(() => _hint = widget.mode ==
                                                FaceLivenessMode.verify
                                            ? 'Mencocokkan wajah...'
                                            : 'Mengambil foto...');
                                        _finishCapture();
                                      },
                                label: const Text(
                                  'Ambil Foto Sekarang (Cahaya Gelap)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                icon: const Icon(Icons.camera_alt, color: _orange),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _chip(String label, bool done) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: done ? Colors.green : Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _OvalMaskPainter extends CustomPainter {
  final bool screenLight;

  _OvalMaskPainter(this.screenLight);

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()
      ..color = screenLight ? Colors.white : Colors.black.withValues(alpha: 0.55);
    final hole = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.40),
      width: size.width * 0.72,
      height: size.height * 0.48,
    );
    hole.addOval(oval);
    hole.fillType = PathFillType.evenOdd;
    canvas.drawPath(hole, overlay);
    final border = Paint()
      ..color = screenLight ? const Color(0xFFFF9800) : const Color(0xFFFF8C69)
      ..style = PaintingStyle.stroke
      ..strokeWidth = screenLight ? 4 : 3;
    canvas.drawOval(oval, border);
  }

  @override
  bool shouldRepaint(covariant _OvalMaskPainter oldDelegate) =>
      oldDelegate.screenLight != screenLight;
}
