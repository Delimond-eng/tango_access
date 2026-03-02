import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:taxenew/pages/member_page.dart';
import 'package:taxenew/services/api_manager.dart';
import '../components/kiosk_components.dart';
import '../pages/history_page.dart';
import '../utils/controllers.dart';
import '../utils/store.dart';
import '/theme/style.dart';
import 'auth/login.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class MainScreenAgent extends StatefulWidget {
  const MainScreenAgent({super.key});

  @override
  State<MainScreenAgent> createState() => _MainScreenAgentState();
}

class _MainScreenAgentState extends State<MainScreenAgent> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isLight = false;
  QRViewController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (dataController.isScanned.value == false) {
        processScan(scanData.code!);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (GetPlatform.isAndroid) {
        controller!.pauseCamera();
      }
      controller!.resumeCamera();
    }
  }

  // Étape 1 : Vérification des infos sans consommer le QR
  Future<void> processScan(String token) async {
    dataController.isScanned.value = true;
    controller?.pauseCamera();
    
    EasyLoading.show(status: "Vérification du code...");
    
    try {
      final res = await ApiManager().getScanInfos(token: token);
      
      if (res is Map && res.containsKey("qrcode")) {
        bool expired = res["status"] != "accepted";
        
        showScanInfos(
          qrcode: res["qrcode"]["token"],
          valideTo: res["qrcode"]["valid_to"] ?? "",
          resident: res["qrcode"]["unit"]?['resident']?['name'] ?? "N/A",
          visitor: res["qrcode"]["visitor"]?['name'] ?? "Inconnu",
          unit: res["qrcode"]["unit"]?['name'] ?? "N/A",
          isExpired: expired,
          errorMessage: expired ? (res["message"] ?? "Ce QR code est expiré ou déjà utilisé.") : null,
        );
      } else {
        dataController.isScanned.value = false;
        EasyLoading.showInfo(res is String ? res : "QR code invalide");
        controller?.resumeCamera();
      }
    } catch (e) {
      dataController.isScanned.value = false;
      EasyLoading.showError("Erreur de connexion réseau");
      controller?.resumeCamera();
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Étape 2 : Validation finale et consommation du QR
  Future<void> validateAccess(String token) async {
    EasyLoading.show(status: "Accord de l'accès...");
    
    try {
      var res = await ApiManager().scanQrcode(token: token);
      if (res is String) {
        EasyLoading.showError(res);
      } else {
        EasyLoading.showSuccess("Accès autorisé avec succès");
      }
    } catch (e) {
      EasyLoading.showError("Échec de la validation (réseau)");
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _showErrorModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QrModal(
        qrData: "",
        visitorName: "",
        dateTime: "",
        resident: "",
        unit: "",
        isExpired: true,
        errorMessage: message,
        onCancel: () {
          Navigator.pop(context);
        },
        onConfirm: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scannerSize = math.min(size.width * 0.8, 240.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.indigo.shade400,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigo.shade500,
                    Colors.indigo.shade300,

                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const KioskBrandHeader(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Scanner le QR Code",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Ubuntu',
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Text(
                          "Placez le code dans le cadre pour l'identifier",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            fontFamily: 'Ubuntu',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // CONTENEUR SCANNER AVEC EFFET GLASS
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: scannerSize + 20,
                          height: scannerSize + 20,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              children: [
                                QRView(
                                  key: qrKey,
                                  onQRViewCreated: _onQRViewCreated,
                                  overlay: QrScannerOverlayShape(
                                    borderColor: primaryColor,
                                    borderRadius: 20,
                                    borderLength: 30,
                                    borderWidth: 8,
                                    cutOutSize: scannerSize,
                                  ),
                                ),
                                Obx(() => dataController.isScanned.value
                                    ? Container(
                                        color: Colors.black.withOpacity(0.4),
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(Icons.refresh_rounded, size: 48, color: Colors.white),
                                            onPressed: () {
                                              dataController.isScanned.value = false;
                                              controller?.resumeCamera();
                                            },
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // BOUTONS DE CONTROLE STYLISÉS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScannerControl(
                        icon: isLight ? Icons.flash_off_rounded : Icons.flash_on_rounded,
                        onTap: () {
                          controller?.toggleFlash();
                          setState(() => isLight = !isLight);
                        },
                      ),
                      Obx(() => dataController.isScanned.value
                          ? Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: ScannerControl(
                                icon: Icons.refresh_rounded,
                                isPrimary: true, // Mise en avant du refresh
                                onTap: () {
                                  dataController.isScanned.value = false;
                                  controller?.resumeCamera();
                                },
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),

                  const Spacer(),

                  // SECTION PROFIL UTILISATEUR EN EFFET GLASS
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Obx(() {
                      final user = authController.user.value;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: showProfile,
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                        image: const DecorationImage(
                                          image: AssetImage("assets/images/male.jpg"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            user?.nom ?? "Agent Sécurité",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 17,
                                              fontFamily: 'Ubuntu',
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            user?.code ?? "Matricule ---",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(0.7),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Ubuntu',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.chevron_right,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  
                  // En-tête du Profil
                  Obx(() {
                    final user = authController.user.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: secondary.withOpacity(0.1),
                        child: Text(
                          user?.nom.substring(0, 1).toUpperCase() ?? "A",
                          style: TextStyle(color: secondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        user?.nom ?? "Agent",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Ubuntu'),
                      ),
                      subtitle: Text(
                        user?.email ?? "",
                        style: const TextStyle(fontSize: 12, fontFamily: 'Ubuntu'),
                      ),
                    );
                  }),
                  
                  const Divider(height: 32),
                  
                  _buildActionItem(
                    icon: Icons.history_rounded,
                    title: "Historique des visites",
                    subtitle: "Consulter tous les scans effectués",
                    color: secondary,
                    onTap: () {
                      Get.back();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionItem(
                    icon: Icons.group_rounded,
                    title: "Mes membres",
                    subtitle: "Gérer famille et employés",
                    color: Colors.blue.shade700,
                    onTap: () {
                      Get.back();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MemberPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionItem(
                    icon: Icons.logout_rounded,
                    title: "Déconnexion",
                    subtitle: "Fermer votre session actuelle",
                    color: Colors.red.shade700,
                    onTap: () {
                      Get.back();
                      _showLogoutConfirmation();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    final scale = kioskScale(context);
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56 * scale,
                height: 56 * scale,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Déconnexion",
                style: TextStyle(
                  fontSize: 19 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Voulez-vous vraiment fermer votre session ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13 * scale,
                  color: Colors.grey.shade600,
                  fontFamily: 'Ubuntu',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        localStorage.remove("user_session");
                        localStorage.erase();
                        Get.offAll(() => const Login());
                        authController.refreshUser();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                      ),
                      child: const Text(
                        "Déconnexion",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon, 
    required String title, 
    required String subtitle,
    required Color color, 
    required VoidCallback onTap
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontFamily: 'Ubuntu',
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontFamily: 'Ubuntu',
          ),
        ),
        trailing: Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  void showScanInfos({
    required String qrcode,
    required String visitor,
    required String valideTo,
    required String resident,
    required String unit,
    bool isExpired = false,
    String? errorMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QrModal(
        qrData: qrcode,
        visitorName: visitor,
        dateTime: valideTo,
        resident: resident,
        unit: unit,
        isExpired: isExpired,
        errorMessage: errorMessage,
        onCancel: () {
          Navigator.pop(context);
        },
        onConfirm: () {
          Navigator.pop(context);
          validateAccess(qrcode);
        },
      ),
    );
  }
}

class QrModal extends StatelessWidget {
  final String qrData;
  final String visitorName;
  final String resident;
  final String dateTime;
  final String unit;
  final bool isExpired;
  final String? errorMessage;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const QrModal({
    super.key,
    required this.qrData,
    required this.visitorName,
    required this.dateTime,
    required this.resident,
    required this.unit,
    required this.onConfirm,
    required this.onCancel,
    this.isExpired = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isExpired ? Colors.red : Colors.green).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpired ? Icons.error_outline_rounded : Icons.verified_rounded,
                  color: isExpired ? Colors.red : Colors.green.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isExpired ? "QR Code Invalide" : "Vérification validée",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isExpired ? Colors.red : secondary,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Ubuntu',
                  fontSize: 20,
                ),
              ),
              if (isExpired && errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Ubuntu',
                  ),
                ),
              ],
              
              if (!isExpired) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: QrImageView(
                    data: qrData,
                    size: 142,
                    backgroundColor: Colors.white,
                    embeddedImage: const AssetImage("assets/images/tango.png"),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(34, 34),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  visitorName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondary,
                    fontSize: 18,
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _ScanInfoTile(
                        icon: Icons.person_rounded,
                        label: "Résident visité",
                        value: resident,
                      ),
                      const SizedBox(height: 12),
                      _ScanInfoTile(
                        icon: Icons.apartment_rounded,
                        label: "Appartement / Box",
                        value: unit,
                      ),
                      const SizedBox(height: 12),
                      _ScanInfoTile(
                        icon: Icons.event_available_rounded,
                        label: "Horaire prévu",
                        value: dateTime.isEmpty ? "Accès permanent" : dateTime,
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 28),
              
              if (isExpired)
                SizedBox(
                  width: 140, 
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Fermer", style: TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: secondary.withOpacity(0.3)),
                        ),
                        child: Text("Annuler", style: TextStyle(color: secondary, fontFamily: 'Ubuntu')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text("Valider", style: TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ScanInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: secondary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: secondary,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScannerControl extends StatelessWidget {
  const ScannerControl({super.key, required this.icon, required this.onTap, this.isPrimary = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

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
