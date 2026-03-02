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
  // Controllers
  final TextEditingController nom = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  String dateTimeVisite = "";
  DateTime? selectedDate;

  bool isLoading = false;

  String toIsoForDb(DateTime dateTime) {
    return dateTime.toIso8601String().substring(0, 19).replaceFirst('T', ' ');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // IMPORTANT
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            /// IMAGE DE FOND
            Image.asset("assets/images/bg.jpeg", fit: BoxFit.cover),

            /// OVERLAY (optionnel)
            Container(color: secondary.withOpacity(0.7)),
          ],
        ),
        title: Text(
          "Création ${widget.type == 'visitor' ? 'Visiteur' : 'Membre(famille ou employé)'} ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18.0,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              "Veuillez renseigner les champs pour créer un ${widget.type == 'visitor' ? 'Visiteur' : 'Membre(famille ou employé)'}",
            ),
            const SizedBox(height: 10),

            /// Formulaire dynamique
            Column(
              children: [
                CustomField(
                  controller: nom,
                  hintText:
                      "Nom du ${widget.type == 'visitor' ? 'Visiteur' : 'Membre(famille ou employé)'}",
                  iconPath: 'user-1',
                ),
                CustomField(
                  controller: phone,
                  hintText: "Téléphone",
                  iconPath: 'phone-2',
                ),

                CustomField(
                  hintText: "Email(facultatif)",
                  iconPath: 'email',
                  controller: email,
                ),

                if (widget.type == "visitor") ...[
                  CustomDateTimeField(
                    hintText: "Date & heure de visite",
                    iconPath: "calendar-time",
                    selectedDateTime: selectedDate,
                    onChanged: (DateTime dateTime) {
                      setState(() {
                        dateTimeVisite = toIsoForDb(dateTime);
                        selectedDate = dateTime;
                      });
                    },
                  ),
                ],
                Obx(
                  () => CostumButton(
                    title: "Créer & générer un qrcode",
                    bgColor: primaryColor,
                    labelColor: Colors.indigo,
                    isLoading: dataController.isLoading.value,
                    onPress: createVisitor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createVisitor() async {
    if (nom.text.isEmpty) {
      EasyLoading.showToast(
        "Le Nom ${widget.type == 'visitor' ? 'Visiteur' : 'Membre(famille ou employé)'} requis.",
      );
      return;
    }
    if (dateTimeVisite.isEmpty && widget.type == "visitor") {
      EasyLoading.showToast("La date & l'heure de la visite requise.");
      return;
    }
    var api = ApiManager();
    api
        .createVisitor(
          name: nom.text,
          dateTime: dateTimeVisite,
          type: widget.type,
        )
        .then((res) {
          if (res is String) {
            EasyLoading.showInfo(res);
          } else {
            cleanFields();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder:
                  (context) => QrcodeBottomSheet(
                    qrData: res["qrcode"],
                    visitorName: res["visitor"]["name"],
                  ),
            );
          }
        });
  }

  void cleanFields() {
    nom.text = "";
    email.text = "";
    phone.text = "";
    setState(() {
      selectedDate = null;
      dateTimeVisite = "";
    });
  }
}
