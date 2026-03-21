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
import '../widgets/visitor_card.dart';
import '/theme/style.dart';

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
    final TextEditingController plateController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController personCountController = TextEditingController(text: "1");

    String arrivalMode = "foot"; // foot, car, taxi
    List<String> selectedTags = [];
    DateTime? selectedDate;
    String dateTimeVisite = "";

    final List<Map<String, dynamic>> quickTags = [
      {"id": "delivery", "label": 'delivery'.tr, "icon": Icons.inventory_2_outlined},
      {"id": "work", "label": 'work'.tr, "icon": Icons.handyman_outlined},
      {"id": "reunion", "label": 'reunion'.tr, "icon": Icons.groups_outlined},
      {"id": "family", "label": 'family'.tr, "icon": Icons.favorite_border},
      {"id": "urgent", "label": 'urgent'.tr, "icon": Icons.notification_important_outlined},
      {"id": "other", "label": 'other'.tr, "icon": Icons.more_horiz_outlined},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setInternalState) {
          Widget buildModeItem(String id, String label, IconData icon) {
            bool isSelected = arrivalMode == id;
            return Expanded(
              child: GestureDetector(
                onTap: () => setInternalState(() => arrivalMode = id),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  left: 20,
                  right: 20,
                  top: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        type == 'visitor' ? 'new_visitor'.tr : 'new_member'.tr,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Ubuntu'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomField(
                      controller: nomController,
                      hintText: 'full_name'.tr,
                      iconPath: 'user-1',
                    ),
                    if (type == "visitor") ...[
                      CustomDateTimeField(
                        hintText: 'visit_date_time'.tr,
                        iconPath: "calendar-time",
                        selectedDateTime: selectedDate,
                        onChanged: (DateTime dt) {
                          setInternalState(() {
                            selectedDate = dt;
                            dateTimeVisite = DateFormat('yyyy-MM-dd HH:mm').format(dt);
                          });
                        },
                      ),
                      
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'number_of_persons'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: CustomField(
                              controller: personCountController,
                              hintText: "1",
                              iconPath: 'user',
                              inputType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      Text('arrival_mode'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          buildModeItem("foot", 'foot'.tr, Icons.directions_walk),
                          const SizedBox(width: 8),
                          buildModeItem("car", 'car'.tr, Icons.directions_car),
                          const SizedBox(width: 8),
                          buildModeItem("taxi", 'taxi'.tr, Icons.local_taxi),
                        ],
                      ),
                      
                      if (arrivalMode != "foot") ...[
                        const SizedBox(height: 15),
                        CustomField(
                          controller: plateController, 
                          hintText: 'plate_hint'.tr, 
                          iconPath: 'settings-2'
                        ),
                      ],
  
                      const SizedBox(height: 20),
                      Text('precisions'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 0,
                        children: quickTags.map((tag) {
                          bool isSelected = selectedTags.contains(tag["id"]);
                          return FilterChip(
                            label: Text(tag["label"]),
                            avatar: Icon(tag["icon"], size: 14, color: isSelected ? Colors.white : primaryColor),
                            selected: isSelected,
                            onSelected: (bool value) {
                              setInternalState(() {
                                if (value) {
                                  selectedTags.add(tag["id"]);
                                } else {
                                  selectedTags.remove(tag["id"]);
                                }
                              });
                            },
                            selectedColor: primaryColor,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 11),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          );
                        }).toList(),
                      ),
  
                      const SizedBox(height: 15),
                      CustomField(
                        controller: noteController, 
                        hintText: 'note_instruction'.tr, 
                        iconPath: 'email'
                      ),
                    ],

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
                            EasyLoading.showToast('name_required'.tr);
                            return;
                          }
                          if (type == "visitor" && dateTimeVisite.isEmpty) {
                            EasyLoading.showToast('date_required'.tr);
                            return;
                          }

                          Map<String, dynamic>? specs;
                          if (type == "visitor") {
                            specs = {
                              "mode": arrivalMode,
                              "plate": plateController.text.isNotEmpty ? plateController.text : null,
                              "tags": selectedTags,
                              "note": noteController.text.isNotEmpty ? noteController.text : null,
                              "person_count": int.tryParse(personCountController.text) ?? 1,
                            };
                          }

                          var api = ApiManager();
                          final res = await api.createVisitor(
                            name: nomController.text,
                            dateTime: dateTimeVisite,
                            type: type,
                            specifications: specs,
                          );
                          if (res is String) {
                            EasyLoading.showInfo(res);
                          } else {
                            if (!mounted) return;
                            Navigator.pop(sheetContext);
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
                                specs: specs,
                              ),
                            );
                          }
                        },
                        child: dataController.isLoading.value
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('generate_qr'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          );
        }
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
        bottomNavigationBar: const KioskBottomBar(activeIndex: 0),
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
                          child: KioskBrandHeader(subtitle: 'terminal_resident'.tr),
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
                                        title: 'create_visitor'.tr,
                                        subtitle: 'my_visitors'.tr,
                                        color: Colors.amber.shade400,
                                        icon: Icons.person_add_rounded,
                                        onTap: () => _showCreationBottomSheet("visitor"),
                                      ),
                                      const SizedBox(width: 15),
                                      _buildActionCard(
                                        context,
                                        title: 'create_member'.tr,
                                        subtitle: 'family_employees'.tr,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('my_visits'.tr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Ubuntu')),
                          Text('pending_visits'.tr, style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Ubuntu')),
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
                return SliverFillRemaining(child: Center(child: Text('none_visits'.tr, style: const TextStyle(fontFamily: 'Ubuntu'))));
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
                  icon: Icons.refresh_rounded,
                  title: 'refresh_qr'.tr,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final dateTime = await pickDateAndTime(context);
                    if (dateTime != null) {
                      EasyLoading.show(status: "Actualisation...");
                      try {
                        final res = await ApiManager().refreshQr(token: data.token!, dateTime: dateTime);
                        if (res is String) {
                          EasyLoading.showInfo(res);
                        } else {
                          EasyLoading.showSuccess("QR actualisé");
                        }
                      } finally {
                        EasyLoading.dismiss();
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
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
                  title: 'delete_visit'.tr,
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
                'delete_confirm_desc'.tr,
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
                          dataController.refreshPendingData();
                          EasyLoading.showSuccess("Supprimé");
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
