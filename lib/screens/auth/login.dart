import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '/screens/main_screen.dart';
import '/screens/main_screen_agent.dart';
import '/services/api_manager.dart';
import '/theme/style.dart';
import '/widgets/custom_btn.dart';
import '../../widgets/costum_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final matricule = TextEditingController();
  final userPass = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Icons noires sur fond clair
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background Image
            Container(
              height: screenSize.height,
              width: screenSize.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Dark Overlay
            Container(
              height: screenSize.height,
              width: screenSize.width,
              color: Colors.indigo.withOpacity(0.5),
            ),
      
            // FILIGRANE AU CENTRE (Fixe par rapport à l'écran total)
            IgnorePointer(
              child: SizedBox(
                height: screenSize.height,
                width: screenSize.width,
                child: Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      "assets/images/tango.png",
                      width: screenSize.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
      
            // Main Content
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal:15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: screenSize.width > 500 ? 450 : screenSize.width,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo Central
                              Center(
                                child: Hero(
                                  tag: 'logo',
                                  child: Image.asset(
                                    "assets/images/tango.png",
                                    height: screenSize.height * .20,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
      
                              Text(
                                "TANGO PROTECTION ACCESS",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26.0,
                                  fontFamily: 'Staatliches',
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
      
                              const SizedBox(height: 10),
      
                              // MESSAGE EN GLACE BG
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
                                      "Veuillez entrer vos identifiants pour continuer",
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
                              
                              const SizedBox(height: 20),
      
                              // Inputs
                              Column(
                                children: [
                                  CustomField(
                                    hintText: "Identifiant (Code ou Email)",
                                    iconPath: "profile",
                                    inputType: TextInputType.text,
                                    controller: matricule,
                                  ),
                                  const SizedBox(height: 5.0),
                                  CustomField(
                                    hintText: "Mot de passe",
                                    iconPath: "lock",
                                    isPassword: true,
                                    controller: userPass,
                                  ),
                                  const SizedBox(height: 5.0),
                                  CostumButton(
                                    title: "Se Connecter",
                                    bgColor: primaryColor,
                                    labelColor: Colors.black87,
                                    isLoading: isLoading,
                                    onPress: () => login(context),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 40),
                              
                              const Text(
                                "© 2026 Tango Protection. Tous droits réservés.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontFamily: 'Ubuntu',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    if (matricule.text.isEmpty) {
      EasyLoading.showToast("L'identifiant est requis.");
      return;
    }
    if (userPass.text.isEmpty) {
      EasyLoading.showToast("Le mot de passe est requis.");
      return;
    }
    
    setState(() => isLoading = true);
    
    try {
      final result = await ApiManager().login(uMatricule: matricule.text, uPass: userPass.text);
      
      setState(() => isLoading = false);
      
      if (result is String) {
        EasyLoading.showInfo(result);
      } else {
        if (result.role == 'resident') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else if (result.role == 'agent') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreenAgent()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      EasyLoading.showError("Erreur de connexion.");
    }
  }
}
