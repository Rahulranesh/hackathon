class Venue {
  final int id;
  final String name;
  final String sport;
  final String address;
  final String? locality;
  final double? rating;
  final int? reviewCount;
  final String? sourceName;
  final String? sourceUrl;
  final String? openTime;
  final String? closeTime;

  const Venue({
    required this.id,
    required this.name,
    required this.sport,
    required this.address,
    this.locality,
    this.rating,
    this.reviewCount,
    this.sourceName,
    this.sourceUrl,
    this.openTime,
    this.closeTime,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    id: json['id'] as int,
    name: json['name'] as String,
    sport: json['sport'] as String,
    address: json['address'] as String,
    locality: json['locality'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    reviewCount: json['review_count'] as int?,
    sourceName: json['source_name'] as String?,
    sourceUrl: json['source_url'] as String?,
    openTime: json['open_time'] as String?,
    closeTime: json['close_time'] as String?,
  );
}
