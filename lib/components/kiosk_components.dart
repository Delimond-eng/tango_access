import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/style.dart';

class KioskColors {
  static const Color surface = Colors.white;
  static const Color outline = Color(0xFFD3DEEE);
  static const Color textHigh = Color(0xFF0B1220);
  static const Color textMid = Color(0xFF4D5B78);
  static const Color textLow = Color(0xFF8A96AE);
  static const Color success = Color(0xFF0F9D74);
  static const Color danger = Color(0xFFE03131);
}

double kioskScale(BuildContext context) =>
    (MediaQuery.of(context).size.width / 390).clamp(0.82, 1.2).toDouble();

TextStyle kioskTitle(BuildContext context) => TextStyle(
  fontSize: 28 * kioskScale(context),
  fontWeight: FontWeight.w800,
  color: KioskColors.textHigh,
  fontFamily: 'Ubuntu',
  letterSpacing: -0.2,
);

TextStyle kioskSubtitle(BuildContext context) => TextStyle(
  fontSize: 19 * kioskScale(context),
  fontWeight: FontWeight.w700,
  color: KioskColors.textHigh,
  fontFamily: 'Ubuntu',
  letterSpacing: 0.1,
);

TextStyle kioskBody(BuildContext context) => TextStyle(
  fontSize: 15 * kioskScale(context),
  fontWeight: FontWeight.w500,
  color: KioskColors.textMid,
  fontFamily: 'Ubuntu',
  height: 1.35,
);

TextStyle kioskCaption(BuildContext context) => TextStyle(
  fontSize: 13 * kioskScale(context),
  fontWeight: FontWeight.w600,
  color: KioskColors.textLow,
  fontFamily: 'Ubuntu',
  letterSpacing: 0.2,
);

class KioskBrandHeader extends StatelessWidget {
  final String? subtitle;
  const KioskBrandHeader({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scale = kioskScale(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KioskColors.surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: secondary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48 * scale,
            height: 48 * scale,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C2C2C), // Noir grisâtre soft
                  Color(0xFF000000), // Noir pur
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                "assets/images/tango.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "TANGO PROTECTION ACCESS",
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Ubuntu',
                  color: KioskColors.textHigh,
                  letterSpacing: 0.7,
                ),
              ),
              Text(
                subtitle ?? "Terminal Agent",
                style: TextStyle(
                  color: KioskColors.textLow,
                  fontSize: 11 * scale,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScannerControl extends StatelessWidget {
  const ScannerControl({super.key, required this.icon, required this.onTap, this.isPrimary = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary; // Ajout d'une option pour différencier flash et refresh

  @override
  Widget build(BuildContext context) {
    final scale = kioskScale(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.amber.withOpacity(0.25) : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22 * scale),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 28 * scale,
                color: isPrimary ? Colors.amber.shade100 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KioskBadge extends StatelessWidget {
  const KioskBadge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scale = kioskScale(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 7 * scale,
      ),
      decoration: BoxDecoration(
        color: KioskColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: KioskColors.success.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: KioskColors.success,
          fontWeight: FontWeight.w800,
          fontSize: 11.5 * scale,
          fontFamily: 'Ubuntu',
          letterSpacing: 0.35,
        ),
      ),
    );
  }
}
