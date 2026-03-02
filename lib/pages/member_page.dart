import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxenew/services/api_manager.dart';
import 'package:taxenew/utils/controllers.dart';
import 'package:taxenew/widgets/custom_btn.dart';
import 'package:taxenew/widgets/qrcode_viewer.dart';
import 'package:taxenew/widgets/svg.dart';
import '../components/kiosk_components.dart';
import '../models/qrcode.dart';
import '../screens/auth/login.dart';
import '../theme/style.dart';
import '../screens/main_screen.dart';
import 'history_page.dart';
import '../utils/store.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataController.refreshMember();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgScaffold = Colors.indigo.shade50;
    final bgHeader = Colors.indigo.shade400;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgScaffold,
      extendBody: true,
      bottomNavigationBar: _buildFloatingBottomBar(),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Persistent Header
          SliverAppBar(
            pinned: true,
            toolbarHeight: 110,
            backgroundColor: bgHeader,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
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
                      child: KioskBrandHeader(
                        subtitle: 'permanent_members'.tr,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('members'.tr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Ubuntu')),
                        Text('permanent_members'.tr, style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Ubuntu')),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => dataController.refreshMember(),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),

          // Members List
          Obx(() {
            if (dataController.isDataLoading.value) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            }
            if (dataController.members.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.group, size: 64, color: Colors.blue.shade300),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'none_visits'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Ubuntu', color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = dataController.members[index];
                    return _buildMemberCard(data);
                  },
                  childCount: dataController.members.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Qrcode data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_pin_rounded, color: Colors.indigo, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.visitor?.name ?? "Inconnu",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87, fontFamily: 'Ubuntu'),
                ),
                const SizedBox(height: 4),
                Text(
                  'unlimited_duration'.tr,
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Ubuntu'),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.indigo.withOpacity(0.08),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => showActions(data),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(CupertinoIcons.ellipsis_vertical, size: 18, color: Colors.indigo),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
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
            _buildNavIcon(Icons.home_rounded, false, () => Get.offAll(() => const MainScreen(), transition: Transition.cupertino)),
            _buildNavIcon(Icons.group_rounded, true, () => dataController.refreshMember()),
            _buildNavIcon(Icons.history_rounded, false, () => Get.to(() => const HistoryPage(), transition: Transition.cupertino)),
            _buildNavIcon(CupertinoIcons.square_grid_2x2, false, () => showProfile()),
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
        child: Icon(icon, color: isActive ? Colors.black87 : Colors.white70, size: 24),
      ),
    );
  }

  void showActions(Qrcode data) {
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5))),
                _buildSheetAction(
                  icon: Icons.share_rounded,
                  title: 'share_qr'.tr,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      useSafeArea: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (context) => QrcodeBottomSheet(qrData: data.token!, visitorName: data.visitor!.name!),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildSheetAction(
                  icon: Icons.delete_outline_rounded,
                  title: 'delete_member'.tr,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showDeleteConfirmation(data);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Qrcode data) {
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
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'delete_confirm_title'.tr,
                style: TextStyle(
                  fontSize: 19 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${'delete_confirm_desc'.tr} (${data.visitor?.name ?? '...'})",
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
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
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
                      onPressed: () async {
                        Get.back();
                        EasyLoading.show(status: "Suppression...");
                        try {
                          await ApiManager().deleteData(table: "visitors", id: data.visitorId!);
                          dataController.refreshMember();
                          EasyLoading.showSuccess("Membre retiré");
                        } finally {
                          EasyLoading.dismiss();
                        }
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
                      child: Text(
                        'delete'.tr,
                        style: const TextStyle(
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

  void _showLogoutConfirmation() {
    final scale = kioskScale(context);

    Get.back();

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
                'logout_confirm_title'.tr,
                style: TextStyle(
                  fontSize: 19 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'logout_confirm_desc'.tr,
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
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
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
                      child: Text(
                        'logout'.tr,
                        style: const TextStyle(
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

  void _showLanguageDialog() {
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
        trailing:  Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  void showProfile() {
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
                _buildSheetAction(icon: Icons.language_rounded, title: 'language'.tr, subtitle: "Change app language", onTap: () { Navigator.pop(sheetContext); _showLanguageDialog(); }),
                const SizedBox(height: 12),
                _buildSheetAction(icon: Icons.history, title: 'history'.tr, subtitle: 'all_validated_visits'.tr, onTap: () { Get.back(); Get.to(() => const HistoryPage(), transition: Transition.cupertino); }),
                const SizedBox(height: 12),
                _buildSheetAction(icon: Icons.logout, title: 'logout'.tr, subtitle: 'logout_confirm_desc'.tr, color: Colors.red, onTap: _showLogoutConfirmation),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
