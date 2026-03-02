import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxenew/models/history.dart';
import 'package:taxenew/services/api_manager.dart';
import 'package:taxenew/theme/style.dart';
import 'package:taxenew/utils/controllers.dart';
import 'package:taxenew/widgets/history_card.dart';
import 'package:taxenew/widgets/svg.dart';
import '../components/kiosk_components.dart';
import '../screens/auth/login.dart';
import '../screens/main_screen.dart';
import '../screens/main_screen_agent.dart';
import 'member_page.dart';
import '../utils/store.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Scan> histories = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData(page: 1);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 120 &&
          !isLoadingMore &&
          currentPage < lastPage) {
        loadData(page: currentPage + 1);
      }
    });
  }

  Future<void> loadData({required int page}) async {
    var api = ApiManager();
    if (page == 1) {
      dataController.isDataLoading.value = true;
      histories.clear();
    } else {
      setState(() => isLoadingMore = true);
    }

    var response = await api.getResidentHistory(page: page);
    dataController.isDataLoading.value = false;
    isLoadingMore = false;

    if (response != null && response.visits != null) {
      setState(() {
        currentPage = response.visits!.currentPage!;
        lastPage = response.visits!.lastPage!;
        histories.addAll(response.visits!.data!);
      });
    }
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
    final bool isAgent = authController.user.value?.role == 'agent';

    return Scaffold(
      backgroundColor: bgScaffold,
      extendBody: true,
      // Affiche la barre uniquement pour les résidents
      bottomNavigationBar: isAgent ? null : _buildFloatingBottomBar(),
      // Affiche un bouton de retour uniquement pour les agents
      floatingActionButton: isAgent 
        ? FloatingActionButton(
            onPressed: () => Get.offAll(() => const MainScreenAgent(), transition: Transition.cupertino),
            backgroundColor: secondary,
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          )
        : null,
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
                        subtitle: 'all_validated_visits'.tr,
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
                        Text('history'.tr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Ubuntu')),
                        Text('all_validated_visits'.tr, style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Ubuntu')),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => loadData(page: 1),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),

          // History List
          Obx(() {
            if (dataController.isDataLoading.value) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            }
            if (histories.isEmpty) {
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
                        child: Svg(path: "history", size: 64, color: Colors.blue.shade300),
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
              padding: EdgeInsets.fromLTRB(20, 0, 20, isAgent ? 20 : 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < histories.length) {
                      return HistoryCard(
                        data: histories[index],
                        onPressed: () {},
                      );
                    }
                    return isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  },
                  childCount: histories.length + 1,
                ),
              ),
            );
          }),
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
            _buildNavIcon(Icons.group_rounded, false, () => Get.to(() => const MemberPage(), transition: Transition.cupertino)),
            _buildNavIcon(Icons.history_rounded, true, () => loadData(page: 1)),
            _buildNavIcon(CupertinoIcons.square_grid_2x2_fill, false, () => showProfile()),
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
                _buildSheetAction(icon: Icons.group, title: 'members'.tr, subtitle: 'permanent_members'.tr, onTap: () { Navigator.pop(sheetContext); Get.to(() => const MemberPage(), transition: Transition.cupertino); }),
                const SizedBox(height: 12),
                _buildSheetAction(icon: Icons.logout, title: 'logout'.tr, subtitle: 'logout_confirm_desc'.tr, color: Colors.red, onTap: _showLogoutConfirmation),
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
        trailing:  Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}
