import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Halaman kamera untuk foto odometer. Memakai kamera belakang (back).
/// Setelah jepret, pop dengan path file gambar; atau null jika batal/error.
class CameraOdometerPage extends StatefulWidget {
  const CameraOdometerPage({Key? key}) : super(key: key);

  @override
  State<CameraOdometerPage> createState() => _CameraOdometerPageState();
}

class _CameraOdometerPageState extends State<CameraOdometerPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  String? _error;
  bool _isCapturing = false;

  static const Color _softOrange = Color(0xFFFFAB76);
  static const Color _softOrangeDark = Color(0xFFE8955A);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Tidak ada kamera');
        return;
      }
      // Pilih kamera belakang (untuk foto odometer)
      final back = cameras.where((c) => c.lensDirection == CameraLensDirection.back).toList();
      final camera = back.isNotEmpty ? back.first : cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameras = cameras;
        _controller = controller;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal inisialisasi kamera: $e');
    }
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final XFile file = await _controller!.takePicture();
      final path = file.path;
      if (path.isNotEmpty && File(path).existsSync() && mounted) {
        Navigator.of(context).pop(path);
        return;
      }
      if (mounted) Navigator.of(context).pop(null);
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil foto: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Foto Odometer'), backgroundColor: _softOrange),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: ElevatedButton.styleFrom(backgroundColor: _softOrangeDark),
                  child: Text('Tutup', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Foto Odometer'), backgroundColor: _softOrange),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Foto Odometer (kamera belakang)', style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: _softOrange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize!.height,
              height: _controller!.value.previewSize!.width,
              child: CameraPreview(_controller!),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isCapturing ? null : _capture,
                icon: Icon(Icons.camera_alt, color: Colors.white),
                label: Text(_isCapturing ? 'Memproses...' : 'Ambil Foto', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _softOrangeDark,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
