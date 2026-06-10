class Booking {
  final int id;
  final int slotId;
  final String userId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int venueId;
  final String venueName;
  final String sport;
  final String? address;

  const Booking({
    required this.id,
    required this.slotId,
    required this.userId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.venueId,
    required this.venueName,
    required this.sport,
    this.address,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as int,
        slotId: json['slot_id'] as int,
        userId: json['user_id'] as String,
        bookingDate: json['booking_date'] as String,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        venueId: json['venue_id'] as int,
        venueName: json['venue_name'] as String,
        sport: json['sport'] as String,
        address: json['address'] as String?,
      );
}
