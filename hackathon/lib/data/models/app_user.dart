class AppUser {
  final String id;
  final String name;
  final String? phone;

  const AppUser({required this.id, required this.name, this.phone});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String?,
  );
}
