import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../screens/auth/login.dart';
import '../screens/main_screen.dart';
import '../pages/member_page.dart';
import '../pages/history_page.dart';
import '../theme/style.dart';
import '../utils/controllers.dart';
import '../utils/store.dart';

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

TextStyle kioskSubtitle(BuildContext context) => TextStyle(
  fontSize: 19 * kioskScale(context),
  fontWeight: FontWeight.w700,
  color: KioskColors.textHigh,
  fontFamily: 'Ubuntu',
  letterSpacing: 0.1,
);

class KioskBrandHeader extends StatelessWidget {
  final String? subtitle;
  const KioskBrandHeader({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scale = kioskScale(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
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
                  Color(0xFF2C2C2C),
                  Color(0xFF000000),
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
                  color:primaryColor,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 5.0,),
              Text(
                subtitle ?? "Terminal Agent",
                style: TextStyle(
                  color: Colors.grey.shade300,
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

class KioskBottomBar extends StatelessWidget {
  final int activeIndex;
  const KioskBottomBar({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.92),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavIcon(Icons.home_rounded, activeIndex == 0, () {
              if (activeIndex != 0) Get.offAll(() => const MainScreen(), transition: Transition.noTransition);
            }),
            _buildNavIcon(Icons.group_rounded, activeIndex == 1, () {
              if (activeIndex != 1) Get.to(() => const MemberPage(), transition: Transition.cupertino);
            }),
            _buildNavIcon(Icons.history_rounded, activeIndex == 2, () {
              if (activeIndex != 2) Get.to(() => const HistoryPage(), transition: Transition.cupertino);
            }),
            _buildNavIcon(CupertinoIcons.square_grid_2x2, activeIndex == 3, () => _showProfileMenu(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black87 : Colors.white70,
          size: 24
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Container(
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
                Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5))),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: secondary.withOpacity(0.1),
                    child: Text(
                      authController.user.value!.nom.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: secondary, fontWeight: FontWeight.bold)
                    )
                  ),
                  title: Text("${'hello'.tr}, ${authController.user.value!.nom}", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Ubuntu', fontSize: 18)),
                  subtitle: Text(authController.user.value!.email, style: const TextStyle(fontFamily: 'Ubuntu')),
                ),
                const Divider(height: 32),
                _buildSheetAction(
                  icon: Icons.language_rounded, 
                  title: 'language'.tr, 
                  subtitle: 'change_language'.tr, 
                  onTap: () { Navigator.pop(sheetContext); _showLanguageDialog(context); }
                ),
                const SizedBox(height: 12),
                _buildSheetAction(
                  icon: Icons.history, 
                  title: 'history'.tr, 
                  subtitle: 'all_validated_visits'.tr, 
                  onTap: () { Navigator.pop(sheetContext); if (activeIndex != 2) Get.to(() => const HistoryPage(), transition: Transition.cupertino); }
                ),
                const SizedBox(height: 12),
                _buildSheetAction(
                  icon: Icons.group, 
                  title: 'members'.tr, 
                  subtitle: 'permanent_members'.tr, 
                  onTap: () { Navigator.pop(sheetContext); if (activeIndex != 1) Get.to(() => const MemberPage(), transition: Transition.cupertino); }
                ),
                const SizedBox(height: 12),
                _buildSheetAction(
                  icon: Icons.logout, 
                  title: 'logout'.tr, 
                  subtitle: 'logout_confirm_desc'.tr, 
                  color: Colors.red, 
                  onTap: () { Navigator.pop(sheetContext); _showLogoutConfirmation(context); }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetAction({required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color color = Colors.black87}) {
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
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: 'Ubuntu', fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontFamily: 'Ubuntu')) : null,
        trailing: Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final scale = kioskScale(context);
    final storage = GetStorage();
    String currentLang = storage.read('lang') ?? 'fr';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28 * scale),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('select_language'.tr, style: kioskSubtitle(context)),
              const SizedBox(height: 20),
              _buildLanguageOption("fr", 'french'.tr, currentLang == "fr"),
              const SizedBox(height: 12),
              _buildLanguageOption("en", 'english'.tr, currentLang == "en"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String label, bool isSelected) {
    return InkWell(
      onTap: () {
        Get.updateLocale(Locale(code));
        GetStorage().write('lang', code);
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? secondary.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? secondary : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontFamily: 'Ubuntu')),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.indigo, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
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
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 28),
              ),
              const SizedBox(height: 18),
              Text('logout_confirm_title'.tr, style: TextStyle(fontSize: 19 * scale, fontWeight: FontWeight.w700, color: Colors.black87, fontFamily: 'Ubuntu')),
              const SizedBox(height: 8),
              Text('logout_confirm_desc'.tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 13 * scale, color: Colors.grey.shade600, fontFamily: 'Ubuntu', height: 1.4)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontFamily: 'Ubuntu')),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                      ),
                      child: Text('logout'.tr, style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Ubuntu')),
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
