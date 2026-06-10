class Slot {
  final int id;
  final int venueId;
  final String startTime;
  final String endTime;
  final bool isBooked;
  final String? bookedBy;

  const Slot({
    required this.id,
    required this.venueId,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    this.bookedBy,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        id: json['id'] as int,
        venueId: json['venue_id'] as int,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        isBooked: (json['is_booked'] as int) == 1,
        bookedBy: json['booked_by'] as String?,
      );
}
