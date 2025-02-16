class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'] ?? '',
    );
  }
}
