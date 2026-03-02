/// ================= Agent =================
class User {
  final int id;
  final String nom;
  final String? code;
  final String telephone;
  final String email;
  late String? role;
  final int accountId;
  final int? buildingId;
  final int? unitId;

  User({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.email,
    required this.accountId,
    this.code,
    this.buildingId,
    this.unitId,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['name'],
      code: json['code'],
      telephone: json['phone'],
      email: json['email'],
      accountId: json['account_id'],
      buildingId: json['building_id'],
      unitId: json['unit_id'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': nom,
    'code': code,
    'phone': telephone,
    'email': email,
    'account_id': accountId,
    'building_id': buildingId,
    'unit_id': unitId,
    'role': role,
  };
}
