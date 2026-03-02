import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxenew/controllers/data_controller.dart';
import 'package:taxenew/screens/main_screen.dart';
import 'package:taxenew/screens/main_screen_agent.dart';
import 'package:taxenew/utils/controllers.dart';
import 'package:taxenew/utils/translations.dart';
import '/screens/auth/login.dart';
import '/theme/style.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(AuthController());
  Get.put(DataController());
  configEasyLoading();
  runApp(const MyApp());
}

void configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..radius = 5.0
    ..backgroundColor = Colors.black54
    ..textColor = Colors.white
    ..indicatorColor = Colors.white
    ..maskColor = primaryColor
    ..userInteractions = true
    ..toastPosition = EasyLoadingToastPosition.bottom;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<Widget> _startupFuture;
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _startupFuture = _initApp();
  }

  Future<Widget> _initApp() async {
    try {
      await authController.refreshUser();
      if (authController.user.value != null) {
        if (authController.user.value!.role == 'resident') {
          return const MainScreen();
        } else if (authController.user.value!.role == 'agent') {
          return const MainScreenAgent();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur initApp: $e");
      }
    }
    return const Login();
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer la langue sauvegardée ou utiliser 'fr' par défaut
    String savedLang = storage.read('lang') ?? 'fr';
    Locale initialLocale = Locale(savedLang);

    return GetMaterialApp(
      title: 'Tango Access',
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('fr'),
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: scaffoldColor,
        fontFamily: 'Ubuntu',
      ),
      home: FutureBuilder<Widget>(
        future: _startupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: scaffoldColor,
              body: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Erreur : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
