import 'qrcode.dart';

class Member {
  List<Qrcode>? members;

  Member({this.members});

  Member.fromJson(Map<String, dynamic> json) {
    if (json['members'] != null) {
      members = <Qrcode>[];
      json['members'].forEach((v) {
        members!.add(Qrcode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
