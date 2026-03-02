import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taxenew/utils/app_theme.dart';

class QrcodeBottomSheet extends StatelessWidget {
  final String qrData; // url ou token
  final String visitorName; 

  const QrcodeBottomSheet({
    super.key,
    required this.qrData,
    required this.visitorName,
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
        ], text: 'my_qr_share_text'.tr);
      } catch (e) {
        print("Erreur partage QR: $e");
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Text(
              "please_share_qr".tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              "qr_validity_note".tr,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: globalKey,
              child: QrImageView(
                data: qrData,
                size: 200,
                backgroundColor: Colors.white,
                embeddedImage: const AssetImage("assets/images/tango.png"),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),
            Text(
              visitorName,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800),
            ).paddingTop(8.0),
            const SizedBox(height: 20),
        
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60.0),
                border: Border.all(color: Colors.blue, width: 2.0),
              ),
              child: Container(
                height: 60.0,
                width: 60.0,
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60.0),
                  gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(60.0),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(60.0),
                    onTap: shareQrCode,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.share, color: Colors.white)],
                    ),
                  ),
                ),
              ),
            ),
        
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
