class Visitor {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? type;
  int? residentId;
  int? accountId;
  String? createdAt;
  String? updatedAt;

  Visitor({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.type,
    this.residentId,
    this.accountId,
    this.createdAt,
    this.updatedAt,
  });

  Visitor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    type = json['type'];
    residentId = json['resident_id'];
    accountId = json['account_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['type'] = type;
    data['resident_id'] = residentId;
    data['account_id'] = accountId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
