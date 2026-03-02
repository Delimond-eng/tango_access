import 'visitor.dart';

class History {
  Visits? visits;
  History({this.visits});
  History.fromJson(Map<String, dynamic> json) {
    visits = json['visits'] != null ? Visits.fromJson(json['visits']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (visits != null) {
      data['visits'] = visits!.toJson();
    }
    return data;
  }
}

class Visits {
  int? currentPage;
  List<Scan>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  Visits({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  Visits.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Scan>[];
      json['data'].forEach((v) {
        data!.add(Scan.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class Scan {
  int? id;
  String? token;
  int? agentId;
  int? unitId;
  int? visitorId;
  String? type;
  String? result;
  String? reason;
  int? accountId;
  String? createdAt;
  String? updatedAt;
  Visitor? visitor;
  Unit? unit;

  Scan({
    this.id,
    this.token,
    this.agentId,
    this.unitId,
    this.visitorId,
    this.type,
    this.result,
    this.reason,
    this.accountId,
    this.createdAt,
    this.updatedAt,
    this.visitor,
    this.unit,
  });

  Scan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    token = json['token'];
    agentId = json['agent_id'];
    unitId = json['unit_id'];
    visitorId = json['visitor_id'];
    type = json['type'];
    result = json['result'];
    reason = json['reason'];
    accountId = json['account_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    visitor =
        json['visitor'] != null ? Visitor.fromJson(json['visitor']) : null;
    unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['token'] = token;
    data['agent_id'] = agentId;
    data['unit_id'] = unitId;
    data['visitor_id'] = visitorId;
    data['type'] = type;
    data['result'] = result;
    data['reason'] = reason;
    data['account_id'] = accountId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (visitor != null) {
      data['visitor'] = visitor!.toJson();
    }
    if (unit != null) {
      data['unit'] = unit!.toJson();
    }
    return data;
  }

  String get status {
    if (result == 'accepted') {
      return "accepté";
    } else if (result == 'expired') {
      return "expiré";
    } else {
      return "réfusé";
    }
  }
}

class Unit {
  int? id;
  String? name;
  String? type;
  int? buildingId;
  int? residentId;
  int? accountId;
  String? createdAt;
  String? updatedAt;
  Resident? resident;

  Unit({
    this.id,
    this.name,
    this.type,
    this.buildingId,
    this.residentId,
    this.accountId,
    this.createdAt,
    this.updatedAt,
    this.resident,
  });

  Unit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    buildingId = json['building_id'];
    residentId = json['resident_id'];
    accountId = json['account_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    resident =
        json['resident'] != null ? Resident.fromJson(json['resident']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['building_id'] = buildingId;
    data['resident_id'] = residentId;
    data['account_id'] = accountId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (resident != null) {
      data['resident'] = resident!.toJson();
    }
    return data;
  }
}

class Resident {
  int? id;
  String? name;
  String? email;
  String? phone;
  int? unitId;
  int? buildingId;
  int? accountId;
  String? createdAt;
  String? updatedAt;

  Resident({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.unitId,
    this.buildingId,
    this.accountId,
    this.createdAt,
    this.updatedAt,
  });

  Resident.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    unitId = json['unit_id'];
    buildingId = json['building_id'];
    accountId = json['account_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['unit_id'] = unitId;
    data['building_id'] = buildingId;
    data['account_id'] = accountId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}
