class Account {
  late final int id;
  late final String name;
  late final String email;
  late final String role;
  late final String carLicense;

  Account({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.carLicense
  });

  Account.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
    carLicense = json['car_license'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['car_license'] = carLicense;
    return data;
  }
}