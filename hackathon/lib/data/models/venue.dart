class Venue {
  final int id;
  final String name;
  final String sport;
  final String address;

  const Venue({
    required this.id,
    required this.name,
    required this.sport,
    required this.address,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as int,
        name: json['name'] as String,
        sport: json['sport'] as String,
        address: json['address'] as String,
      );
}
