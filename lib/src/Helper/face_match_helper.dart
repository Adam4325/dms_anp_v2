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
  static const double matchThreshold = 0.36;

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

      final score = _bestScore(enrollCrop, liveCrop);
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
            'Wajah tidak sesuai foto enroll. Absensi ditolak.\n(skor ${score.toStringAsFixed(2)})',
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

  static double _bestScore(img.Image enrollCrop, img.Image liveCrop) {
    final variants = <img.Image>[
      liveCrop,
      img.flipHorizontal(_copy(liveCrop)),
    ];
    var best = 0.0;
    final enrollVec = _toVector(enrollCrop);
    final enrollHist = _histogram(enrollCrop);
    for (final live in variants) {
      final cosine = _cosine(enrollVec, _toVector(live));
      final hist = _histCorr(enrollHist, _histogram(live));
      final mixed = (cosine * 0.65) + (hist * 0.35);
      best = math.max(best, math.max(cosine, mixed));
    }
    return best;
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

  static List<int> _histogram(img.Image src) {
    final gray = img.grayscale(src);
    final bins = List<int>.filled(16, 0);
    for (var y = 0; y < gray.height; y++) {
      for (var x = 0; x < gray.width; x++) {
        final p = gray.getPixel(x, y);
        final lum = ((p.r + p.g + p.b) / 3.0).round().clamp(0, 255);
        bins[lum ~/ 16]++;
      }
    }
    return bins;
  }

  static double _histCorr(List<int> a, List<int> b) {
    final n = math.min(a.length, b.length);
    if (n == 0) return 0;
    var sumA = 0.0;
    var sumB = 0.0;
    for (var i = 0; i < n; i++) {
      sumA += a[i];
      sumB += b[i];
    }
    final meanA = sumA / n;
    final meanB = sumB / n;
    var num = 0.0;
    var denA = 0.0;
    var denB = 0.0;
    for (var i = 0; i < n; i++) {
      final da = a[i] - meanA;
      final db = b[i] - meanB;
      num += da * db;
      denA += da * da;
      denB += db * db;
    }
    final den = math.sqrt(denA * denB);
    if (den < 0.0001) return 0;
    return num / den;
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
