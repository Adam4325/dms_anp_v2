import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dms_anp/src/services/DeliveryRateService.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DeliveryRateDialog extends StatefulWidget {
  final String doNumber;
  final String driverId;
  final String status;
  final Function(int rate, bool isTimeout) onCompleted;

  const DeliveryRateDialog({
    Key? key,
    required this.doNumber,
    required this.driverId,
    this.status = "OUTUNLOADING",
    required this.onCompleted,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String doNumber,
    required String driverId,
    String status = "OUTUNLOADING",
    required Function(int rate, bool isTimeout) onCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DeliveryRateDialog(
        doNumber: doNumber,
        driverId: driverId,
        status: status,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<DeliveryRateDialog> createState() => _DeliveryRateDialogState();
}

class _DeliveryRateDialogState extends State<DeliveryRateDialog> {
  static const int _totalSeconds = 60;
  int _remainingSeconds = _totalSeconds;
  Timer? _countdownTimer;
  int _selectedStars = 0;
  bool _isSubmitting = false;
  String _customerPhone = "";
  String _formattedWaPhone = "";

  @override
  void initState() {
    super.initState();
    _fetchPhone();
    _startCountdown();
  }

  void _fetchPhone() async {
    final result = await DeliveryRateService.getCustomerPhone(widget.doNumber);
    if (mounted) {
      setState(() {
        _customerPhone = result["customer_phone"] ?? "0815-4621-5818";
        _formattedWaPhone = result["formatted_phone"] ?? "6281546215818";
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Waktu habis 60 detik (Idle / Timeout)
        timer.cancel();
        _handleTimeoutAutoRateZero();
      }
    });
  }

  /// Penanganan jika dalam 1 menit driver idle / tidak memberi rating
  void _handleTimeoutAutoRateZero() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _remainingSeconds = 0;
    });

    EasyLoading.showToast(
      "Waktu rating habis (1 menit). Rating otomatis bernilai 0.",
      duration: const Duration(seconds: 2),
      toastPosition: EasyLoadingToastPosition.bottom,
    );

    // Otomatis kirim rate = 0 ke backend API
    await DeliveryRateService.submitDeliveryRate(
      doNumber: widget.doNumber,
      rate: 0,
      status: widget.status,
      drvid: widget.driverId,
      hpNumber: _customerPhone,
    );

    if (mounted) {
      Navigator.of(context).pop();
      widget.onCompleted(0, true);
    }
  }

  /// Penanganan jika driver memilih rating manual sebelum 60 detik
  void _handleManualRating(int star) async {
    if (_isSubmitting) return;
    _countdownTimer?.cancel(); // Batalkan timer 60 detik

    setState(() {
      _selectedStars = star;
      _isSubmitting = true;
    });

    EasyLoading.show(status: 'Menyimpan rating $star bintang...');

    await DeliveryRateService.submitDeliveryRate(
      doNumber: widget.doNumber,
      rate: star,
      status: widget.status,
      drvid: widget.driverId,
      hpNumber: _customerPhone,
    );

    EasyLoading.dismiss();

    if (mounted) {
      Navigator.of(context).pop();
      widget.onCompleted(star, false);
    }
  }

  /// Membagikan rating langsung ke WhatsApp customer
  void _shareToWhatsApp() async {
    final int expiryMs = DateTime.now().millisecondsSinceEpoch + (3 * 24 * 60 * 60 * 1000); // Masa berlaku 3 hari
    final String raw = '${widget.driverId}:::${widget.doNumber}:::$expiryMs';
    final String token = base64Url.encode(utf8.encode(raw)).replaceAll('=', '');
    final String shareUrl = 'https://apps.tuluatas.com/trucking/given_rate.jsp?q=$token';

    final phone = _formattedWaPhone.isNotEmpty ? _formattedWaPhone : "6281546215818";
    await DeliveryRateService.openWhatsApp(
      phoneWa: phone,
      doNumber: widget.doNumber,
      ratingUrl: shareUrl,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / _totalSeconds;
    final isUrgent = _remainingSeconds <= 15;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Badge & Countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF57C00), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "PENILAIAN DO",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                // Timer Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isUrgent ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUrgent ? Colors.red.shade300 : Colors.green.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: isUrgent ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$_remainingSeconds s",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUrgent ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar Countdown
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUrgent ? Colors.red.shade600 : Colors.orange.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Info
            const Text(
              "Bagikan Nilai Layanan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "No DO: ${widget.doNumber}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade700,
              ),
            ),
            if (_customerPhone.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                "Telp Customer: $_customerPhone",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Star Rating Selector (1 - 5 Bintang)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1;
                final isSelected = _selectedStars >= starVal;
                return GestureDetector(
                  onTap: _isSubmitting ? null : () => _handleManualRating(starVal),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isSelected ? const Color(0xFFFFB300) : Colors.grey.shade400,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              "Ketuk bintang di atas atau kirim link ke WhatsApp",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                // Tombol Bagikan WhatsApp
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _shareToWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text(
                      "Kirim WhatsApp",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Lewati / Selesai
                OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          _countdownTimer?.cancel();
                          _handleTimeoutAutoRateZero();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "Lewati (0★)",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
