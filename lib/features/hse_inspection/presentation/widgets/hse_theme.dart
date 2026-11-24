import 'package:flutter/material.dart';

class HseTheme {
  static const Color primaryOrange = Color(0xFFFF8C69);
  static const Color lightOrange = Color(0xFFFFF4E6);
  static const Color accentOrange = Color(0xFFFFB347);
  static const Color darkOrange = Color(0xFFE07B39);
  static const Color backgroundColor = Color(0xFFFFFAF5);
  static const Color cardColor = Color(0xFFFFF8F0);
  static const Color shadowColor = Color(0x20FF8C69);
  static const Color borderOrangeSoft = Color(0x59FFB347);
  static const Color borderOrangeMid = Color(0x73FFB347);

  static const Color lockRed = Color(0xFFD32F2F);
  static const Color lockRedBg = Color(0xFFFFEBEE);
  static const Color unlockGreen = Color(0xFF2E7D32);
  static const Color unlockGreenBg = Color(0xFFE8F5E9);
  static const Color waitAmber = Color(0xFFEF6C00);
  static const Color waitAmberBg = Color(0xFFFFF3E0);

  static InputDecoration softDecoration({
    String? label,
    String? hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
    );
  }

  static ButtonStyle btnStyle(Color bg) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bg,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      shadowColor: Colors.transparent,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    );
  }

  static Widget btnLabel(String text, {double size = 13}) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: size,
      ),
    );
  }

  static Widget fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.grey.shade800,
      ),
    );
  }

  static BoxDecoration softCardDecoration({double radius = 16}) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderOrangeSoft),
      boxShadow: const [
        BoxShadow(
          color: shadowColor,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static IconData entityIcon(String entityType) {
    switch (entityType.toUpperCase()) {
      case 'KARYAWAN':
        return Icons.badge_outlined;
      case 'DRIVER':
        return Icons.person_pin_outlined;
      case 'MOBIL':
        return Icons.local_shipping_outlined;
      default:
        return Icons.verified_user_outlined;
    }
  }

  static void showImagePreviewDialog(
    BuildContext context, {
    required String imageUrl,
    required String title,
  }) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: darkOrange,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.65,
              ),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Gagal memuat gambar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HseStatusBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const HseStatusBadge({
    Key? key,
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.icon,
  }) : super(key: key);

  factory HseStatusBadge.fromStatusFlow(String statusFlow, bool isLocked) {
    final sf = statusFlow.toUpperCase();
    if (sf == 'COMPLETE' || sf == 'SELESAI') {
      return const HseStatusBadge(
        text: 'SELESAI',
        bgColor: HseTheme.unlockGreenBg,
        textColor: HseTheme.unlockGreen,
        icon: Icons.check_circle_rounded,
      );
    }
    if (sf == 'ONGOING' || sf == 'OPEN') {
      return const HseStatusBadge(
        text: 'ONGOING',
        bgColor: HseTheme.lightOrange,
        textColor: HseTheme.darkOrange,
        icon: Icons.pending_actions_rounded,
      );
    }
    if (sf == 'BP' || sf == 'IN_PROGRESS' || sf == 'APPROVED') {
      return const HseStatusBadge(
        text: 'APPROVED',
        bgColor: HseTheme.lockRedBg,
        textColor: HseTheme.lockRed,
        icon: Icons.check_circle_outline,
      );
    }
    if (sf == 'WAITING_FINAL') {
      return const HseStatusBadge(
        text: 'WAITING FINAL',
        bgColor: HseTheme.waitAmberBg,
        textColor: HseTheme.waitAmber,
        icon: Icons.hourglass_bottom_rounded,
      );
    }
    if (sf == 'WAITING_SHE') {
      return HseStatusBadge(
        text: 'WAITING SHE',
        bgColor: HseTheme.lightOrange,
        textColor: HseTheme.darkOrange,
        icon: Icons.verified_outlined,
      );
    }
    if (sf == 'REJECTED') {
      return HseStatusBadge(
        text: isLocked ? 'REJECTED (BP)' : 'REJECTED',
        bgColor: HseTheme.lockRedBg,
        textColor: HseTheme.lockRed,
        icon: Icons.cancel_outlined,
      );
    }
    return HseStatusBadge(
      text: isLocked ? '$sf (LOCKED)' : sf,
      bgColor: isLocked ? HseTheme.lockRedBg : Colors.grey.shade200,
      textColor: isLocked ? HseTheme.lockRed : Colors.grey.shade700,
      icon: isLocked ? Icons.lock_rounded : Icons.info_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

