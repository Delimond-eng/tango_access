import 'visitor.dart';

class Qrcode {
  int? id;
  int? visitorId;
  int? unitId;
  String? token;
  String? type;
  String? validFrom;
  String? validTo;
  int? singleUse;
  String? usedAt;
  String? usedBy;
  String? status;
  int? accountId;
  String? createdAt;
  String? updatedAt;
  Visitor? visitor;

  Qrcode({
    this.id,
    this.visitorId,
    this.unitId,
    this.token,
    this.type,
    this.validFrom,
    this.validTo,
    this.singleUse,
    this.usedAt,
    this.usedBy,
    this.status,
    this.accountId,
    this.createdAt,
    this.updatedAt,
    this.visitor,
  });

  Qrcode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitorId = json['visitor_id'];
    unitId = json['unit_id'];
    token = json['token'];
    validTo = json['valid_to'] ?? "";
    visitor =
        json['visitor'] != null ? Visitor.fromJson(json['visitor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['visitor_id'] = visitorId;
    data['unit_id'] = unitId;
    data['token'] = token;
    data['type'] = type;
    if (visitor != null) {
      data['visitor'] = visitor!.toJson();
    }
    return data;
  }
}
