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

class _VisualMatchDetails {
  final double visualScore;
  final double cosEyes;
  final double cosNoseMouth;
  final double cosFull;

  const _VisualMatchDetails({
    required this.visualScore,
    required this.cosEyes,
    required this.cosNoseMouth,
    required this.cosFull,
  });
}

/// Bandingkan wajah live vs foto enroll.
/// Menggunakan koreksi orientasi tegak (EXIF bake), normalisasi kanonikal berbasis mata,
/// perbandingan proporsi geometris landmark tulang wajah, dan pencocokan visual per-blok (grid).
class FaceMatchHelper {
  /// Ambang batas kecocokan gabungan
  static const double matchThreshold = 0.52;

  /// Ambang batas jika landmark tidak terdeteksi lengkap pada salah satu foto
  static const double matchThresholdNoLandmark = 0.56;

  /// Ambang batas minimal kemiripan zona mata & alis
  static const double minEyeSimilarity = 0.28;

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

    // Decode dan tegakkan rotasi (EXIF bakeOrientation) agar koordinat 0°
    final enrollImg = _decodeOriented(enrollBytes);
    final liveImg = _decodeOriented(liveBytes);
    if (enrollImg == null || liveImg == null) {
      return const FaceMatchResult(
        matched: false,
        score: 0,
        message: 'Foto tidak bisa dibaca.',
      );
    }

    // Tulis gambar yang sudah tegak ke temporary file agar ML Kit mendeteksi di koordinat tegak
    final enrollTemp = await _writeImageTemp(enrollImg, 'enroll');
    final liveTemp = await _writeImageTemp(liveImg, 'live');

    final detector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    try {
      final enrollFace = await _detectLargestFromPath(detector, enrollTemp.path);
      final liveFace = await _detectLargestFromPath(detector, liveTemp.path);

      if (liveFace == null) {
        return const FaceMatchResult(
          matched: false,
          score: 0,
          message: 'Wajah tidak terdeteksi pada kamera. Pastikan wajah terlihat jelas.',
        );
      }

      // Potong wajah ter-normalisasi (prioritas posisi mata jika ada)
      final enrollCrop = _cropAlignedFace(enrollImg, enrollFace);
      final liveCrop = _cropAlignedFace(liveImg, liveFace);

      if (enrollCrop == null || liveCrop == null) {
        return const FaceMatchResult(
          matched: false,
          score: 0,
          message: 'Gagal memproses area wajah. Coba lagi.',
        );
      }

      // 1. Evaluasi kemiripan visual per-blok (mata, hidung, mulut, dan kontur wajah)
      final visual = _compareVisualBlocks(enrollCrop, liveCrop);

      // Cek apakah zona mata & alis cocok (fitur identitas terkuat manusia)
      if (visual.cosEyes < minEyeSimilarity) {
        final score = visual.visualScore;
        return FaceMatchResult(
          matched: false,
          score: score,
          message:
              'Ciri mata/alis tidak sesuai foto enroll (kemiripan ${(visual.cosEyes * 100).toInt()}%). Absensi ditolak.',
        );
      }

      // 2. Evaluasi proporsi geometris landmark tulang wajah
      final geomScore = _calculateGeomScore(enrollFace, liveFace);

      // Jika kedua foto memiliki landmark tetapi proporsi tulang wajah berbeda drastis, tolak
      if (geomScore != null && geomScore < 0.40) {
        final score = (visual.visualScore * 0.4) + (geomScore * 0.2);
        return FaceMatchResult(
          matched: false,
          score: score,
          message:
              'Proporsi struktur wajah tidak sesuai foto enroll (skor ${(geomScore * 100).toInt()}%). Absensi ditolak.',
        );
      }

      // 3. Hitung skor akhir gabungan
      final double finalScore;
      final double threshold;
      if (geomScore != null) {
        // Landmark lengkap: 55% visual blocks + 45% geometri tulang wajah
        finalScore = (visual.visualScore * 0.55) + (geomScore * 0.45);
        threshold = matchThreshold;
      } else {
        // Tanpa landmark: murni visual dengan threshold lebih ketat
        finalScore = visual.visualScore;
        threshold = matchThresholdNoLandmark;
      }

      if (finalScore >= threshold) {
        return FaceMatchResult(
          matched: true,
          score: finalScore,
          message: 'Wajah sesuai',
        );
      }

      return FaceMatchResult(
        matched: false,
        score: finalScore,
        message:
            'Wajah tidak sesuai foto enroll (Kecocokan ${(finalScore * 100).toInt()}%, min ${(threshold * 100).toInt()}%). Absensi ditolak.',
      );
    } finally {
      await detector.close();
      try {
        if (await enrollTemp.exists()) await enrollTemp.delete();
      } catch (_) {}
      try {
        if (await liveTemp.exists()) await liveTemp.delete();
      } catch (_) {}
    }
  }

  static bool _isJpeg(Uint8List bytes) {
    return bytes.length > 200 && bytes[0] == 0xFF && bytes[1] == 0xD8;
  }

  static img.Image _copy(img.Image src) {
    return img.copyResize(src, width: src.width, height: src.height);
  }

  static img.Image? _decodeOriented(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    try {
      return img.bakeOrientation(decoded);
    } catch (_) {
      return decoded;
    }
  }

  static Future<File> _writeImageTemp(img.Image image, String prefix) async {
    final dir = Directory.systemTemp;
    final file = File(
        '${dir.path}/face_${prefix}_${DateTime.now().microsecondsSinceEpoch}.jpg');
    final jpgBytes = Uint8List.fromList(img.encodeJpg(image, quality: 85));
    await file.writeAsBytes(jpgBytes, flush: true);
    return file;
  }

  static Future<Face?> _detectLargestFromPath(
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

  /// Potong wajah secara ter-normalisasi:
  /// Jika landmark kedua mata ada, sejajarkan kemiringan dan pusatkan di kanonikal 64x64.
  /// Jika tidak ada, gunakan bounding box wajah dengan margin proporsional.
  static img.Image? _cropAlignedFace(img.Image src, Face? face) {
    if (face == null) return _centerCrop(src);

    final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;

    if (leftEye != null && rightEye != null) {
      final eyeDist = leftEye.distanceTo(rightEye).toDouble();
      if (eyeDist >= 10) {
        final eyeMidX = (leftEye.x + rightEye.x) / 2.0;
        final eyeMidY = (leftEye.y + rightEye.y) / 2.0;

        final angleRad =
            math.atan2(rightEye.y - leftEye.y, rightEye.x - leftEye.x);
        final angleDeg = angleRad * 180.0 / math.pi;

        var orientedSrc = src;
        var centerX = eyeMidX;
        var centerY = eyeMidY + (eyeDist * 0.35);

        // Jika kepala sedikit miring (> 4 derajat), luruskan
        if (angleDeg.abs() > 4.0 && angleDeg.abs() < 45.0) {
          try {
            orientedSrc = img.copyRotate(src, angle: -angleDeg);
            final rad = -angleRad;
            final cosT = math.cos(rad);
            final sinT = math.sin(rad);
            final originX = src.width / 2.0;
            final originY = src.height / 2.0;
            final relX = centerX - originX;
            final relY = centerY - originY;
            centerX = originX + (relX * cosT - relY * sinT);
            centerY = originY + (relX * sinT + relY * cosT);
          } catch (_) {
            orientedSrc = src;
            centerX = eyeMidX;
            centerY = eyeMidY + (eyeDist * 0.35);
          }
        }

        final cropW = (eyeDist * 2.5).round();
        final cropH = (eyeDist * 3.0).round();
        var cropX = (centerX - (cropW / 2.0)).round();
        var cropY = (centerY - (cropH * 0.45)).round();

        if (cropX < 0) cropX = 0;
        if (cropY < 0) cropY = 0;
        if (cropX + cropW > orientedSrc.width) {
          cropX = math.max(0, orientedSrc.width - cropW);
        }
        if (cropY + cropH > orientedSrc.height) {
          cropY = math.max(0, orientedSrc.height - cropH);
        }
        final actualW = math.min(cropW, orientedSrc.width - cropX);
        final actualH = math.min(cropH, orientedSrc.height - cropY);

        if (actualW >= 20 && actualH >= 20) {
          final cropped = img.copyCrop(orientedSrc,
              x: cropX, y: cropY, width: actualW, height: actualH);
          return img.copyResize(cropped, width: 64, height: 64);
        }
      }
    }

    return _cropFaceBox(src, face);
  }

  static img.Image? _cropFaceBox(img.Image src, Face face) {
    final box = face.boundingBox;
    final padX = (box.width * 0.15).round();
    final padY = (box.height * 0.20).round();
    var x = box.left.round() - padX;
    var y = box.top.round() - padY;
    var w = box.width.round() + (padX * 2);
    var h = box.height.round() + (padY * 2);
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x + w > src.width) w = src.width - x;
    if (y + h > src.height) h = src.height - y;
    if (w < 20 || h < 20) return _centerCrop(src);
    final cropped = img.copyCrop(src, x: x, y: y, width: w, height: h);
    return img.copyResize(cropped, width: 64, height: 64);
  }

  static img.Image? _centerCrop(img.Image src) {
    final side = math.min(src.width, src.height);
    if (side < 20) return null;
    final x = ((src.width - side) / 2).round();
    final y = ((src.height - side) / 2).round();
    final cropped = img.copyCrop(src, x: x, y: y, width: side, height: side);
    return img.copyResize(cropped, width: 64, height: 64);
  }

  /// Evaluasi proporsi anatomis tulang wajah:
  /// Mengukur rasio jarak antar organ terhadap jarak mata.
  /// Skala-invarian dan rotasi-invarian.
  /// Mengembalikan null jika landmark tidak terdeteksi pada salah satu foto (BUKAN 1.0!).
  static double? _calculateGeomScore(Face? a, Face? b) {
    if (a == null || b == null) return null;

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

    // Jika landmark mata tidak lengkap, JANGAN berikan nilai gratis 1.0!
    if (aLeftEye == null ||
        aRightEye == null ||
        bLeftEye == null ||
        bRightEye == null) {
      return null;
    }

    final aEyeDist = aLeftEye.distanceTo(aRightEye).toDouble();
    final bEyeDist = bLeftEye.distanceTo(bRightEye).toDouble();
    if (aEyeDist < 8 || bEyeDist < 8) return null;

    var diffSum = 0.0;
    var count = 0;

    final aEyeMidX = (aLeftEye.x + aRightEye.x) / 2.0;
    final aEyeMidY = (aLeftEye.y + aRightEye.y) / 2.0;
    final bEyeMidX = (bLeftEye.x + bRightEye.x) / 2.0;
    final bEyeMidY = (bLeftEye.y + bRightEye.y) / 2.0;

    // 1. Rasio jarak mata ke ujung hidung vs jarak antar mata (bobot ganda)
    if (aNose != null && bNose != null) {
      final aNoseDist = math.sqrt(
          math.pow(aNose.x - aEyeMidX, 2) + math.pow(aNose.y - aEyeMidY, 2));
      final bNoseDist = math.sqrt(
          math.pow(bNose.x - bEyeMidX, 2) + math.pow(bNose.y - bEyeMidY, 2));
      final aRatio = aNoseDist / aEyeDist;
      final bRatio = bNoseDist / bEyeDist;
      final maxR = math.max(aRatio, bRatio);
      if (maxR > 0) {
        diffSum += ((aRatio - bRatio).abs() / maxR) * 2.0;
        count += 2;
      }

      // 2. Rasio jarak hidung ke tengah mulut
      if (aMouthLeft != null &&
          aMouthRight != null &&
          bMouthLeft != null &&
          bMouthRight != null) {
        final aMouthMidX = (aMouthLeft.x + aMouthRight.x) / 2.0;
        final aMouthMidY = (aMouthLeft.y + aMouthRight.y) / 2.0;
        final bMouthMidX = (bMouthLeft.x + bMouthRight.x) / 2.0;
        final bMouthMidY = (bMouthLeft.y + bMouthRight.y) / 2.0;

        final aNMDur = math.sqrt(math.pow(aNose.x - aMouthMidX, 2) +
            math.pow(aNose.y - aMouthMidY, 2));
        final bNMDur = math.sqrt(math.pow(bNose.x - bMouthMidX, 2) +
            math.pow(bNose.y - bMouthMidY, 2));
        final aRatioNM = aNMDur / aEyeDist;
        final bRatioNM = bNMDur / bEyeDist;
        final maxRNM = math.max(aRatioNM, bRatioNM);
        if (maxRNM > 0) {
          diffSum += (aRatioNM - bRatioNM).abs() / maxRNM;
          count++;
        }
      }
    }

    // 3. Rasio lebar bibir vs jarak antar mata
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

    // 4. Aspek rasio kontur wajah (lebar / tinggi bounding box)
    final aBoxRatio =
        a.boundingBox.width / math.max(1.0, a.boundingBox.height.toDouble());
    final bBoxRatio =
        b.boundingBox.width / math.max(1.0, b.boundingBox.height.toDouble());
    final maxBox = math.max(aBoxRatio, bBoxRatio);
    if (maxBox > 0) {
      diffSum += (aBoxRatio - bBoxRatio).abs() / maxBox;
      count++;
    }

    if (count == 0) return null;
    final avgDiff = diffSum / count;

    // Rata-rata perbedaan <= 5% -> score 1.0
    // Rata-rata perbedaan == 15% -> score 0.50
    // Rata-rata perbedaan >= 25% -> score 0.0
    final score = 1.0 - ((avgDiff - 0.05) / 0.20);
    return score.clamp(0.0, 1.0);
  }

  /// Ekstraksi fitur visual berbasis gradien Sobel & perbandingan blok 4x4:
  /// Membagi wajah 64x64 menjadi 16 blok (16x16 px).
  /// Membandingkan blok mata, hidung/mulut, dan keseluruhan wajah.
  static _VisualMatchDetails _compareVisualBlocks(
    img.Image enrollCrop,
    img.Image liveCrop,
  ) {
    final enrollResized = img.copyResize(enrollCrop, width: 64, height: 64);
    final liveResized = img.copyResize(liveCrop, width: 64, height: 64);

    final enrollGray = img.grayscale(enrollResized);
    final liveGray = img.grayscale(liveResized);

    // Citra gradien Sobel menghilangkan pengaruh variasi pencahayaan
    final enrollGrad = _gradientImage(enrollGray);
    final enrollFull = _toVector(enrollGrad);

    // Ambil vektor blok enroll (4 baris x 4 kolom, masing-masing 16x16)
    final enrollBlocks = <List<double>>[];
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        enrollBlocks.add(_toVectorSub(enrollGrad, c * 16, r * 16, 16, 16));
      }
    }

    final variants = <img.Image>[
      liveGray,
      img.flipHorizontal(_copy(liveGray)),
    ];

    var bestVisualScore = 0.0;
    var bestCosEyes = 0.0;
    var bestCosNoseMouth = 0.0;
    var bestCosFull = 0.0;

    // Evaluasi toleransi pergeseran mikro (-1, 0, 1 px)
    for (final vGray in variants) {
      for (final dy in [0, -1, 1]) {
        for (final dx in [0, -1, 1]) {
          final shifted =
              (dx == 0 && dy == 0) ? vGray : _shiftImage(vGray, dx, dy);
          final liveGrad = _gradientImage(shifted);

          final cosFull = _cosine(enrollFull, _toVector(liveGrad));

          // Hitung kemiripan tiap blok 16x16
          // Blok (c, r): index = r * 4 + c
          // Mata kiri: c=1, r=1 -> idx 5
          // Mata kanan: c=2, r=1 -> idx 6
          // Hidung: c=1..2, r=2 -> idx 9, 10
          // Mulut: c=1..2, r=3 -> idx 13, 14
          final sLefteye =
              _cosine(enrollBlocks[5], _toVectorSub(liveGrad, 16, 16, 16, 16));
          final sRightEye =
              _cosine(enrollBlocks[6], _toVectorSub(liveGrad, 32, 16, 16, 16));
          final cosEyes = (sLefteye + sRightEye) / 2.0;

          final sNoseL =
              _cosine(enrollBlocks[9], _toVectorSub(liveGrad, 16, 32, 16, 16));
          final sNoseR =
              _cosine(enrollBlocks[10], _toVectorSub(liveGrad, 32, 32, 16, 16));
          final sMouthL =
              _cosine(enrollBlocks[13], _toVectorSub(liveGrad, 16, 48, 16, 16));
          final sMouthR =
              _cosine(enrollBlocks[14], _toVectorSub(liveGrad, 32, 48, 16, 16));
          final cosNoseMouth = (sNoseL + sNoseR + sMouthL + sMouthR) / 4.0;

          // Bobot gabungan visual: 40% Mata + 35% Hidung/Mulut + 25% Seluruh Wajah
          final score =
              (cosEyes * 0.40) + (cosNoseMouth * 0.35) + (cosFull * 0.25);

          if (score > bestVisualScore) {
            bestVisualScore = score;
            bestCosEyes = cosEyes;
            bestCosNoseMouth = cosNoseMouth;
            bestCosFull = cosFull;
          }
        }
      }
    }

    return _VisualMatchDetails(
      visualScore: bestVisualScore,
      cosEyes: bestCosEyes,
      cosNoseMouth: bestCosNoseMouth,
      cosFull: bestCosFull,
    );
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
}

