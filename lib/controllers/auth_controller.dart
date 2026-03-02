import 'package:get/get.dart';
import '../models/user.dart';
import '/utils/store.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  Rx<User?> user = Rx<User?>(null);

  @override
  onInit() {
    super.onInit();
    refreshUser();
    // Ecouter le changement du filtre
    /* ever(selectedTypeFilter, (_) {
   
    }); */
  }

  Future<User?> refreshUser() async {
    var userObject = localStorage.read('user_session');
    if (userObject != null) {
      var u = User.fromJson(userObject);
      user.value = u;
      return u;
    } else {
      return null;
    }
  }
}
