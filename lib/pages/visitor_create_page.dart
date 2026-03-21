import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/state_manager.dart';
import 'package:taxenew/services/api_manager.dart';
import 'package:taxenew/theme/style.dart';
import 'package:taxenew/utils/controllers.dart';
import 'package:taxenew/widgets/costum_field.dart';
import 'package:taxenew/widgets/custom_btn.dart';

import '../widgets/qrcode_viewer.dart';

class VisitorCreatePage extends StatefulWidget {
  final String type;
  const VisitorCreatePage({super.key, required this.type});

  @override
  State<VisitorCreatePage> createState() => _VisitorCreatePageState();
}

class _VisitorCreatePageState extends State<VisitorCreatePage> {
  final TextEditingController nom = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String arrivalMode = "foot"; // foot, car, taxi
  List<String> selectedTags = [];
  String dateTimeVisite = "";
  DateTime? selectedDate;

  final List<Map<String, dynamic>> quickTags = [
    {"id": "delivery", "label": "Livraison", "icon": Icons.inventory_2_outlined},
    {"id": "work", "label": "Travaux/Service", "icon": Icons.handyman_outlined},
    {"id": "heavy", "label": "Colis Lourd", "icon": Icons.fitness_center},
    {"id": "family", "label": "Famille/Ami", "icon": Icons.favorite_border},
    {"id": "urgent", "label": "Urgent", "icon": Icons.notification_important_outlined},
  ];

  String toIsoForDb(DateTime dateTime) {
    return dateTime.toIso8601String().substring(0, 19).replaceFirst('T', ' ');
  }

  Widget _buildModeItem(String id, String label, IconData icon) {
    bool isSelected = arrivalMode == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => arrivalMode = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/images/bg.jpeg", fit: BoxFit.cover),
            Container(color: secondary.withOpacity(0.8)),
          ],
        ),
        title: const Text("Nouvel Accès", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomField(controller: nom, hintText: "Nom du visiteur", iconPath: 'user-1'),
            if (widget.type == "visitor")
              CustomDateTimeField(
                hintText: "Date & heure de visite",
                iconPath: "calendar-time",
                selectedDateTime: selectedDate,
                onChanged: (dt) => setState(() {
                  selectedDate = dt;
                  dateTimeVisite = toIsoForDb(dt);
                }),
              ),
            
            const SizedBox(height: 20),
            const Text("Mode d'arrivée", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildModeItem("foot", "À pied", Icons.directions_walk),
                const SizedBox(width: 8),
                _buildModeItem("car", "Voiture", Icons.directions_car),
                const SizedBox(width: 8),
                _buildModeItem("taxi", "Taxi/VTC", Icons.local_taxi),
              ],
            ),
            
            if (arrivalMode != "foot") ...[
              const SizedBox(height: 15),
              CustomField(controller: plateController, hintText: "Plaque d'immatriculation (Optionnel)", iconPath: 'settings'),
            ],

            const SizedBox(height: 20),
            const Text("Précisions (Tags)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickTags.map((tag) {
                bool isSelected = selectedTags.contains(tag["id"]);
                return FilterChip(
                  label: Text(tag["label"]),
                  avatar: Icon(tag["icon"], size: 16, color: isSelected ? Colors.white : primaryColor),
                  selected: isSelected,
                  onSelected: (bool value) {
                    setState(() {
                      if (value) {
                        selectedTags.add(tag["id"]);
                      } else {
                        selectedTags.remove(tag["id"]);
                      }
                    });
                  },
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            CustomField(controller: noteController, hintText: "Note ou instruction particulière...", iconPath: 'email'),

            const SizedBox(height: 30),
            Obx(() => CostumButton(
              title: "Générer l'accès",
              bgColor: primaryColor,
              labelColor: Colors.white,
              isLoading: dataController.isLoading.value,
              onPress: createVisitor,
            )),
          ],
        ),
      ),
    );
  }

  Future<void> createVisitor() async {
    if (nom.text.isEmpty) {
      EasyLoading.showToast("Nom requis.");
      return;
    }
    
    Map<String, dynamic> specs = {
      "mode": arrivalMode,
      "plate": plateController.text.isNotEmpty ? plateController.text : null,
      "tags": selectedTags,
      "note": noteController.text.isNotEmpty ? noteController.text : null,
    };

    ApiManager().createVisitor(
      name: nom.text,
      dateTime: dateTimeVisite,
      type: widget.type,
      specifications: specs,
    ).then((res) {
      if (res is Map && res.containsKey("qrcode")) {
        cleanFields();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => QrcodeBottomSheet(
            qrData: res["qrcode"],
            visitorName: res["visitor"]["name"],
          ),
        );
      } else if (res is String) {
        EasyLoading.showError(res);
      }
    });
  }

  void cleanFields() {
    nom.clear();
    plateController.clear();
    noteController.clear();
    setState(() {
      arrivalMode = "foot";
      selectedTags = [];
      selectedDate = null;
    });
  }
}
