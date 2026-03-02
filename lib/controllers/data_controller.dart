import 'package:get/get.dart';
import 'package:taxenew/models/qrcode.dart';
import 'package:taxenew/models/scan.dart';
import 'package:taxenew/services/api_manager.dart';

class DataController extends GetxController {
  static DataController instance = Get.find();

  RxList<Qrcode> pendingVisits = RxList<Qrcode>([]);
  RxList<Qrcode> members = RxList<Qrcode>([]);
  RxString filterDate = RxString("");

  var isDataLoading = false.obs;
  var isLoadingMore = false.obs;
  var isScanned = false.obs;
  var isLoading = false.obs;

  int currentPage = 1;
  int lastPage = 1;

  void refreshPendingData() async {
    currentPage = 1;
    isDataLoading.value = true;
    var apiManager = ApiManager();
    var response = await apiManager.getPendingVisits(page: currentPage);
    
    if (response != null && response.pendings != null) {
      pendingVisits.value = response.pendings!;
      lastPage = response.lastPage ?? 1;
    } else {
      pendingVisits.clear();
    }
    
    isDataLoading.value = false;
  }

  void loadMorePendingData() async {
    if (currentPage >= lastPage || isLoadingMore.value) return;

    isLoadingMore.value = true;
    currentPage++;
    
    var apiManager = ApiManager();
    var response = await apiManager.getPendingVisits(page: currentPage);
    
    if (response != null && response.pendings != null) {
      pendingVisits.addAll(response.pendings!);
    }
    
    isLoadingMore.value = false;
  }

  void refreshMember() async {
    isDataLoading.value = true;
    var apiManager = ApiManager();
    var membersArr = await apiManager.getMembers();
    members.value = membersArr;
    isDataLoading.value = false;
  }
}
