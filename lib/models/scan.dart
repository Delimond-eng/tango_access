import 'qrcode.dart';

class QRScan {
  List<Qrcode>? pendings;
  int? currentPage;
  int? lastPage;
  int? total;

  QRScan({this.pendings, this.currentPage, this.lastPage, this.total});

  QRScan.fromJson(Map<String, dynamic> json) {
    if (json['pendings'] != null) {
      // Laravel pagination object has 'data' field
      if (json['pendings']['data'] != null) {
        pendings = <Qrcode>[];
        json['pendings']['data'].forEach((v) {
          pendings!.add(Qrcode.fromJson(v));
        });
        currentPage = json['pendings']['current_page'];
        lastPage = json['pendings']['last_page'];
        total = json['pendings']['total'];
      } else if (json['pendings'] is List) {
        // Fallback for non-paginated lists
        pendings = <Qrcode>[];
        json['pendings'].forEach((v) {
          pendings!.add(Qrcode.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pendings != null) {
      data['pendings'] = pendings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
