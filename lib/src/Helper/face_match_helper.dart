import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class FaceMatchResult {
  final bool matched;
  final double score;
  final String message;

  const FaceMatchResult({
    required this.matched,
    required this.score,
    required this.message,
  });
}

/// Bandingkan wajah live vs foto enroll.
/// Threshold longgar karena enroll/verify beda cahaya, senyum, dan kamera depan.
class FaceMatchHelper {
  static const double matchThreshold = 0.45;

  static Future<FaceMatchResult> compareLiveToEnroll({
    required File liveFile,
    required String enrollPhotoUrl,
    Uint8List? enrollPhotoBytes,
  }) async {
    if (enrollPhotoUrl.trim().isEmpty &&
        (enrollPhotoBytes == null || enrollPhotoBytes.isEmpty)) {
      return const FaceMatchResult(
        matched: false,
        score: 0,
        message: 'Foto enroll tidak ditemukan. Hubungi HRD.',
      );
    }

    Uint8List? enrollBytes =
        (enrollPhotoBytes != null && _isJpeg(enrollPhotoBytes))
            ? enrollPhotoBytes
            : null;
    enrollBytes ??= await _download(enrollPhotoUrl);
    if (enrollBytes == null || !_isJpeg(enrollBytes)) {
      return const FaceMatchResult(
        matched: false,
        score: 0,
        message: 'Gagal unduh foto enroll. Cek koneksi, lalu coba lagi.',
      );
    }

    final liveBytes = await liveFile.readAsBytes();
    if (!_isJpeg(liveBytes)) {
      return const FaceMatchResult(
        matched: false,
        score: 0,
        message: 'Foto kamera tidak valid. Coba lagi.',
      );
    }
    final enrollImg = _decodeOriented(enrollBytes);
    final liveImg = _decodeOriented(liveBytes);
    if (enrollImg == null || liveImg == null) {
      return const FaceMatchResult(
        matched: false,
        score: 0,
        message: 'Foto tidak bisa dibaca.',
      );
    }

    final detector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    try {
      Face? enrollFace = await _detectLargest(detector, enrollBytes, 'enroll');
      Face? liveFace = await _detectFromPath(detector, liveFile.path);
      liveFace ??= await _detectLargest(detector, liveBytes, 'live');

      var enrollCrop = enrollFace != null
          ? _cropFace(enrollImg, enrollFace)
          : null;
      enrollCrop ??= _centerCrop(enrollImg);
      var liveCrop = liveFace != null ? _cropFace(liveImg, liveFace) : null;
      liveCrop ??= _centerCrop(liveImg);
      if (enrollCrop == null || liveCrop == null) {
        return const FaceMatchResult(
          matched: false,
          score: 0,
          message: 'Gagal potong wajah.',
        );
      }

      final score = _calculateMatchScore(
        enrollCrop,
        liveCrop,
        enrollFace,
        liveFace,
      );
      if (score >= matchThreshold) {
        return FaceMatchResult(
          matched: true,
          score: score,
          message: 'Wajah sesuai',
        );
      }
      return FaceMatchResult(
        matched: false,
        score: score,
        message:
            'Wajah tidak sesuai foto enroll (skor ${(score * 100).toInt()}%). Absensi ditolak.',
      );
    } finally {
      await detector.close();
    }
  }

  static bool _isJpeg(Uint8List bytes) {
    return bytes.length > 200 && bytes[0] == 0xFF && bytes[1] == 0xD8;
  }

  static img.Image _copy(img.Image src) {
    return img.copyResize(src, width: src.width, height: src.height);
  }

  /// Evaluasi gabungan: Geometri Landmark (proporsi wajah) + Visual Gradient & Zona
  static double _calculateMatchScore(
    img.Image enrollCrop,
    img.Image liveCrop,
    Face? enrollFace,
    Face? liveFace,
  ) {
    final visualScore = _compareVisual(enrollCrop, liveCrop);
    final geomScore = _landmarkSimilarity(enrollFace, liveFace);

    // Jika proporsi geometris landmark berbeda signifikan (< 0.45), tolak (orang berbeda)
    if (geomScore < 0.45) {
      return visualScore * 0.4;
    }

    if (enrollFace != null && liveFace != null) {
      return (visualScore * 0.60) + (geomScore * 0.40);
    }
    return visualScore;
  }

  /// Bandingkan proporsi geometris landmark (jarak mata, hidung, mulut)
  /// Sangat efektif membedakan Orang A vs Orang B karena proporsi tulang wajah tiap orang unik.
  static double _landmarkSimilarity(Face? a, Face? b) {
    if (a == null || b == null) return 1.0;

    final aLeftEye = a.landmarks[FaceLandmarkType.leftEye]?.position;
    final aRightEye = a.landmarks[FaceLandmarkType.rightEye]?.position;
    final aNose = a.landmarks[FaceLandmarkType.noseBase]?.position;
    final aMouthLeft = a.landmarks[FaceLandmarkType.leftMouth]?.position;
    final aMouthRight = a.landmarks[FaceLandmarkType.rightMouth]?.position;

    final bLeftEye = b.landmarks[FaceLandmarkType.leftEye]?.position;
    final bRightEye = b.landmarks[FaceLandmarkType.rightEye]?.position;
    final bNose = b.landmarks[FaceLandmarkType.noseBase]?.position;
    final bMouthLeft = b.landmarks[FaceLandmarkType.leftMouth]?.position;
    final bMouthRight = b.landmarks[FaceLandmarkType.rightMouth]?.position;

    if (aLeftEye == null ||
        aRightEye == null ||
        bLeftEye == null ||
        bRightEye == null) {
      return 1.0; // Skip jika landmark mata tidak lengkap
    }

    final aEyeDist = aLeftEye.distanceTo(aRightEye).toDouble();
    final bEyeDist = bLeftEye.distanceTo(bRightEye).toDouble();
    if (aEyeDist < 8 || bEyeDist < 8) return 1.0;

    var diffSum = 0.0;
    var count = 0;

    // 1. Rasio jarak mata ke hidung vs jarak antar mata
    if (aNose != null && bNose != null) {
      final aEyeMidX = (aLeftEye.x + aRightEye.x) / 2.0;
      final aEyeMidY = (aLeftEye.y + aRightEye.y) / 2.0;
      final aNoseDist = math.sqrt(
          math.pow(aNose.x - aEyeMidX, 2) + math.pow(aNose.y - aEyeMidY, 2));
      final aRatio = aNoseDist / aEyeDist;

      final bEyeMidX = (bLeftEye.x + bRightEye.x) / 2.0;
      final bEyeMidY = (bLeftEye.y + bRightEye.y) / 2.0;
      final bNoseDist = math.sqrt(
          math.pow(bNose.x - bEyeMidX, 2) + math.pow(bNose.y - bEyeMidY, 2));
      final bRatio = bNoseDist / bEyeDist;

      final maxR = math.max(aRatio, bRatio);
      if (maxR > 0) {
        diffSum += (aRatio - bRatio).abs() / maxR;
        count++;
      }
    }

    // 2. Rasio lebar mulut vs jarak antar mata
    if (aMouthLeft != null &&
        aMouthRight != null &&
        bMouthLeft != null &&
        bMouthRight != null) {
      final aMouthWidth = aMouthLeft.distanceTo(aMouthRight).toDouble();
      final bMouthWidth = bMouthLeft.distanceTo(bMouthRight).toDouble();
      final aRatio = aMouthWidth / aEyeDist;
      final bRatio = bMouthWidth / bEyeDist;

      final maxR = math.max(aRatio, bRatio);
      if (maxR > 0) {
        diffSum += (aRatio - bRatio).abs() / maxR;
        count++;
      }
    }

    // 3. Rasio proporsi bounding box (lebar / tinggi wajah)
    final aBoxRatio = a.boundingBox.width / math.max(1, a.boundingBox.height);
    final bBoxRatio = b.boundingBox.width / math.max(1, b.boundingBox.height);
    final maxBox = math.max(aBoxRatio, bBoxRatio);
    if (maxBox > 0) {
      diffSum += (aBoxRatio - bBoxRatio).abs() / maxBox;
      count++;
    }

    if (count == 0) return 1.0;
    final avgDiff = diffSum / count;
    // Rata-rata perbedaan > 18% berarti geometri wajah sangat berbeda
    return (1.0 - (avgDiff * 2.8)).clamp(0.0, 1.0);
  }

  /// Ekstraksi fitur kontur/gradien bebas pencahayaan & perbandingan zona (mata, hidung, mulut)
  static double _compareVisual(img.Image enrollCrop, img.Image liveCrop) {
    final enrollResized = img.copyResize(enrollCrop, width: 64, height: 64);
    final liveResized = img.copyResize(liveCrop, width: 64, height: 64);

    final enrollGray = img.grayscale(enrollResized);
    final liveGray = img.grayscale(liveResized);

    // Citra gradien mengisolasi garis mata, alis, hidung, dan bibir tanpa terpengaruh pencahayaan
    final enrollGrad = _gradientImage(enrollGray);
    final enrollFull = _toVector(enrollGrad);
    final enrollEyes = _toVectorSub(enrollGrad, 6, 8, 52, 22);
    final enrollNose = _toVectorSub(enrollGrad, 14, 22, 36, 20);
    final enrollMouth = _toVectorSub(enrollGrad, 10, 38, 44, 20);

    final variants = <img.Image>[
      liveGray,
      img.flipHorizontal(_copy(liveGray)),
    ];

    var bestVisual = 0.0;

    for (final vGray in variants) {
      for (final dy in [0, -2, 2]) {
        for (final dx in [0, -2, 2]) {
          final shifted =
              (dx == 0 && dy == 0) ? vGray : _shiftImage(vGray, dx, dy);
          final liveGrad = _gradientImage(shifted);

          final cosFull = _cosine(enrollFull, _toVector(liveGrad));
          final cosEyes =
              _cosine(enrollEyes, _toVectorSub(liveGrad, 6, 8, 52, 22));
          final cosNose =
              _cosine(enrollNose, _toVectorSub(liveGrad, 14, 22, 36, 20));
          final cosMouth =
              _cosine(enrollMouth, _toVectorSub(liveGrad, 10, 38, 44, 20));

          // Penalti ketat: Jika zona mata tidak mirip (< 0.18), bukan orang yang sama
          if (cosEyes < 0.18) continue;

          final zoneScore =
              (cosEyes * 0.50) + (cosNose * 0.25) + (cosMouth * 0.25);
          final score = (cosFull * 0.40) + (zoneScore * 0.60);

          if (score > bestVisual) {
            bestVisual = score;
          }
        }
      }
    }
    return bestVisual;
  }

  static img.Image _shiftImage(img.Image src, int dx, int dy) {
    final w = src.width;
    final h = src.height;
    final out = img.Image(width: w, height: h);
    for (var y = 0; y < h; y++) {
      final sy = (y - dy).clamp(0, h - 1);
      for (var x = 0; x < w; x++) {
        final sx = (x - dx).clamp(0, w - 1);
        out.setPixel(x, y, src.getPixel(sx, sy));
      }
    }
    return out;
  }

  static img.Image _gradientImage(img.Image gray) {
    final w = gray.width;
    final h = gray.height;
    final out = img.Image(width: w, height: h);
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final pL = gray.getPixel(x - 1, y).r;
        final pR = gray.getPixel(x + 1, y).r;
        final pT = gray.getPixel(x, y - 1).r;
        final pB = gray.getPixel(x, y + 1).r;
        final dx = (pR - pL).abs();
        final dy = (pB - pT).abs();
        final mag = ((dx + dy) * 1.5).round().clamp(0, 255);
        out.setPixelRgb(x, y, mag, mag, mag);
      }
    }
    return out;
  }

  static List<double> _toVectorSub(
      img.Image src, int startX, int startY, int w, int h) {
    final raw = <double>[];
    final endX = math.min(src.width, startX + w);
    final endY = math.min(src.height, startY + h);
    var minL = 255.0;
    var maxL = 0.0;
    for (var y = startY; y < endY; y++) {
      for (var x = startX; x < endX; x++) {
        final p = src.getPixel(x, y);
        final lum = (p.r + p.g + p.b) / 3.0;
        raw.add(lum);
        if (lum < minL) minL = lum;
        if (lum > maxL) maxL = lum;
      }
    }
    if (raw.isEmpty) return const [];
    final span = (maxL - minL).abs() < 1 ? 1.0 : (maxL - minL);
    var sum = 0.0;
    for (var i = 0; i < raw.length; i++) {
      raw[i] = (raw[i] - minL) / span;
      sum += raw[i];
    }
    final mean = sum / raw.length;
    var norm = 0.0;
    final centered = List<double>.generate(raw.length, (i) {
      final v = raw[i] - mean;
      norm += v * v;
      return v;
    });
    norm = math.sqrt(norm);
    if (norm < 0.0001) return centered;
    return centered.map((v) => v / norm).toList();
  }

  static img.Image? _decodeOriented(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return null;
    }
    try {
      return img.bakeOrientation(decoded);
    } catch (_) {
      return decoded;
    }
  }

  static Future<Uint8List?> _download(String url) async {
    if (url.trim().isEmpty) return null;
    for (var i = 0; i < 3; i++) {
      final client = http.Client();
      try {
        final response = await client
            .get(Uri.parse(url), headers: {'Connection': 'close'})
            .timeout(const Duration(seconds: 20));
        final body = response.bodyBytes;
        if (response.statusCode == 200 && _isJpeg(body)) {
          return body;
        }
      } catch (_) {
      } finally {
        client.close();
      }
      await Future.delayed(Duration(milliseconds: 350 * (i + 1)));
    }
    return null;
  }

  static Future<File> _writeTemp(Uint8List bytes, String name) async {
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$name.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<Face?> _detectFromPath(
    FaceDetector detector,
    String path,
  ) async {
    try {
      final faces = await detector.processImage(InputImage.fromFilePath(path));
      if (faces.isEmpty) return null;
      faces.sort((a, b) => (b.boundingBox.width * b.boundingBox.height)
          .compareTo(a.boundingBox.width * a.boundingBox.height));
      return faces.first;
    } catch (_) {
      return null;
    }
  }

  static Future<Face?> _detectLargest(
    FaceDetector detector,
    Uint8List bytes,
    String tag,
  ) async {
    final file = await _writeTemp(bytes, 'face_$tag');
    try {
      final faces =
          await detector.processImage(InputImage.fromFilePath(file.path));
      if (faces.isEmpty) return null;
      faces.sort((a, b) => (b.boundingBox.width * b.boundingBox.height)
          .compareTo(a.boundingBox.width * a.boundingBox.height));
      return faces.first;
    } finally {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  static img.Image? _cropFace(img.Image src, Face face) {
    final box = face.boundingBox;
    final padX = box.width * 0.18;
    final padY = box.height * 0.22;
    var x = (box.left - padX).round();
    var y = (box.top - padY).round();
    var w = (box.width + padX * 2).round();
    var h = (box.height + padY * 2).round();
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x + w > src.width) w = src.width - x;
    if (y + h > src.height) h = src.height - y;
    if (w < 20 || h < 20) return null;
    final cropped = img.copyCrop(src, x: x, y: y, width: w, height: h);
    return img.copyResize(cropped, width: 96, height: 96);
  }

  static img.Image? _centerCrop(img.Image src) {
    final side = math.min(src.width, src.height);
    if (side < 20) return null;
    final x = ((src.width - side) / 2).round();
    final y = ((src.height - side) / 2).round();
    final cropped = img.copyCrop(src, x: x, y: y, width: side, height: side);
    return img.copyResize(cropped, width: 96, height: 96);
  }

  static List<double> _toVector(img.Image src) {
    final gray = img.grayscale(src);
    final raw = <double>[];
    var minL = 255.0;
    var maxL = 0.0;
    for (var y = 0; y < gray.height; y++) {
      for (var x = 0; x < gray.width; x++) {
        final p = gray.getPixel(x, y);
        final lum = (p.r + p.g + p.b) / 3.0;
        raw.add(lum);
        if (lum < minL) minL = lum;
        if (lum > maxL) maxL = lum;
      }
    }
    final span = (maxL - minL).abs() < 1 ? 1.0 : (maxL - minL);
    var sum = 0.0;
    for (var i = 0; i < raw.length; i++) {
      raw[i] = (raw[i] - minL) / span;
      sum += raw[i];
    }
    final mean = raw.isEmpty ? 0.0 : sum / raw.length;
    var norm = 0.0;
    final centered = List<double>.generate(raw.length, (i) {
      final v = raw[i] - mean;
      norm += v * v;
      return v;
    });
    norm = math.sqrt(norm);
    if (norm < 0.0001) return centered;
    return centered.map((v) => v / norm).toList();
  }

  static double _cosine(List<double> a, List<double> b) {
    final n = math.min(a.length, b.length);
    if (n == 0) return 0;
    var dot = 0.0;
    for (var i = 0; i < n; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }
}
