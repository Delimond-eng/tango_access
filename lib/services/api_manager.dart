import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:taxenew/models/history.dart';
import 'package:taxenew/models/member.dart';
import 'package:taxenew/models/scan.dart';
import 'package:taxenew/models/user.dart';
import 'package:taxenew/utils/controllers.dart';
import 'package:taxenew/utils/store.dart';

import '../models/qrcode.dart';
import '/services/api_service.dart';

class ApiManager {
  Future<dynamic> login({
    required String uMatricule,
    required String uPass,
  }) async {
    try {
      var response = await Api.request(
        url: "user/login",
        method: "post",
        body: {"login": uMatricule, "password": uPass},
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"].toString();
        } else {
          var user = User.fromJson(response["user"]);
          user.role = response["role"].toString();
          localStorage.write("user_session", user.toJson());
          authController.user.value = user;
          authController.refreshUser();
          return user;
        }
      } else {
        return response["errors"].toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "Echec de traitement de la requête !${e.toString()}";
    }
  }

  Future<dynamic> createVisitor({
    required String name,
    required String dateTime,
    required String type,
    String? phone,
    String? email,
  }) async {
    try {
      dataController.isLoading.value = true;
      var user = authController.user.value;
      var response = await Api.request(
        url: "resident/visitors",
        method: "post",
        body: {
          "name": name,
          "valid_to": dateTime,
          "phone": phone,
          "email": email,
          "type": type,
          "resident_id": user!.id,
        },
      );
      dataController.isLoading.value = false;
      if (response != null) {
        dataController.refreshPendingData();
        if (response.containsKey("errors")) {
          return response["errors"].toString();
        } else {
          if (response.containsKey("qrcode")) {
            return response;
          }
        }
      } else {
        return response["errors"].toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      dataController.isLoading.value = false;
      return "Echec de traitement de la requête !";
    }
  }

  Future<dynamic> refreshQr({
    required String token,
    required String dateTime,
  }) async {
    try {
      dataController.isLoading.value = true;
      var response = await Api.request(
        url: "resident/visitors/refresh",
        method: "post",
        body: {"token": token, "dateh": dateTime},
      );
      dataController.isLoading.value = false;
      if (response != null) {
        dataController.refreshPendingData();
        if (response.containsKey("errors")) {
          return response["errors"].toString();
        } else {
          return response;
        }
      } else {
        return response["errors"].toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      dataController.isLoading.value = false;
      return "Echec de traitement de la requête !";
    }
  }

  Future<dynamic> getScanInfos({required String token}) async {
    try {
      dataController.isLoading.value = true;
      var user = authController.user.value;
      var response = await Api.request(
        url: "agent/scan/infos",
        method: "post",
        body: {"token": token, "agent_id": user!.id},
      );
      dataController.isLoading.value = false;
      if (response != null) {
        if (response.containsKey("qrcode")) {
          return response;
        }
        if (response.containsKey("errors")) {
          return response["errors"].toString();
        }
      }
      return "QR code invalide ou expiré";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      dataController.isLoading.value = false;
      return "Echec de traitement de la requête !";
    }
  }

  Future<dynamic> scanQrcode({required String token}) async {
    try {
      dataController.isLoading.value = true;
      var user = authController.user.value;
      var response = await Api.request(
        url: "agent/scan",
        method: "post",
        body: {"token": token, "agent_id": user!.id},
      );
      dataController.isLoading.value = false;
      EasyLoading.dismiss();
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"].toString();
        } else {
          if (response.containsKey("qrcode")) {
            return response;
          }
          if (response["status"] == "expired") {
            return response["message"].toString();
          }
        }
      } else {
        EasyLoading.dismiss();
        return response["errors"].toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      dataController.isLoading.value = false;
      EasyLoading.dismiss();
      return "Echec de traitement de la requête !";
    }
  }

  Future<QRScan?> getPendingVisits({int page = 1}) async {
    var user = authController.user.value;
    if (user != null) {
      if (user.role == 'resident') {
        var response = await Api.request(
          url: "resident/visits/pending?resident_id=${user.id}&page=$page",
          method: "get",
        );
        if (response != null) {
          return QRScan.fromJson(response);
        }
      }
    }
    return null;
  }

  Future<List<Qrcode>> getMembers() async {
    var user = authController.user.value;
    List<Qrcode> members = [];
    if (user != null) {
      if (user.role == 'resident') {
        var response = await Api.request(
          url: "resident/members?resident_id=${user.id}",
          method: "get",
        );
        if (response != null) {
          var data = Member.fromJson(response);
          members = data.members!;
        }
      }
      dataController.isDataLoading.value = false;
    }
    return members;
  }

  Future<History?> getResidentHistory({int page = 1}) async {
    History? data;
    var user = authController.user.value;
    if (user != null) {
      String url =
          user.role == 'resident'
              ? "resident/visits/history?resident_id=${user.id}&page=$page&date=${dataController.filterDate.value}"
              : "agent/visits/history?agent_id=${user.id}&page=$page&date=${dataController.filterDate.value}";
      dataController.isDataLoading.value = true;
      var response = await Api.request(url: url, method: "get");
      dataController.isDataLoading.value = false;
      if (response != null) {
        dataController.filterDate.value = "";
        var history = History.fromJson(response);
        data = history;
      }
    }
    return data;
  }

  Future<dynamic> deleteData({required String table, required int id}) async {
    try {
      dataController.isLoading.value = true;
      var response = await Api.request(
        url: "data/delete",
        method: "post",
        body: {"table": table, "id": id},
      );
      dataController.isLoading.value = false;
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"].toString();
        } else {
          return response;
        }
      } else {
        return response["errors"].toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      dataController.isLoading.value = false;
      return "Echec de traitement de la requête !";
    }
  }
}
