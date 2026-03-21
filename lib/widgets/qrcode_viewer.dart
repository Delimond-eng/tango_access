import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taxenew/theme/style.dart';

class QrcodeBottomSheet extends StatelessWidget {
  final String qrData;
  final String visitorName;
  final Map<String, dynamic>? specs;

  const QrcodeBottomSheet({
    super.key,
    required this.qrData,
    required this.visitorName,
    this.specs,
  });

  @override
  Widget build(BuildContext context) {
    GlobalKey globalKey = GlobalKey();

    Future<void> shareQrCode() async {
      try {
        RenderRepaintBoundary boundary =
            globalKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/qrcode.png').create();
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Voici le pass d\'accès pour $visitorName');
      } catch (e) {
        print("Erreur partage QR: $e");
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
            ),
            const Text(
              "Pass d'accès généré",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.indigo),
            ),
            const SizedBox(height: 20),
            RepaintBoundary(
              key: globalKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      size: 180,
                      backgroundColor: Colors.white,
                      embeddedImage: const AssetImage("assets/images/tango.png"),
                      embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(35, 35)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      visitorName.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    if (specs != null) ...[
                       const SizedBox(height: 8),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(_getModeIcon(specs!["mode"]), size: 14, color: Colors.grey),
                           const SizedBox(width: 5),
                           Text(
                             _getModeLabel(specs!["mode"]),
                             style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                           ),
                         ],
                       ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: shareQrCode,
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text("PARTAGER LE PASS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  IconData _getModeIcon(String? mode) {
    switch (mode) {
      case "car": return Icons.directions_car;
      case "taxi": return Icons.local_taxi;
      default: return Icons.directions_walk;
    }
  }

  String _getModeLabel(String? mode) {
    switch (mode) {
      case "car": return "En Voiture";
      case "taxi": return "En Taxi";
      default: return "À pied";
    }
  }
}
