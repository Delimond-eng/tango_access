import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taxenew/services/api_manager.dart';
import 'package:taxenew/utils/controllers.dart';
import 'package:taxenew/widgets/costum_field.dart';
import 'package:taxenew/widgets/qrcode_viewer.dart';
import '../components/kiosk_components.dart';
import '../models/qrcode.dart';
import '../pages/history_page.dart';
import '../pages/member_page.dart';
import '../utils/app_theme.dart';
import '../utils/store.dart';
import '../widgets/custom_btn.dart';
import '../widgets/visitor_card.dart';
import '/theme/style.dart';
import 'auth/login.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 400 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 400 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dataController.refreshPendingData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE CRÉATION VIA BOTTOM SHEET ---
  void _showCreationBottomSheet(String type) {
    final TextEditingController nomController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    DateTime? selectedDate;
    String dateTimeVisite = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder( // Renommé context en sheetContext
        builder: (context, setInternalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    type == 'visitor' ? "Nouveau Visiteur" : "Nouveau Membre",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Ubuntu'),
                  ),
                  const SizedBox(height: 20),
                  CustomField(
                    controller: nomController,
                    hintText: "Nom complet",
                    iconPath: 'user-1',
                  ),
                  CustomField(
                    controller: phoneController,
                    hintText: "Téléphone",
                    inputType: TextInputType.phone,
                    iconPath: 'phone-2',
                  ),
                  CustomField(
                    controller: emailController,
                    hintText: "Email (Optionnel)",
                    inputType: TextInputType.emailAddress,
                    iconPath: 'email',
                  ),
                  if (type == "visitor")
                    CustomDateTimeField(
                      hintText: "Date & heure de visite",
                      iconPath: "calendar-time",
                      selectedDateTime: selectedDate,
                      onChanged: (DateTime dt) {
                        setInternalState(() {
                          selectedDate = dt;
                          dateTimeVisite = DateFormat('yyyy-MM-dd HH:mm').format(dt);
                        });
                      },
                    ),
                  const SizedBox(height: 24),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: dataController.isLoading.value ? null : () async {
                        if (nomController.text.isEmpty) {
                          EasyLoading.showToast("Le nom est requis.");
                          return;
                        }
                        if (type == "visitor" && dateTimeVisite.isEmpty) {
                          EasyLoading.showToast("La date est requise.");
                          return;
                        }
                        var api = ApiManager();
                        final res = await api.createVisitor(
                          name: nomController.text,
                          dateTime: dateTimeVisite,
                          type: type,
                          phone: phoneController.text,
                          email: emailController.text,
                        );
                        if (res is String) {
                          EasyLoading.showInfo(res);
                        } else {
                          if (!mounted) return;
                          Navigator.pop(sheetContext); // Utilisation de sheetContext
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            useSafeArea: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => QrcodeBottomSheet(
                              qrData: res["qrcode"],
                              visitorName: res["visitor"]["name"],
                            ),
                          );
                        }
                      },
                      child: dataController.isLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Générer l'accès QR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgScaffold = Colors.indigo.shade50;
    final bgHeader = Colors.indigo.shade400;
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bgScaffold,
        extendBody: true,
        floatingActionButton: _showBackToTop
            ? Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut);
                  },
                  backgroundColor: secondary,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 30),
                ),
              )
            : null,
        bottomNavigationBar: _buildFloatingBottomBar(),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 300.0,
              toolbarHeight: 110,
              backgroundColor: bgHeader,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              elevation: 0,
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                  child: Center(
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
                          child: const KioskBrandHeader(subtitle: "Terminal pour résident"),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  const double expandedHeight = 300.0;
                  const double toolbarHeight = 110.0;
                  final double currentHeight = constraints.biggest.height;
                  final double t = ((currentHeight - toolbarHeight) / (expandedHeight - toolbarHeight)).clamp(0.0, 1.0);
                  
                  final double opacity = Curves.easeIn.transform(t);
                  final double scale = 0.85 + (0.15 * t);

                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      decoration: BoxDecoration(
                        color: bgHeader,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40 * t)),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          children: [
                            const SizedBox(height: 110),
                            Opacity(
                              opacity: opacity,
                              child: Transform.scale(
                                scale: scale,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
                                  child: Row(
                                    children: [
                                      _buildActionCard(
                                        context,
                                        title: "Créer\nVisiteur",
                                        subtitle: "Mes visiteurs",
                                        color: Colors.amber.shade400,
                                        icon: Icons.person_add_rounded,
                                        onTap: () => _showCreationBottomSheet("visitor"),
                                      ),
                                      const SizedBox(width: 15),
                                      _buildActionCard(
                                        context,
                                        title: "Créer\nMembre",
                                        subtitle: "Famille & Employés",
                                        color: Colors.white.withOpacity(0.9),
                                        icon: Icons.group_add_rounded,
                                        onTap: () => _showCreationBottomSheet("worker"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mes Visites", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Ubuntu')),
                          Text("Passages programmés en attente", style: TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Ubuntu')),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => dataController.refreshPendingData(),
                      icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

            Obx(() {
              if (dataController.isDataLoading.value) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (dataController.pendingVisits.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text("-- Aucune visite --", style: TextStyle(fontFamily: 'Ubuntu'))));
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => VisitorCard(
                      onPressed: () => showAgendaActions(dataController.pendingVisits[index]),
                      data: dataController.pendingVisits[index],
                    ),
                    childCount: dataController.pendingVisits.length,
                  ),
                ),
              );
            }),
          ],
        ),
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
            _buildNavIcon(Icons.home_rounded, true, () => dataController.refreshPendingData()),
            _buildNavIcon(Icons.group_rounded, false, () => Get.to(() => const MemberPage(), transition: Transition.cupertino)),
            _buildNavIcon(Icons.history_rounded, false, () => Get.to(() => const HistoryPage(), transition: Transition.cupertino)),
            _buildNavIcon(CupertinoIcons.person_fill, false, () => showProfile()),
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

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), shape: BoxShape.circle),
                    child: Icon(icon, size: 20, color: Colors.black87),
                  ),
                  const Icon(CupertinoIcons.arrow_up_right_circle_fill, size: 30, color: Colors.black87),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.1, fontFamily: 'Ubuntu')),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54, fontFamily: 'Ubuntu')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAgendaActions(Qrcode data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Container( // Renommé context en sheetContext
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
                  icon: Icons.refresh_rounded,
                  title: "Ré-actualiser le QR Code",
                  subtitle: "Changer la date de validité",
                  onTap: () async {
                    Navigator.pop(sheetContext); // On ferme la modale d'abord
                    final dateTime = await pickDateAndTime(context); // On utilise le contexte de la page
                    if (dateTime != null) {
                      ApiManager().refreshQr(token: data.token!, dateTime: dateTime).then((res) {
                        if (res is String) EasyLoading.showInfo(res);
                        else EasyLoading.showSuccess("QR actualisé");
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSheetAction(
                  icon: Icons.share_rounded,
                  title: "Partager le QR Code",
                  subtitle: "Envoyer l'accès au visiteur",
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
                  title: "Supprimer la visite",
                  subtitle: "Annuler cet accès définitivement",
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showConfirmDialog(context: context, title: "Supprimer ?", message: "Voulez-vous supprimer cet accès ?").then((confirmed) {
                      if (confirmed == true) {
                        ApiManager().deleteData(table: "visitors", id: data.visitorId!).then((res) {
                          dataController.refreshPendingData();
                          EasyLoading.showSuccess("Supprimé");
                        });
                      }
                    });
                  },
                ),
              ],
            ),
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
                  title: Text("Bonjour, ${authController.user.value!.nom}", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Ubuntu', fontSize: 18)),
                  subtitle: Text(authController.user.value!.email, style: const TextStyle(fontFamily: 'Ubuntu')),
                ),
                const Divider(height: 32),
                _buildSheetAction(icon: Icons.history, title: "Historique", subtitle: "Consulter vos passages passés", onTap: () { Navigator.pop(sheetContext); Get.to(() => const HistoryPage(), transition: Transition.cupertino); }),
                const SizedBox(height: 12),
                _buildSheetAction(icon: Icons.group, title: "Mes membres", subtitle: "Gérer famille et employés", onTap: () { Navigator.pop(sheetContext); Get.to(() => const MemberPage(), transition: Transition.cupertino); }),
                const SizedBox(height: 12),
                _buildSheetAction(icon: Icons.logout, title: "Déconnexion", subtitle: "Fermer votre session actuelle", color: Colors.red, onTap: _showLogoutConfirmation
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> pickDateAndTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100)
    );
    
    if (pickedDate == null || !mounted) return null;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now()
    );
    
    if (pickedTime == null || !mounted) return null;

    return DateFormat('yyyy-MM-dd HH:mm').format(
      DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute)
    );
  }
}
